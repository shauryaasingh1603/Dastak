-- Switching to the final visit list (booth numbers = 2027 draft-roll parts
-- 1-431), keeping everything already recorded in the field.
--
-- 1. tools/import/final_list.py prepares the rows; they are loaded into
--    private.final_stage / private.final_booths with import_final_stage
--    (one-time import token, as for earlier imports).
-- 2. private.apply_final_list(false) is a dry run: counts only, no change.
--    private.apply_final_list(true) switches, in one transaction:
--    - people on the final list are matched to the records already loaded
--      (by EPIC, else by name + relative + 2025 booth) and updated in place,
--      so their visits, forms and photos stay attached;
--    - people new on the final list are added;
--    - records not on the final list are hidden, except those with field
--      work (visits, forms, voters or households added in the field), which
--      stay visible;
--    - every record and every volunteer's booths move to the new numbering
--      (an April-2026 booth becomes the draft part(s) holding at least 10%
--      of its people);
--    - booths become the 431 draft parts with their polling stations.
-- A full copy of the list before the switch is in schema backup_20261124.

create table private.final_stage (
  code        text primary key,
  source      text not null,
  category    text not null,
  asdd_reason text,
  confidence  text,
  epic        text,
  name        text not null,
  relation    text,
  relative    text,
  age         int,
  gender      text,
  house       text,
  part        int not null,
  section     text,
  april_part  int,
  old_part    int,
  old_serial  int,
  closest     text,
  review      boolean not null default false,
  priority    int not null
);

create table private.final_booths (
  part_no            int primary key,
  polling_station_hi text
);

create function public.import_final_stage(p_token text, p_people jsonb, p_booths jsonb default null) returns int
language plpgsql security definer set search_path = ''
as $$
declare
  v_count int;
begin
  if not private.import_allowed(p_token) then
    raise exception 'IMPORT_NOT_ALLOWED' using errcode = '42501';
  end if;
  if p_booths is not null then
    insert into private.final_booths
    select * from jsonb_populate_recordset(null::private.final_booths, p_booths)
    on conflict (part_no) do update set polling_station_hi = excluded.polling_station_hi;
  end if;
  insert into private.final_stage
  select * from jsonb_populate_recordset(null::private.final_stage, coalesce(p_people, '[]'))
  on conflict (code) do nothing;
  get diagnostics v_count = row_count;
  return v_count;
end
$$;
revoke execute on function public.import_final_stage(text, jsonb, jsonb) from public, anon, authenticated;

create function private.apply_final_list(p_commit boolean) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_stats jsonb;
begin
  -- Which loaded record each final-list person is.
  create temporary table fl_match (code text primary key, voter_id uuid unique, family_id uuid, how text)
    on commit drop;
  insert into fl_match
  select s.code, v.id, v.family_id, 'EPIC'
  from private.final_stage s join public.voters v on v.epic = s.epic
  where s.epic is not null;

  -- No EPIC match: the same name, relative and 2025 booth, when that points
  -- to exactly one record on each side.
  with cand as (
    select s.code, v.id as voter_id, v.family_id,
           count(*) over (partition by s.code) as per_row,
           count(*) over (partition by v.id) as per_voter
    from private.final_stage s
    join public.voters v
      on v.name_hi = s.name and coalesce(v.relative_name_hi, '') = coalesce(s.relative, '')
     and v.old_part_no = s.old_part and v.source_list <> 'NEW'
    where s.name <> '(नाम दर्ज नहीं)'
      and not exists (select 1 from fl_match m where m.code = s.code)
      and not exists (select 1 from fl_match m where m.voter_id = v.id)
  )
  insert into fl_match
  select code, voter_id, family_id, 'name' from cand where per_row = 1 and per_voter = 1;

  -- April-2026 booth -> draft parts, from where the final list puts people.
  create temporary table fl_map on commit drop as
    select april_part, part, count(*) as n,
           count(*)::numeric / sum(count(*)) over (partition by april_part) as share,
           row_number() over (partition by april_part order by count(*) desc, part) as rank
    from private.final_stage where april_part is not null
    group by april_part, part;

  -- Records with field work, which must stay visible.
  create temporary table fl_worked on commit drop as
    select f.id as family_id from public.families f
    where f.created_by is not null
       or exists (select 1 from public.visits v where v.family_id = f.id)
       or exists (select 1 from public.voters vo where vo.family_id = f.id and vo.source_list = 'NEW')
       or exists (select 1 from public.voters vo join public.visit_voters vv on vv.voter_id = vo.id
                  where vo.family_id = f.id)
       or exists (select 1 from public.voters vo join public.forms fo on fo.voter_id = vo.id
                  where vo.family_id = f.id);

  v_stats := jsonb_build_object(
    'final_list_people', (select count(*) from private.final_stage),
    'final_list_booths', (select count(*) from private.final_booths),
    'matched_by_epic', (select count(*) from fl_match where how = 'EPIC'),
    'matched_by_name', (select count(*) from fl_match where how = 'name'),
    'new_people', (select count(*) from private.final_stage s
                   where not exists (select 1 from fl_match m where m.code = s.code)),
    'loaded_not_on_final_list', (select count(*) from public.voters v
                                 where not exists (select 1 from fl_match m where m.voter_id = v.id)),
    'households_with_field_work', (select count(*) from fl_worked),
    'with_field_work_on_final_list', (select count(*) from fl_worked w
                                      where exists (select 1 from fl_match m where m.family_id = w.family_id)),
    'visited_people_on_final_list', (select count(distinct vv.voter_id) from public.visit_voters vv
                                     where exists (select 1 from fl_match m where m.voter_id = vv.voter_id)),
    'visited_people_total', (select count(distinct voter_id) from public.visit_voters),
    'forms_on_final_list', (select count(*) from public.forms fo
                            where exists (select 1 from fl_match m where m.voter_id = fo.voter_id)),
    'forms_total', (select count(*) from public.forms),
    'april_booths_split', (select count(distinct april_part) from fl_map where share >= 0.10 and rank > 1),
    'assignments_now', (select count(*) from public.assignments),
    'assignments_after', (select count(*) from (
        select distinct a.user_id, mp.part
        from public.assignments a join fl_map mp on mp.april_part = a.part_no and mp.share >= 0.10
        where a.to_date is null or a.to_date >= private.today()) x)
  );

  if not p_commit then
    return v_stats || jsonb_build_object('committed', false);
  end if;

  -- Booths: the 431 draft parts.
  insert into public.booths (part_no, name_hi, polling_station_hi)
  select part_no, 'बूथ ' || part_no, polling_station_hi from private.final_booths
  on conflict (part_no) do update set name_hi = excluded.name_hi, polling_station_hi = excluded.polling_station_hi;

  -- Records not on the final list: into the new numbering, hidden unless
  -- they carry field work.
  update public.families f set
    part_no = coalesce((select mp.part from fl_map mp where mp.april_part = f.part_no and mp.rank = 1), f.part_no),
    is_hidden = not exists (select 1 from fl_worked w where w.family_id = f.id)
  where not exists (select 1 from fl_match m where m.family_id = f.id);

  -- Matched records take the final list's details.
  update public.families f set
    part_no = s.part, house_no = s.house, head_name_hi = s.name, priority = s.priority,
    needs_review = s.review, is_hidden = false
  from fl_match m join private.final_stage s on s.code = m.code
  where f.id = m.family_id;

  update public.voters v set
    name_hi = s.name, relation_type = s.relation, relative_name_hi = s.relative, age = s.age,
    gender = s.gender, source_list = s.source, asdd_reason = s.asdd_reason,
    match_confidence = s.confidence, category = s.category, closest_2026 = s.closest,
    draft_part = s.part, draft_section = s.section, likely_new_part = s.part,
    old_part_no = s.old_part, old_serial = coalesce(s.old_serial, v.old_serial), already_on_roll = false,
    epic = coalesce(v.epic, case when not exists (select 1 from public.voters x where x.epic = s.epic) then s.epic end)
  from fl_match m join private.final_stage s on s.code = m.code
  where v.id = m.voter_id;

  -- New people.
  with fresh as (
    select s.*, count(*) over (partition by s.old_part, s.old_serial) as ref_n
    from private.final_stage s
    where not exists (select 1 from fl_match m where m.code = s.code)
  ), fam as (
    insert into public.families (code, part_no, house_no, head_name_hi, priority, needs_review)
    select code, part, house, name, priority, review from fresh
    returning id, code
  )
  insert into public.voters (family_id, epic, roll_ref, name_hi, relation_type, relative_name_hi, age, gender,
                             source_list, asdd_reason, old_part_no, old_serial, likely_new_part, match_confidence,
                             category, closest_2026, draft_part, draft_section)
  select fam.id,
         case when exists (select 1 from public.voters x where x.epic = s.epic) then null else s.epic end,
         case when s.old_part is null or s.old_serial is null or s.ref_n > 1 then null
              when exists (select 1 from public.voters x
                           where x.roll_ref = 'P' || lpad(s.old_part::text, 3, '0') || '-S' || lpad(s.old_serial::text, 4, '0'))
              then null
              else 'P' || lpad(s.old_part::text, 3, '0') || '-S' || lpad(s.old_serial::text, 4, '0') end,
         s.name, s.relation, s.relative, s.age, s.gender, s.source, s.asdd_reason, s.old_part, s.old_serial,
         s.part, s.confidence, s.category, s.closest, s.part, s.section
  from fresh s join fam using (code);

  -- Volunteers' booths in the new numbering.
  create temporary table fl_assign on commit drop as
    select distinct a.user_id, mp.part
    from public.assignments a join fl_map mp on mp.april_part = a.part_no and mp.share >= 0.10
    where a.to_date is null or a.to_date >= private.today();
  delete from public.assignments a where a.to_date is null or a.to_date >= private.today();
  insert into public.assignments (user_id, part_no)
  select user_id, part from fl_assign;

  -- Old booth numbers above 431 are no longer used.
  delete from public.booths b
  where b.part_no > 431
    and not exists (select 1 from public.families f where f.part_no = b.part_no)
    and not exists (select 1 from public.assignments a where a.part_no = b.part_no);

  update private.dashboard_state set summary_stale = true, cached_at = null;

  return v_stats || jsonb_build_object(
    'committed', true,
    'visible_people_after', (select count(*) from public.voters v join public.families f on f.id = v.family_id
                             where not f.is_hidden),
    'booths_after', (select count(*) from public.booths),
    'assignments_written', (select count(*) from public.assignments));
end
$$;
revoke execute on function private.apply_final_list(boolean) from public, anon, authenticated;
