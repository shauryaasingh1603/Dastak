-- Person-first visits (the family grouping in the source data cannot be
-- trusted). Every listed person is their own record; at the door the
-- volunteer confirms who else on the list lives there and records them in
-- the same visit. Each visit where someone was met also records a household
-- contact (often a parent of someone who moved away): name, relation, and
-- phone number with consent, or a recorded refusal.

alter table public.visits
  add column contact_name text,
  add column contact_relation text,
  add column contact_mobile text,
  add column contact_consent boolean not null default false,
  add column contact_refused boolean not null default false,
  add constraint visits_contact_relation check
    (contact_relation in ('FATHER', 'MOTHER', 'HUSBAND', 'WIFE', 'SON', 'DAUGHTER', 'SIBLING', 'SELF', 'OTHER')),
  add constraint visits_contact_mobile_format check (contact_mobile ~ '^[6-9][0-9]{9}$'),
  add constraint visits_contact_consent check (contact_mobile is null or contact_consent);

-- Progress is counted in people. 45 a day is the old 30 households at about
-- 1.5 listed people per door; admins can change it.
alter table public.campaign_settings add column daily_people_target int not null default 45;

create or replace function private.push_visit(
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
  where f in ('GPS_OFF', 'GPS_DENIED', 'GPS_INACCURATE', 'GPS_TIMEOUT', 'GPS_APPROXIMATE');
  if p_clock_skew then
    v_flags := v_flags || 'CLOCK_SKEW';
  end if;

  -- Someone was met: the household contact's number, or a recorded refusal.
  if p_data ->> 'outcome' <> 'NOT_MET'
     and nullif(p_data ->> 'contact_mobile', '') is null
     and not coalesce((p_data ->> 'contact_refused')::boolean, false) then
    perform private.sync_reject('CONTACT_REQUIRED');
  end if;

  insert into public.visits (id, family_id, user_id, visited_at, gps_lat, gps_lng, gps_accuracy_m,
                             met_person, outcome, remarks, revisit_on, flags,
                             contact_name, contact_relation, contact_mobile, contact_consent, contact_refused)
  values (p_id, v_family, p_me.id, v_visited_at,
          (p_data ->> 'gps_lat')::double precision, (p_data ->> 'gps_lng')::double precision,
          (p_data ->> 'gps_accuracy_m')::real,
          left(nullif(trim(p_data ->> 'met_person'), ''), 100), p_data ->> 'outcome',
          left(nullif(trim(p_data ->> 'remarks'), ''), 500), (p_data ->> 'revisit_on')::date, v_flags,
          left(nullif(trim(p_data ->> 'contact_name'), ''), 100), nullif(p_data ->> 'contact_relation', ''),
          nullif(p_data ->> 'contact_mobile', ''), coalesce((p_data ->> 'contact_consent')::boolean, false),
          coalesce((p_data ->> 'contact_refused')::boolean, false));

  for v_member in select value from jsonb_array_elements(coalesce(p_data -> 'voters', '[]')) loop
    -- A visit can cover listed people from other records at the same house,
    -- as long as the volunteer may see them.
    if not exists (select 1 from public.voters v
                   where v.id = (v_member ->> 'voter_id')::uuid
                     and v.family_id in (select private.visible_family_ids())) then
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

create or replace function private.sync_message_hi(p_code text) returns text
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
    when 'CONTACT_REQUIRED'   then 'घर के व्यक्ति का मोबाइल नंबर दर्ज करें या “मना किया” चुनें'
    else 'जानकारी अधूरी या गलत है'
  end
$$;

create or replace function public.sync_push(p_items jsonb, p_device_now timestamptz default null) returns jsonb
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
          when 'voters_mobile_consent'     then 'MOBILE_CONSENT'
          when 'voters_mobile_format'      then 'INVALID_MOBILE'
          when 'visits_contact_consent'    then 'MOBILE_CONSENT'
          when 'visits_contact_mobile_format' then 'INVALID_MOBILE'
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

create or replace function public.sync_pull() returns jsonb
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
                  'match_confidence', match_confidence, 'already_on_roll', already_on_roll,
                  'old_part_no', old_part_no, 'old_serial', old_serial)) from vot), '[]'),
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
