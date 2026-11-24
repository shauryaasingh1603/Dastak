-- Version 2 of the visit list, re-checked against the draft roll published
-- on 17 Nov 2026 (tools/import/update_v2.py):
-- - ON_DRAFT_ROLL: people found on the draft roll again. No visit needed;
--   closest_2026 holds the draft entry they matched, to check.
-- - draft_part / draft_section: where the person is (or would be) on the
--   2027 draft roll.
-- - import_people takes the draft fields; import_voter_updates changes
--   people already loaded, by record code. Both need a one-time token.
-- - Phones receive the draft fields; the dashboard leaves ON_DRAFT_ROLL
--   people out of the to-visit totals.

alter table public.voters
  add column draft_part int,
  add column draft_section text;

alter table public.voters drop constraint voters_category_check;
alter table public.voters add constraint voters_category_check
  check (category in ('UNTRACEABLE', 'SHIFTED', 'DECEASED', 'DUPLICATE', 'ALREADY_BACK',
                      'POSS_HIGH', 'POSS_MEDIUM', 'POSS_LOW', 'NEW', 'ON_DRAFT_ROLL'));

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
      category text, closest text, on_roll boolean, draft_part int, draft_section text)
  ), fam as (
    insert into public.families (code, part_no, house_no, head_name_hi, priority, needs_review)
    select code, part, house, name, priority, review or epic_taken from input
    on conflict (code) do nothing
    returning id, code
  )
  insert into public.voters (family_id, epic, roll_ref, name_hi, relation_type, relative_name_hi, age, gender,
                             source_list, asdd_reason, old_part_no, old_serial, likely_new_part, match_confidence,
                             category, closest_2026, already_on_roll, draft_part, draft_section)
  select fam.id, case when i.epic_taken then null else i.epic end,
         case when i.ref_taken then null else i.roll_ref end,
         i.name, i.relation, i.relative, i.age, i.gender,
         i.source, i.asdd_reason, i.old_part, i.old_serial, i.likely_part, i.confidence,
         i.category, nullif(i.closest, ''), coalesce(i.on_roll, false), i.draft_part, nullif(i.draft_section, '')
  from input i join fam using (code);
  get diagnostics v_count = row_count;
  return v_count;
end
$$;

-- Changes to people already loaded, by record code. Fields left out keep
-- their value; set_closest replaces the entry to check (null clears it).
create function public.import_voter_updates(p_token text, p_rows jsonb) returns int
language plpgsql security definer set search_path = ''
as $$
declare
  v_count int;
begin
  if not private.import_allowed(p_token) then
    raise exception 'IMPORT_NOT_ALLOWED' using errcode = '42501';
  end if;
  with input as (
    select x.*, f.id as family_id
    from jsonb_to_recordset(p_rows) as x(code text, category text, priority int, confidence text,
                                         closest text, set_closest boolean, draft_part int, draft_section text)
    join public.families f on f.code = x.code
  ), voters_changed as (
    update public.voters v set
      category = coalesce(i.category, v.category),
      match_confidence = coalesce(i.confidence, v.match_confidence),
      closest_2026 = case when coalesce(i.set_closest, false) then nullif(i.closest, '') else v.closest_2026 end,
      draft_part = coalesce(i.draft_part, v.draft_part),
      draft_section = coalesce(nullif(i.draft_section, ''), v.draft_section)
    from input i
    where v.family_id = i.family_id and v.source_list <> 'NEW'
    returning 1
  ), families_changed as (
    update public.families f set priority = i.priority
    from input i
    where f.id = i.family_id and i.priority is not null and f.priority <> i.priority
    returning 1
  )
  select count(*) into v_count from voters_changed;
  return v_count;
end
$$;

revoke execute on function public.import_people(text, jsonb), public.import_voter_updates(text, jsonb)
  from public, anon, authenticated;

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
                  'new_reason', new_reason, 'new_reason_note', new_reason_note,
                  'draft_part', draft_part, 'draft_section', draft_section)) from vot), '[]'),
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

create or replace function public.admin_dashboard() returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_today    date := private.today();
  v_settings public.campaign_settings;
  v_from     date;
  v_result   jsonb;
begin
  if not private.is_admin() then
    raise exception 'NOT_AUTHORIZED' using errcode = '42501';
  end if;
  select * into v_settings from public.campaign_settings;
  v_from := least(v_settings.visits_open_from, v_today);

  with
  live_visits as (
    select v.*, (v.visited_at at time zone 'Asia/Kolkata')::date as day
    from public.visits v
    where not exists (select 1 from public.visits s where s.supersedes = v.id)
  ),
  -- The latest word on each person who has been covered by a visit.
  person_latest as (
    select distinct on (vv.voter_id)
      vv.voter_id, vv.voter_outcome, lv.day, lv.user_id
    from public.visit_voters vv
    join live_visits lv on lv.id = vv.visit_id
    order by vv.voter_id, lv.visited_at desc
  ),
  people as (
    select vo.id, f.part_no, f.priority, vo.source_list,
           pl.voter_outcome, (pl.voter_id is not null) as attempted,
           coalesce(pl.voter_outcome <> 'NOT_MET', false) as reached
    from public.voters vo
    join public.families f on f.id = vo.family_id
    left join person_latest pl on pl.voter_id = vo.id
    where not f.is_hidden and vo.category not in ('ALREADY_BACK', 'ON_DRAFT_ROLL')
  ),
  -- People covered per visit (for "people visited per day").
  visit_people as (
    select lv.id as visit_id, lv.user_id, lv.day, vv.voter_id, vv.voter_outcome
    from live_visits lv
    join public.visit_voters vv on vv.visit_id = lv.id
  ),
  submitted as (
    select fe.form_id, min((fe.changed_at at time zone 'Asia/Kolkata')::date) as day
    from public.form_events fe
    where fe.status = 'SUBMITTED'
    group by fe.form_id
  ),
  field_users as (
    select u.* from public.users u where u.role in ('volunteer', 'bla2')
  ),
  active_assignments as (
    select a.user_id, a.part_no
    from public.assignments a
    where a.from_date <= v_today and (a.to_date is null or a.to_date >= v_today)
  ),
  -- Families whose latest visit found nobody, with a revisit date.
  revisits as (
    select distinct on (lv.family_id) lv.family_id, lv.outcome, lv.revisit_on
    from live_visits lv
    order by lv.family_id, lv.visited_at desc
  )
  select jsonb_build_object(
    'generated_at', now(),
    'today', v_today,
    'settings', jsonb_build_object(
      'visits_open_from', v_settings.visits_open_from,
      'claims_close_at', v_settings.claims_close_at,
      'status_close_at', v_settings.status_close_at,
      'daily_people_target', v_settings.daily_people_target
    ),

    'totals', (
      select jsonb_build_object(
        'people', count(*),
        'already_back', (select count(*) from public.voters where category = 'ALREADY_BACK'),
        'on_draft_roll', (select count(*) from public.voters where category = 'ON_DRAFT_ROLL'),
        'attempted', count(*) filter (where attempted),
        'reached', count(*) filter (where reached),
        'visits', (select count(*) from live_visits),
        'visits_today', (select count(*) from live_visits where day = v_today),
        'people_today', (select count(distinct voter_id) from visit_people where day = v_today),
        'new_voters', (select count(*) from public.voters where source_list = 'NEW'),
        'contacts_given', (select count(*) from live_visits where contact_mobile is not null),
        'contacts_refused', (select count(*) from live_visits where contact_refused),
        'member_mobiles', (select count(*) from public.visit_voters vv
                           join live_visits lv on lv.id = vv.visit_id
                           where vv.mobile is not null),
        'revisits_due_today', (select count(*) from revisits where outcome = 'NOT_MET' and revisit_on = v_today),
        'revisits_overdue', (select count(*) from revisits where outcome = 'NOT_MET' and revisit_on < v_today),
        'field_users', (select count(*) from field_users where is_active),
        'signed_in', (select count(*) from field_users where is_active and active_session_id is not null),
        'active_today', (select count(distinct user_id) from live_visits where day = v_today),
        'pending_sign_ins', (select count(*) from public.login_requests
                             where status = 'pending' and created_at > now() - interval '24 hours')
      )
      from people
    ),

    'forms', (
      select jsonb_build_object(
        'by_type', coalesce((select jsonb_object_agg(form_type, n)
                             from (select form_type, count(*) n from public.forms group by 1) t), '{}'),
        'by_status', coalesce((select jsonb_object_agg(current_status, n)
                               from (select current_status, count(*) n from public.forms group by 1) t), '{}'),
        'by_route', coalesce((select jsonb_object_agg(coalesce(route, 'NONE'), n)
                              from (select route, count(*) n from public.forms group by 1) t), '{}')
      )
    ),

    'daily', (
      select coalesce(jsonb_agg(jsonb_build_object(
        'day', d.day,
        'people', (select count(distinct voter_id) from visit_people vp where vp.day = d.day),
        'visits', (select count(*) from live_visits lv where lv.day = d.day),
        'volunteers', (select count(distinct user_id) from live_visits lv where lv.day = d.day),
        'form6', (select count(*) from public.forms fo
                  where fo.form_type = '6' and (fo.created_at at time zone 'Asia/Kolkata')::date = d.day),
        'form8', (select count(*) from public.forms fo
                  where fo.form_type = '8' and (fo.created_at at time zone 'Asia/Kolkata')::date = d.day),
        'form7', (select count(*) from public.forms fo
                  where fo.form_type = '7' and (fo.created_at at time zone 'Asia/Kolkata')::date = d.day),
        'submitted', (select count(*) from submitted s where s.day = d.day)
      ) order by d.day), '[]')
      from (select generate_series(v_from, v_today, interval '1 day')::date as day) d
    ),

    'outcomes', (
      select coalesce(jsonb_object_agg(voter_outcome, n), '{}')
      from (select voter_outcome, count(*) n from person_latest group by 1) t
    ),

    'by_priority', (
      select coalesce(jsonb_agg(jsonb_build_object(
        'priority', priority, 'people', n, 'attempted', a, 'reached', r) order by priority), '[]')
      from (select priority, count(*) n, count(*) filter (where attempted) a,
                   count(*) filter (where reached) r
            from people group by 1) t
    ),

    'by_category', (
      select coalesce(jsonb_agg(jsonb_build_object(
        'category', category, 'people', n, 'attempted', a, 'reached', r) order by n desc), '[]')
      from (select vo.category, count(*) n, count(pl.voter_id) a,
                   count(*) filter (where pl.voter_outcome <> 'NOT_MET') r
            from public.voters vo
            join public.families f on f.id = vo.family_id and not f.is_hidden
            left join person_latest pl on pl.voter_id = vo.id
            group by 1) t
    ),

    'flags', (
      select coalesce(jsonb_object_agg(flag, n), '{}')
      from (select unnest(flags) as flag, count(*) n from live_visits group by 1) t
    ),

    'booths', (
      select coalesce(jsonb_agg(jsonb_build_object(
        'part_no', b.part_no,
        'name', b.name_hi,
        'people', coalesce(p.n, 0),
        'attempted', coalesce(p.a, 0),
        'reached', coalesce(p.r, 0),
        'top_priority_left', coalesce(p.p1_left, 0),
        'forms', coalesce(fm.n, 0),
        'submitted', coalesce(fm.s, 0),
        'visits_today', coalesce(vt.n, 0),
        'last_visit_at', lv.last_at,
        'volunteers', coalesce(ass.names, '[]')
      ) order by b.part_no), '[]')
      from public.booths b
      left join (select part_no, count(*) n, count(*) filter (where attempted) a,
                        count(*) filter (where reached) r,
                        count(*) filter (where priority = 1 and not reached) p1_left
                 from people group by 1) p on p.part_no = b.part_no
      left join (select f.part_no, count(*) n,
                        count(*) filter (where fo.current_status <> 'FILLED') s
                 from public.forms fo
                 join public.voters vo on vo.id = fo.voter_id
                 join public.families f on f.id = vo.family_id
                 group by 1) fm on fm.part_no = b.part_no
      left join (select f.part_no, count(*) n
                 from live_visits v join public.families f on f.id = v.family_id
                 where v.day = v_today group by 1) vt on vt.part_no = b.part_no
      left join (select f.part_no, max(v.visited_at) last_at
                 from live_visits v join public.families f on f.id = v.family_id
                 group by 1) lv on lv.part_no = b.part_no
      left join (select aa.part_no, jsonb_agg(u.name order by u.name) names
                 from active_assignments aa join field_users u on u.id = aa.user_id and u.is_active
                 group by 1) ass on ass.part_no = b.part_no
    ),

    'volunteers', (
      select coalesce(jsonb_agg(jsonb_build_object(
        'id', u.id,
        'name', u.name,
        'role', u.role,
        'is_active', u.is_active,
        'signed_in', u.active_session_id is not null,
        'last_login_at', u.last_login_at,
        'booths', coalesce((select jsonb_agg(aa.part_no order by aa.part_no)
                            from active_assignments aa where aa.user_id = u.id), '[]'),
        'people_today', (select count(distinct voter_id) from visit_people vp
                         where vp.user_id = u.id and vp.day = v_today),
        'people_total', (select count(distinct voter_id) from visit_people vp where vp.user_id = u.id),
        'visits_total', (select count(*) from live_visits lv where lv.user_id = u.id),
        'days_worked', (select count(distinct day) from live_visits lv where lv.user_id = u.id),
        'forms', (select count(*) from public.forms fo where fo.filed_by_user_id = u.id),
        'submitted', (select count(*) from public.forms fo
                      where fo.filed_by_user_id = u.id and fo.current_status <> 'FILLED'),
        'flagged_visits', (select count(*) from live_visits lv
                           where lv.user_id = u.id and cardinality(lv.flags) > 0),
        'last_visit_at', (select max(visited_at) from live_visits lv where lv.user_id = u.id),
        'last_received_at', (select max(received_at) from live_visits lv where lv.user_id = u.id)
      ) order by u.name), '[]')
      from field_users u
    ),

    'recent', (
      select coalesce(jsonb_agg(r order by r ->> 'visited_at' desc), '[]')
      from (
        select jsonb_build_object(
          'id', lv.id,
          'visited_at', lv.visited_at,
          'received_at', lv.received_at,
          'volunteer', u.name,
          'part_no', f.part_no,
          'outcome', lv.outcome,
          'people', (select count(*) from public.visit_voters vv where vv.visit_id = lv.id),
          'flags', to_jsonb(lv.flags),
          'gps', lv.gps_lat is not null,
          'contact', case when lv.contact_mobile is not null then 'GIVEN'
                          when lv.contact_refused then 'REFUSED' else null end
        ) as r
        from live_visits lv
        join public.users u on u.id = lv.user_id
        join public.families f on f.id = lv.family_id
        order by lv.visited_at desc
        limit 30
      ) t
    )
  ) into v_result;

  return v_result;
end
$$;

revoke all on function public.admin_dashboard() from public, anon;
grant execute on function public.admin_dashboard() to authenticated;
