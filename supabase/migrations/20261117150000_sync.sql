-- Offline sync for the field app (spec sections 7, 8 and 12).
--
--   sync_pull()               everything the caller may see, as one JSON document
--   sync_push(items, now)     up to 50 outbox items; each is accepted or rejected
--
-- Both run as the definer and decide visibility themselves, using the same
-- booth scoping as the row-level security policies. Field users have no
-- direct write access to visits or forms: every write comes through
-- sync_push, which enforces the business rules on the server clock.

-- ---------------------------------------------------------------------------
-- Campaign dates and limits
-- ---------------------------------------------------------------------------

create table public.campaign_settings (
  id                  boolean primary key default true check (id),
  -- R4: visits dated before this day are rejected. The spec says 20 Nov 2026;
  -- it is set earlier while the app is being tested.
  visits_open_from    date not null,
  -- R4: no new form after this moment (server clock).
  claims_close_at     timestamptz not null,
  -- Status updates stay open until this moment.
  status_close_at     timestamptz not null,
  daily_family_target int not null default 30,
  bla2_daily_limit    int not null default 10,
  bla2_total_limit    int not null default 30
);

insert into public.campaign_settings (visits_open_from, claims_close_at, status_close_at)
values ('2026-11-17', '2026-12-16 23:59:59+05:30', '2027-01-04 23:59:59+05:30');

alter table public.campaign_settings enable row level security;
revoke all on public.campaign_settings from anon, authenticated;
grant select, update on public.campaign_settings to authenticated;
grant all on public.campaign_settings to service_role;

create policy member_read on public.campaign_settings for select to authenticated
  using ((select private.current_user_id()) is not null);
create policy admin_update on public.campaign_settings for update to authenticated
  using ((select private.is_admin())) with check ((select private.is_admin()));

-- ---------------------------------------------------------------------------
-- Scope helpers
-- ---------------------------------------------------------------------------

-- Families the caller may see and work on.
create function private.visible_family_ids() returns setof uuid
language sql stable security definer set search_path = ''
as $$
  with me as (
    select private.current_user_id() as id, private.my_parts() as parts, private.my_sections() as secs
  )
  select f.id
  from public.families f, me
  where me.id is not null
    and not f.is_hidden
    and (f.part_no = any (me.parts)
         or f.assigned_user_id = me.id
         or (f.section_no is not null and (f.part_no || ':' || f.section_no) = any (me.secs)))
$$;

-- Forms a BLA-2 has marked submitted through the BLA-2 route (R2).
create function private.bla2_submitted(p_user uuid, p_today_only boolean) returns int
language sql stable security definer set search_path = ''
as $$
  select count(*)::int
  from public.form_events e
  join public.forms f on f.id = e.form_id
  where e.changed_by = p_user
    and e.status = 'SUBMITTED'
    and f.route = 'BLA2'
    and (not p_today_only or (e.changed_at at time zone 'Asia/Kolkata')::date = private.today())
$$;

-- ---------------------------------------------------------------------------
-- Pull
-- ---------------------------------------------------------------------------

create function public.sync_pull() returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_me     public.users;
  v_result jsonb;
begin
  select * into v_me from public.users
  where id = private.current_user_id() and role in ('volunteer', 'bla2');
  if not found then
    raise exception 'NOT_AUTHORIZED' using errcode = '42501';
  end if;

  with fam as (
    select f.* from public.families f where f.id in (select private.visible_family_ids())
  ), vot as (
    select v.* from public.voters v where v.family_id in (select id from fam)
  ), vis as (
    select v.* from public.visits v where v.family_id in (select id from fam)
  ), vv as (
    select x.* from public.visit_voters x where x.visit_id in (select id from vis)
  ), frm as (
    select f.* from public.forms f where f.voter_id in (select id from vot)
  ), fev as (
    select e.* from public.form_events e where e.form_id in (select id from frm)
  ), parts as (
    select unnest(private.my_parts()) as part_no
    union
    select part_no from fam
  )
  select jsonb_build_object(
    'server_time', now(),
    'me', jsonb_build_object('id', v_me.id, 'name', v_me.name, 'role', v_me.role, 'mobile', v_me.mobile),
    'settings', (select to_jsonb(s) - 'id' from public.campaign_settings s),
    'quota', case when v_me.role = 'bla2' then jsonb_build_object(
               'today', private.bla2_submitted(v_me.id, true),
               'total', private.bla2_submitted(v_me.id, false)) end,
    'booths', coalesce((select jsonb_agg(jsonb_build_object('part_no', b.part_no, 'name_hi', b.name_hi) order by b.part_no)
                        from public.booths b where b.part_no in (select part_no from parts)), '[]'),
    'families', coalesce((select jsonb_agg(jsonb_build_object(
                  'id', id, 'code', code, 'part_no', part_no, 'section_no', section_no, 'house_no', house_no,
                  'head_name_hi', head_name_hi, 'priority', priority, 'needs_review', needs_review)) from fam), '[]'),
    'voters', coalesce((select jsonb_agg(jsonb_build_object(
                  'id', id, 'family_id', family_id, 'epic', epic, 'name_hi', name_hi,
                  'relation_type', relation_type, 'relative_name_hi', relative_name_hi, 'age', age,
                  'gender', gender, 'source_list', source_list, 'asdd_reason', asdd_reason,
                  'match_confidence', match_confidence, 'already_on_roll', already_on_roll)) from vot), '[]'),
    -- Other volunteers' GPS and remarks stay on the server.
    'visits', coalesce((select jsonb_agg(jsonb_build_object(
                  'id', id, 'family_id', family_id, 'by_me', user_id = v_me.id, 'visited_at', visited_at,
                  'outcome', outcome, 'revisit_on', revisit_on,
                  'remarks', case when user_id = v_me.id then remarks end)) from vis), '[]'),
    'visit_voters', coalesce((select jsonb_agg(jsonb_build_object(
                  'visit_id', visit_id, 'voter_id', voter_id, 'voter_outcome', voter_outcome,
                  'docs_seen', docs_seen)) from vv), '[]'),
    'forms', coalesce((select jsonb_agg(jsonb_build_object(
                  'id', id, 'voter_id', voter_id, 'form_type', form_type, 'route', route,
                  'reference_no', reference_no, 'filed_on', filed_on, 'by_me', filed_by_user_id = v_me.id,
                  'current_status', current_status, 'updated_at', updated_at)) from frm), '[]'),
    'form_events', coalesce((select jsonb_agg(jsonb_build_object(
                  'id', id, 'form_id', form_id, 'status', status, 'changed_at', changed_at, 'note', note))
                  from fev), '[]')
  ) into v_result;

  return v_result;
end
$$;

-- ---------------------------------------------------------------------------
-- Push
-- ---------------------------------------------------------------------------

-- Each push_* function either completes or raises an exception whose message
-- is the rejection code, so a rejected item leaves nothing behind.

create function private.sync_reject(p_code text) returns void
language plpgsql set search_path = ''
as $$
begin
  raise exception using message = p_code, errcode = 'P0001';
end
$$;

create function private.require_visible_family(p_family uuid) returns void
language plpgsql stable security definer set search_path = ''
as $$
begin
  if p_family is null or not exists (select 1 from private.visible_family_ids() x where x = p_family) then
    perform private.sync_reject('FAMILY_NOT_VISIBLE');
  end if;
end
$$;

create function private.push_voter(p_me public.users, p_id uuid, p_data jsonb) returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_family uuid := (p_data ->> 'family_id')::uuid;
begin
  if exists (select 1 from public.voters where id = p_id) then
    return; -- already received
  end if;
  perform private.require_visible_family(v_family);

  insert into public.voters (id, family_id, epic, name_hi, relation_type, relative_name_hi, age, gender,
                             source_list, created_by)
  values (p_id, v_family, nullif(upper(trim(p_data ->> 'epic')), ''), trim(p_data ->> 'name_hi'),
          p_data ->> 'relation_type', nullif(trim(p_data ->> 'relative_name_hi'), ''),
          (p_data ->> 'age')::int, p_data ->> 'gender', 'NEW', p_me.id);
end
$$;

create function private.push_visit(
  p_me public.users, p_settings public.campaign_settings, p_id uuid, p_data jsonb, p_clock_skew boolean
) returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_family     uuid := (p_data ->> 'family_id')::uuid;
  v_visited_at timestamptz := (p_data ->> 'visited_at')::timestamptz;
  v_flags      text[];
  v_member     jsonb;
begin
  if exists (select 1 from public.visits where id = p_id) then
    return;
  end if;
  perform private.require_visible_family(v_family);

  if v_visited_at is null or v_visited_at > now() + interval '1 day' then
    perform private.sync_reject('INVALID');
  end if;
  if (v_visited_at at time zone 'Asia/Kolkata')::date < p_settings.visits_open_from then
    perform private.sync_reject('VISIT_TOO_EARLY');
  end if;

  select coalesce(array_agg(distinct f), '{}') into v_flags
  from jsonb_array_elements_text(coalesce(p_data -> 'flags', '[]')) f
  where f in ('GPS_OFF', 'GPS_DENIED', 'GPS_INACCURATE');
  if p_clock_skew then
    v_flags := v_flags || 'CLOCK_SKEW';
  end if;

  insert into public.visits (id, family_id, user_id, visited_at, gps_lat, gps_lng, gps_accuracy_m,
                             met_person, outcome, remarks, revisit_on, flags)
  values (p_id, v_family, p_me.id, v_visited_at,
          (p_data ->> 'gps_lat')::double precision, (p_data ->> 'gps_lng')::double precision,
          (p_data ->> 'gps_accuracy_m')::real,
          left(nullif(trim(p_data ->> 'met_person'), ''), 100), p_data ->> 'outcome',
          left(nullif(trim(p_data ->> 'remarks'), ''), 500), (p_data ->> 'revisit_on')::date, v_flags);

  for v_member in select value from jsonb_array_elements(coalesce(p_data -> 'voters', '[]')) loop
    if not exists (select 1 from public.voters
                   where id = (v_member ->> 'voter_id')::uuid and family_id = v_family) then
      perform private.sync_reject('UNKNOWN_RECORD');
    end if;
    insert into public.visit_voters (visit_id, voter_id, voter_outcome, docs_seen, mobile, mobile_consent)
    values (p_id, (v_member ->> 'voter_id')::uuid, v_member ->> 'voter_outcome',
            coalesce((select array_agg(d) from jsonb_array_elements_text(coalesce(v_member -> 'docs_seen', '[]')) d
                      where d in ('AADHAAR', 'BIRTH_CERT', 'HIGHSCHOOL', 'RATION', 'ELECTRICITY', 'OTHER')), '{}'),
            nullif(v_member ->> 'mobile', ''), coalesce((v_member ->> 'mobile_consent')::boolean, false));
  end loop;

  -- R3: after three visits that found nobody, ask the office to review.
  if (select count(*) from public.visits where family_id = v_family and outcome = 'NOT_MET') >= 3
     and not exists (select 1 from public.visits where family_id = v_family and outcome <> 'NOT_MET') then
    update public.families set needs_review = true where id = v_family and not needs_review;
  end if;
end
$$;

create function private.push_form(
  p_me public.users, p_settings public.campaign_settings, p_id uuid, p_data jsonb
) returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_form   public.forms;
  v_family uuid;
begin
  select * into v_form from public.forms where id = p_id;
  select family_id into v_family from public.voters
  where id = coalesce(v_form.voter_id, (p_data ->> 'voter_id')::uuid);
  if v_family is null then
    perform private.sync_reject('UNKNOWN_RECORD');
  end if;
  perform private.require_visible_family(v_family);

  if v_form.id is null then
    -- R4: no new form after claims close, by the server clock.
    if now() > p_settings.claims_close_at then
      perform private.sync_reject('CLAIMS_CLOSED');
    end if;
    if p_data ->> 'form_type' not in ('6', '8') then
      perform private.sync_reject('INVALID');
    end if;
    insert into public.forms (id, voter_id, form_type, route, reference_no, filed_on, filed_by_user_id)
    values (p_id, (p_data ->> 'voter_id')::uuid, p_data ->> 'form_type', p_data ->> 'route',
            nullif(trim(p_data ->> 'reference_no'), ''), (p_data ->> 'filed_on')::date, p_me.id);
  else
    if now() > p_settings.status_close_at then
      perform private.sync_reject('STATUS_CLOSED');
    end if;
    -- Once submitted, the office owns the form's details.
    if v_form.current_status <> 'FILLED' then
      perform private.sync_reject('NOT_ALLOWED_STATUS');
    end if;
    update public.forms
    set route = p_data ->> 'route',
        reference_no = nullif(trim(p_data ->> 'reference_no'), ''),
        filed_on = (p_data ->> 'filed_on')::date
    where id = p_id;
  end if;
end
$$;

create function private.push_form_event(
  p_me public.users, p_settings public.campaign_settings, p_id uuid, p_data jsonb
) returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_form   public.forms;
  v_family uuid;
  v_status text := p_data ->> 'status';
begin
  if exists (select 1 from public.form_events where id = p_id) then
    return;
  end if;
  select * into v_form from public.forms where id = (p_data ->> 'form_id')::uuid;
  if v_form.id is null then
    perform private.sync_reject('UNKNOWN_RECORD');
  end if;
  select family_id into v_family from public.voters where id = v_form.voter_id;
  perform private.require_visible_family(v_family);

  if now() > p_settings.status_close_at then
    perform private.sync_reject('STATUS_CLOSED');
  end if;

  -- Field users record a form as filled, and as submitted. Every later status
  -- comes from the office (ERO list uploads).
  if v_status = 'FILLED' then
    if v_form.current_status <> 'FILLED' then
      perform private.sync_reject('NOT_ALLOWED_STATUS');
    end if;
  elsif v_status = 'SUBMITTED' then
    if v_form.current_status <> 'FILLED' then
      return; -- already submitted: nothing to do
    end if;
    if v_form.route is null then
      perform private.sync_reject('ROUTE_REQUIRED');
    end if;
    if v_form.reference_no is null then
      perform private.sync_reject('RECEIPT_REQUIRED'); -- R1
    end if;
    if v_form.route = 'BLA2' then
      if p_me.role <> 'bla2' then
        perform private.sync_reject('BLA2_ONLY');
      end if;
      -- R2: a BLA-2 may submit 10 forms a day and 30 in total.
      if private.bla2_submitted(p_me.id, true) >= p_settings.bla2_daily_limit then
        perform private.sync_reject('BLA2_DAILY_LIMIT');
      end if;
      if private.bla2_submitted(p_me.id, false) >= p_settings.bla2_total_limit then
        perform private.sync_reject('BLA2_TOTAL_LIMIT');
      end if;
    end if;
  else
    perform private.sync_reject('NOT_ALLOWED_STATUS');
  end if;

  insert into public.form_events (id, form_id, status, changed_by, client_ts, note)
  values (p_id, v_form.id, v_status, p_me.id, (p_data ->> 'client_ts')::timestamptz,
          left(nullif(trim(p_data ->> 'note'), ''), 300));
  update public.forms set current_status = v_status where id = v_form.id;
end
$$;

create function private.sync_message_hi(p_code text) returns text
language sql immutable set search_path = ''
as $$
  select case p_code
    when 'FAMILY_NOT_VISIBLE' then 'यह परिवार अब आपकी सूची में नहीं है'
    when 'VISIT_TOO_EARLY'    then 'भेंट की तारीख़ अभियान शुरू होने से पहले की है'
    when 'CLAIMS_CLOSED'      then 'दावा अवधि समाप्त (16 दिसंबर)'
    when 'STATUS_CLOSED'      then 'स्थिति बदलने की अवधि समाप्त'
    when 'RECEIPT_REQUIRED'   then 'रसीद / संदर्भ संख्या ज़रूरी है'
    when 'ROUTE_REQUIRED'     then 'फॉर्म कैसे जमा हुआ, यह चुनें'
    when 'BLA2_ONLY'          then 'बीएलए-2 के माध्यम वाला फॉर्म केवल बीएलए-2 जमा कर सकते हैं'
    when 'BLA2_DAILY_LIMIT'   then 'आज की सीमा (10) पूरी – फॉर्म स्वयं या ऑनलाइन जमा करें'
    when 'BLA2_TOTAL_LIMIT'   then 'कुल सीमा (30) पूरी – फॉर्म स्वयं या ऑनलाइन जमा करें'
    when 'DUPLICATE_FORM'     then 'यह फॉर्म पहले से दर्ज है'
    when 'DUPLICATE_REFERENCE' then 'यह संदर्भ संख्या पहले से दर्ज है'
    when 'DUPLICATE_EPIC'     then 'यह EPIC पहले से दर्ज है'
    when 'NOT_ALLOWED_STATUS' then 'यह बदलाव केवल कार्यालय कर सकता है'
    when 'REVISIT_REQUIRED'   then 'दोबारा जाने की तारीख़ चुनें'
    when 'MOBILE_CONSENT'     then 'मोबाइल नंबर के लिए सहमति ज़रूरी है'
    when 'INVALID_MOBILE'     then 'सही मोबाइल नंबर डालें'
    when 'UNKNOWN_RECORD'     then 'जुड़ा हुआ रिकॉर्ड नहीं मिला'
    else 'जानकारी अधूरी या गलत है'
  end
$$;

create function public.sync_push(p_items jsonb, p_device_now timestamptz default null) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_me         public.users;
  v_settings   public.campaign_settings;
  v_item       jsonb;
  v_id         uuid;
  v_code       text;
  v_constraint text;
  v_results    jsonb := '[]';
  v_accepted   int := 0;
  -- Server time is the truth for deadlines; a phone clock more than 10 minutes
  -- off is recorded on the visits it sends.
  v_skew       boolean := p_device_now is not null
                          and abs(extract(epoch from (now() - p_device_now))) > 600;
begin
  select * into v_me from public.users
  where id = private.current_user_id() and role in ('volunteer', 'bla2');
  if not found then
    raise exception 'NOT_AUTHORIZED' using errcode = '42501';
  end if;
  if jsonb_typeof(p_items) is distinct from 'array' or jsonb_array_length(p_items) > 50 then
    raise exception 'BAD_BATCH' using errcode = '22023';
  end if;
  select * into v_settings from public.campaign_settings;

  for v_item in select value from jsonb_array_elements(p_items) loop
    v_code := 'OK';
    v_id := null;
    begin
      v_id := (v_item ->> 'uuid')::uuid;
      case v_item ->> 'entity'
        when 'voter'      then perform private.push_voter(v_me, v_id, v_item -> 'data');
        when 'visit'      then perform private.push_visit(v_me, v_settings, v_id, v_item -> 'data', v_skew);
        when 'form'       then perform private.push_form(v_me, v_settings, v_id, v_item -> 'data');
        when 'form_event' then perform private.push_form_event(v_me, v_settings, v_id, v_item -> 'data');
        else perform private.sync_reject('INVALID');
      end case;
    exception
      when raise_exception then
        v_code := sqlerrm;
      when unique_violation then
        get stacked diagnostics v_constraint = constraint_name;
        v_code := case v_constraint
          when 'forms_reference_no_key'  then 'DUPLICATE_REFERENCE'
          when 'forms_one_open_per_type' then 'DUPLICATE_FORM'
          when 'voters_epic_key'         then 'DUPLICATE_EPIC'
          else 'INVALID' end;
      when check_violation then
        get stacked diagnostics v_constraint = constraint_name;
        v_code := case v_constraint
          when 'forms_check'               then 'RECEIPT_REQUIRED'
          when 'visits_check'              then 'REVISIT_REQUIRED'
          when 'visit_voters_check'        then 'MOBILE_CONSENT'
          when 'visit_voters_mobile_check' then 'INVALID_MOBILE'
          else 'INVALID' end;
      when foreign_key_violation then
        v_code := 'UNKNOWN_RECORD';
      when others then
        v_code := 'INVALID';
    end;

    if v_code = 'OK' then
      v_accepted := v_accepted + 1;
      v_results := v_results || jsonb_build_object('uuid', v_item ->> 'uuid', 'ok', true);
    else
      v_results := v_results || jsonb_build_object(
        'uuid', v_item ->> 'uuid', 'ok', false, 'code', v_code, 'message_hi', private.sync_message_hi(v_code));
    end if;
  end loop;

  insert into public.audit_log (user_id, action, entity, detail)
  values (v_me.id, 'sync_push', 'outbox',
          jsonb_build_object('accepted', v_accepted, 'rejected', jsonb_array_length(p_items) - v_accepted,
                             'clock_skew', v_skew));

  return jsonb_build_object('server_time', now(), 'results', v_results);
end
$$;

revoke execute on function public.sync_pull(), public.sync_push(jsonb, timestamptz) from public, anon;
grant execute on function public.sync_pull(), public.sync_push(jsonb, timestamptz) to authenticated;
