-- 1. New voters: why they are being added (turned 18 this year, or another
--    reason with a short note), and new household records, so a first-time
--    voter can be added at a house where nobody is on the list.
-- 2. A face photo for each claim form, taken on the phone after the form is
--    chosen. Photos go to a private storage bucket named by form id; only
--    the volunteer who filed the form and admins can read them.

-- 1 -------------------------------------------------------------------------

alter table public.voters
  add column new_reason text check (new_reason in ('TURNED_18_THIS_YEAR', 'OTHER')),
  add column new_reason_note text check (char_length(new_reason_note) <= 200);

alter table public.families
  add column created_by uuid references public.users (id);

-- A household the volunteer found in one of their own booths.
create function private.push_family(p_me public.users, p_id uuid, p_data jsonb) returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_part int := (p_data ->> 'part_no')::int;
begin
  if exists (select 1 from public.families where id = p_id) then
    return; -- already received
  end if;
  if v_part is null or not (v_part = any (private.my_parts())) then
    perform private.sync_reject('NOT_YOUR_BOOTH');
  end if;
  insert into public.families (id, code, part_no, house_no, head_name_hi, priority, created_by)
  values (p_id,
          '371-' || lpad(v_part::text, 3, '0') || '-V' || upper(left(replace(p_id::text, '-', ''), 8)),
          v_part,
          nullif(left(trim(p_data ->> 'house_no'), 40), ''),
          nullif(left(trim(p_data ->> 'head_name_hi'), 120), ''),
          4, p_me.id);
end
$$;

create or replace function private.push_voter(p_me public.users, p_id uuid, p_data jsonb) returns void
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
                             source_list, created_by, mobile, mobile_consent, new_reason, new_reason_note)
  values (p_id, v_family, nullif(upper(trim(p_data ->> 'epic')), ''), trim(p_data ->> 'name_hi'),
          p_data ->> 'relation_type', nullif(trim(p_data ->> 'relative_name_hi'), ''),
          (p_data ->> 'age')::int, p_data ->> 'gender', 'NEW', p_me.id,
          nullif(p_data ->> 'mobile', ''), coalesce((p_data ->> 'mobile_consent')::boolean, false),
          nullif(p_data ->> 'new_reason', ''), nullif(left(trim(p_data ->> 'new_reason_note'), 200), ''));
end
$$;

-- 2 -------------------------------------------------------------------------

alter table public.forms
  add column photo_path text,
  add column photo_at timestamptz;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('form-photos', 'form-photos', false, 1048576, array['image/jpeg'])
on conflict (id) do nothing;

-- The object for form F is "F.jpg". The volunteer who filed F may upload or
-- replace it once F has reached the server; admins may read every photo.
create function private.my_form_photo(p_bucket text, p_name text) returns boolean
language sql stable security definer set search_path = ''
as $$
  select p_bucket = 'form-photos'
     and exists (select 1 from public.forms f
                 where f.id::text || '.jpg' = p_name
                   and f.filed_by_user_id = private.current_user_id())
$$;
grant execute on function private.my_form_photo(text, text) to authenticated;

create policy "form photos: filer uploads" on storage.objects
  for insert to authenticated
  with check (private.my_form_photo(bucket_id, name));

create policy "form photos: filer replaces" on storage.objects
  for update to authenticated
  using (private.my_form_photo(bucket_id, name))
  with check (private.my_form_photo(bucket_id, name));

create policy "form photos: filer and admins read" on storage.objects
  for select to authenticated
  using (bucket_id = 'form-photos' and (private.is_admin() or private.my_form_photo(bucket_id, name)));

-- After uploading, the phone sends this so the form records its photo.
create function private.push_form_photo(p_me public.users, p_form uuid) returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not exists (select 1 from public.forms where id = p_form and filed_by_user_id = p_me.id) then
    perform private.sync_reject('UNKNOWN_RECORD');
  end if;
  if not exists (select 1 from storage.objects
                 where bucket_id = 'form-photos' and name = p_form::text || '.jpg') then
    perform private.sync_reject('PHOTO_NOT_UPLOADED');
  end if;
  update public.forms set photo_path = p_form::text || '.jpg', photo_at = now() where id = p_form;
end
$$;

-- Messages and the push dispatcher ------------------------------------------

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
    when 'NOT_YOUR_BOOTH'     then 'यह बूथ अब आपकी सूची में नहीं है'
    when 'PHOTO_NOT_UPLOADED' then 'फ़ोटो सर्वर तक नहीं पहुँची, दोबारा भेजी जाएगी'
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
        when 'family'     then perform private.push_family(v_me, v_id, v_item -> 'data');
        when 'voter'      then perform private.push_voter(v_me, v_id, v_item -> 'data');
        when 'visit'      then perform private.push_visit(v_me, v_settings, v_id, v_item -> 'data', v_skew);
        when 'form'       then perform private.push_form(v_me, v_settings, v_id, v_item -> 'data');
        when 'form_event' then perform private.push_form_event(v_me, v_settings, v_id, v_item -> 'data');
        when 'form_photo' then perform private.push_form_photo(v_me, v_id);
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

-- Phones get the new-voter reason and whether a form's photo has arrived.
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
                  'old_part_no', old_part_no, 'old_serial', old_serial,
                  'category', category, 'closest_2026', closest_2026,
                  'new_reason', new_reason, 'new_reason_note', new_reason_note)) from vot), '[]'),
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
                  'current_status', current_status, 'updated_at', updated_at,
                  'has_photo', photo_path is not null)) from frm), '[]'),
    'form_events', coalesce((select jsonb_agg(jsonb_build_object(
                  'id', id, 'form_id', form_id, 'status', status, 'changed_at', changed_at, 'note', note))
                  from fev), '[]')
  ) into v_result;

  return v_result;
end
$$;
