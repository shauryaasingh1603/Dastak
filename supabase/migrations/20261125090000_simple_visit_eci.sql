-- The simpler visit (three choices) and the ECI screenshot.
--
-- 1. Permanently shifted voters are hidden from volunteers' lists (records
--    with field work stay visible).
-- 2. A visit result "OTHER" with the reason in remarks; a met visit no
--    longer requires the household contact's number.
-- 3. Each form can hold two images in the form-photos bucket: the face
--    photo (<form id>.jpg) and the ECI "Track application status"
--    screenshot (<form id>-eci.jpg). The screenshot is read by Claude (Edge
--    Function eci-read), which records the ECI reference number, name,
--    form type, status and date, and marks the form submitted.

-- 1 -------------------------------------------------------------------------
update public.families f set is_hidden = true
where not f.is_hidden
  and exists (select 1 from public.voters v where v.family_id = f.id and v.category = 'SHIFTED')
  and not exists (select 1 from public.voters v where v.family_id = f.id and v.category <> 'SHIFTED')
  and f.created_by is null
  and not exists (select 1 from public.visits vi where vi.family_id = f.id)
  and not exists (select 1 from public.voters v join public.visit_voters vv on vv.voter_id = v.id
                  where v.family_id = f.id)
  and not exists (select 1 from public.voters v join public.forms fo on fo.voter_id = v.id
                  where v.family_id = f.id);

-- 2 -------------------------------------------------------------------------
alter table public.visits drop constraint visits_outcome_check;
alter table public.visits add constraint visits_outcome_check check (outcome in
  ('ELIGIBLE', 'CORRECTION', 'MOVED_IN', 'SHIFTED', 'DEAD', 'NOT_MET', 'ALREADY_ON_ROLL', 'OTHER'));
alter table public.visit_voters drop constraint visit_voters_voter_outcome_check;
alter table public.visit_voters add constraint visit_voters_voter_outcome_check check (voter_outcome in
  ('ELIGIBLE', 'CORRECTION', 'MOVED_IN', 'SHIFTED', 'DEAD', 'NOT_MET', 'ALREADY_ON_ROLL', 'OTHER'));

do $do$
declare
  d text := pg_get_functiondef('private.push_visit(public.users, public.campaign_settings, uuid, jsonb, boolean)'::regprocedure);
  a text := $q$  if p_data ->> 'outcome' <> 'NOT_MET'
     and nullif(p_data ->> 'contact_mobile', '') is null
     and not coalesce((p_data ->> 'contact_refused')::boolean, false) then
    perform private.sync_reject('CONTACT_REQUIRED');
  end if;
$q$;
begin
  if position(a in d) = 0 then raise exception 'push_visit: expected text not found'; end if;
  execute replace(d, a, '');
end
$do$;

-- 3 -------------------------------------------------------------------------
alter table public.forms
  add column eci_path text,
  add column eci_at timestamptz,
  add column eci_status text check (eci_status in ('PENDING', 'READ', 'FAILED', 'NOT_ECI')),
  add column eci_reference_no text,
  add column eci_name text,
  add column eci_form_type text,
  add column eci_tracking_status text,
  add column eci_status_date date,
  add column eci_state text,
  add column eci_ac text,
  add column eci_name_matches boolean,
  add column eci_note text,
  add column eci_read_at timestamptz;

-- The filer may upload either image of their form; admins read both.
create or replace function private.my_form_photo(p_bucket text, p_name text) returns boolean
language sql stable security definer set search_path = ''
as $$
  select p_bucket = 'form-photos'
     and exists (select 1 from public.forms f
                 where p_name in (f.id::text || '.jpg', f.id::text || '-eci.jpg')
                   and f.filed_by_user_id = private.current_user_id())
$$;

drop function private.push_form_photo(public.users, uuid);
create function private.push_form_photo(p_me public.users, p_form uuid, p_kind text) returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_name text := p_form::text || case when p_kind = 'eci' then '-eci.jpg' else '.jpg' end;
begin
  if not exists (select 1 from public.forms where id = p_form and filed_by_user_id = p_me.id) then
    perform private.sync_reject('UNKNOWN_RECORD');
  end if;
  if not exists (select 1 from storage.objects where bucket_id = 'form-photos' and name = v_name) then
    perform private.sync_reject('PHOTO_NOT_UPLOADED');
  end if;
  if p_kind = 'eci' then
    -- A new screenshot is read again.
    update public.forms set eci_path = v_name, eci_at = now(), eci_status = 'PENDING', eci_note = null
    where id = p_form;
  else
    update public.forms set photo_path = v_name, photo_at = now() where id = p_form;
  end if;
end
$$;

do $do$
declare
  d text := pg_get_functiondef('public.sync_push(jsonb, timestamptz)'::regprocedure);
  a text := $q$when 'form_photo' then perform private.push_form_photo(v_me, (v_item -> 'data' ->> 'form_id')::uuid);$q$;
begin
  if position(a in d) = 0 then raise exception 'sync_push: expected text not found'; end if;
  execute replace(d, a, $q$when 'form_photo' then perform private.push_form_photo(v_me, (v_item -> 'data' ->> 'form_id')::uuid,
                                                         coalesce(v_item -> 'data' ->> 'kind', 'face'));$q$);
end
$do$;

-- Phones see whether each image arrived and what the ECI screenshot said.
do $do$
declare
  d text := pg_get_functiondef('public.sync_pull()'::regprocedure);
  a text := $q$'has_photo', photo_path is not null$q$;
begin
  if position(a in d) = 0 then raise exception 'sync_pull: expected text not found'; end if;
  execute replace(d, a, a || $q$, 'has_eci', eci_path is not null,
                  'eci_status', eci_status, 'eci_reference_no', eci_reference_no$q$);
end
$do$;

-- Admin pages show the ECI reading.
do $do$
declare
  d text := pg_get_functiondef('public.admin_person(uuid)'::regprocedure);
  a text := $q$'photo_path', fo.photo_path, 'photo_at', fo.photo_at,$q$;
begin
  if position(a in d) = 0 then raise exception 'admin_person: expected text not found'; end if;
  execute replace(d, a, a || $q$
        'eci_path', fo.eci_path, 'eci_status', fo.eci_status, 'eci_reference_no', fo.eci_reference_no,
        'eci_name', fo.eci_name, 'eci_form_type', fo.eci_form_type, 'eci_tracking_status', fo.eci_tracking_status,
        'eci_status_date', fo.eci_status_date, 'eci_name_matches', fo.eci_name_matches, 'eci_note', fo.eci_note,$q$);

  d := pg_get_functiondef('public.admin_rows(text, jsonb)'::regprocedure);
  a := $q$'has_photo', fo.photo_path is not null$q$;
  if position(a in d) = 0 then raise exception 'admin_rows: expected text not found'; end if;
  execute replace(d, a, a || $q$, 'has_eci', fo.eci_path is not null,
        'eci_status', fo.eci_status, 'eci_reference_no', fo.eci_reference_no, 'eci_name', fo.eci_name,
        'eci_tracking_status', fo.eci_tracking_status, 'eci_status_date', fo.eci_status_date,
        'eci_name_matches', fo.eci_name_matches$q$);
end
$do$;

-- For the eci-read Edge Function (service role only): what is waiting, and
-- recording a reading. A readable reference number fills the form's receipt
-- and marks it submitted (online), unless another form already has it.
create function public.eci_pending(p_form uuid default null, p_limit int default 10) returns jsonb
language sql stable security definer set search_path = ''
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
           'form_id', fo.id, 'eci_path', fo.eci_path, 'form_type', fo.form_type,
           'name', vo.name_hi, 'relative', vo.relative_name_hi, 'age', vo.age, 'gender', vo.gender)), '[]')
  from (select * from public.forms
        where eci_status = 'PENDING' and eci_path is not null and (p_form is null or id = p_form)
        order by eci_at limit p_limit) fo
  join public.voters vo on vo.id = fo.voter_id
$$;

create function public.eci_record(p_form uuid, p_reading jsonb) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_form   public.forms;
  v_ref    text := nullif(upper(regexp_replace(coalesce(p_reading ->> 'reference_number', ''), '\s', '', 'g')), '');
  v_status text := p_reading ->> 'status';
  v_note   text := nullif(p_reading ->> 'note', '');
begin
  select * into v_form from public.forms where id = p_form for update;
  if not found then
    return jsonb_build_object('ok', false, 'code', 'UNKNOWN_FORM');
  end if;
  if v_status not in ('READ', 'FAILED', 'NOT_ECI') then
    raise exception 'BAD_STATUS' using errcode = '22023';
  end if;

  if v_status = 'READ' and v_ref is not null
     and exists (select 1 from public.forms x where x.id <> p_form and x.reference_no = v_ref) then
    v_note := coalesce(v_note || ' · ', '') || 'This reference number is already on another form.';
    v_ref := null;
  end if;

  update public.forms set
    eci_status = v_status, eci_read_at = now(), eci_note = left(v_note, 500),
    eci_reference_no = coalesce(nullif(upper(regexp_replace(coalesce(p_reading ->> 'reference_number', ''), '\s', '', 'g')), ''), eci_reference_no),
    eci_name = nullif(left(p_reading ->> 'applicant_name', 120), ''),
    eci_form_type = nullif(left(p_reading ->> 'form_type', 20), ''),
    eci_tracking_status = nullif(left(p_reading ->> 'tracking_status', 60), ''),
    eci_status_date = nullif(p_reading ->> 'status_date', '')::date,
    eci_state = nullif(left(p_reading ->> 'state', 60), ''),
    eci_ac = nullif(left(p_reading ->> 'assembly_constituency', 60), ''),
    eci_name_matches = (p_reading ->> 'name_matches')::boolean
  where id = p_form;

  if v_status = 'READ' and v_ref is not null and v_form.reference_no is null then
    update public.forms set
      reference_no = v_ref,
      route = coalesce(route, 'ONLINE'),
      filed_on = coalesce(filed_on, nullif(p_reading ->> 'status_date', '')::date, private.today()),
      current_status = case when current_status = 'FILLED' then 'SUBMITTED' else current_status end,
      updated_at = now()
    where id = p_form;
    if v_form.current_status = 'FILLED' then
      insert into public.form_events (id, form_id, status, changed_by, changed_at, note)
      values (gen_random_uuid(), p_form, 'SUBMITTED', v_form.filed_by_user_id, now(), 'ECI screenshot');
    end if;
  end if;
  return jsonb_build_object('ok', true);
end
$$;

revoke all on function public.eci_pending(uuid, int), public.eci_record(uuid, jsonb) from public, anon, authenticated;
grant execute on function public.eci_pending(uuid, int), public.eci_record(uuid, jsonb) to service_role;
