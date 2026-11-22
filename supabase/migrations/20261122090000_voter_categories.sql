-- Every person gets the workbook's category, so volunteers can filter by it,
-- and the people on the workbook's "ASDD No Visit" sheet can be loaded:
--
--   UNTRACEABLE   ASDD: untraceable / absent            (ASDD Visit List)
--   SHIFTED       ASDD: permanently shifted             (ASDD Visit List)
--   DECEASED      ASDD: deceased, verify with family    (ASDD No Visit)
--   DUPLICATE     ASDD: already enrolled elsewhere      (ASDD No Visit)
--   ALREADY_BACK  back in the April-2026 roll           (ASDD No Visit)
--   POSS_HIGH / POSS_MEDIUM / POSS_LOW                  (Possibly Deleted)
--   NEW           added by a volunteer in the field
--
-- closest_2026 is the workbook's "Closest 2026 entry (check)": for possibly
-- deleted people, the most similar entry in the April-2026 roll, to be
-- checked before visiting.

alter table public.voters
  add column category text check (category in ('UNTRACEABLE', 'SHIFTED', 'DECEASED', 'DUPLICATE',
                                               'ALREADY_BACK', 'POSS_HIGH', 'POSS_MEDIUM', 'POSS_LOW', 'NEW')),
  add column closest_2026 text;

update public.voters set category = case
  when source_list = 'NEW' then 'NEW'
  when source_list = 'POSS_DEL' then 'POSS_' || coalesce(match_confidence, 'MEDIUM')
  else coalesce(asdd_reason, 'SHIFTED') end;

-- Anyone inserted without a category (voters added in the field) gets one.
create function private.voter_default_category() returns trigger
language plpgsql set search_path = ''
as $$
begin
  if new.category is null then
    new.category := case
      when new.source_list = 'NEW' then 'NEW'
      when new.source_list = 'POSS_DEL' then 'POSS_' || coalesce(new.match_confidence, 'MEDIUM')
      else coalesce(new.asdd_reason, 'SHIFTED') end;
  end if;
  return new;
end
$$;
create trigger voters_category before insert on public.voters
  for each row execute function private.voter_default_category();

alter table public.voters alter column category set not null;

-- import_people now takes the category, the closest-entry note and whether
-- the person is already back on the roll. An EPIC or roll reference that a
-- person already loaded holds is left blank and the record flagged, so one
-- clash cannot stop a batch.
create or replace function public.import_people(p_token text, p_people jsonb) returns int
language plpgsql security definer set search_path = ''
as $$
declare
  v_count int;
begin
  if not private.import_allowed(p_token) then
    raise exception 'IMPORT_NOT_ALLOWED' using errcode = '42501';
  end if;
  with input as (
    select x.*,
           exists (select 1 from public.voters v where v.epic = x.epic) as epic_taken,
           exists (select 1 from public.voters v where v.roll_ref = x.roll_ref) as ref_taken
    from jsonb_to_recordset(p_people) as x(
      code text, part int, house text, name text, priority int, review boolean, epic text, roll_ref text,
      relation text, relative text, age int, gender text, source text, asdd_reason text,
      old_part int, old_serial int, likely_part int, confidence text,
      category text, closest text, on_roll boolean)
  ), fam as (
    insert into public.families (code, part_no, house_no, head_name_hi, priority, needs_review)
    select code, part, house, name, priority, review or epic_taken from input
    on conflict (code) do nothing
    returning id, code
  )
  insert into public.voters (family_id, epic, roll_ref, name_hi, relation_type, relative_name_hi, age, gender,
                             source_list, asdd_reason, old_part_no, old_serial, likely_new_part, match_confidence,
                             category, closest_2026, already_on_roll)
  select fam.id, case when i.epic_taken then null else i.epic end,
         case when i.ref_taken then null else i.roll_ref end,
         i.name, i.relation, i.relative, i.age, i.gender,
         i.source, i.asdd_reason, i.old_part, i.old_serial, i.likely_part, i.confidence,
         i.category, nullif(i.closest, ''), coalesce(i.on_roll, false)
  from input i join fam using (code);
  get diagnostics v_count = row_count;
  return v_count;
end
$$;

-- Fills in the closest-entry note for people loaded before it was imported.
create function public.import_voter_notes(p_token text, p_rows jsonb) returns int
language plpgsql security definer set search_path = ''
as $$
declare
  v_count int;
begin
  if not private.import_allowed(p_token) then
    raise exception 'IMPORT_NOT_ALLOWED' using errcode = '42501';
  end if;
  update public.voters v set closest_2026 = nullif(x.closest, '')
  from jsonb_to_recordset(p_rows) as x(code text, closest text), public.families f
  where f.code = x.code and v.family_id = f.id and v.closest_2026 is distinct from nullif(x.closest, '');
  get diagnostics v_count = row_count;
  return v_count;
end
$$;

-- Closed to everyone; an import run opens them with a fresh one-time token
-- and closes them again afterwards.
revoke execute on function public.import_people(text, jsonb), public.import_voter_notes(text, jsonb)
  from public, anon, authenticated;

-- Phones get the category and the closest-entry note.
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
                  'category', category, 'closest_2026', closest_2026)) from vot), '[]'),
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
