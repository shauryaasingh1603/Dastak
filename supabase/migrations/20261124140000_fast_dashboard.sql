-- The admin dashboard was two thirds of all database time: every refresh
-- by every admin recounted all 82,000 listed people.
-- - private.people_summary keeps people per booth, priority and category;
--   triggers mark it stale when voters or households change, and the
--   dashboard recounts only then.
-- - The finished dashboard is cached for 60 seconds and shared by every
--   admin and open tab.
-- Same JSON as before.

create table private.people_summary (
  part_no  int not null,
  priority smallint not null,
  category text not null,
  people   int not null,
  primary key (part_no, priority, category)
);

create table private.dashboard_state (
  id            boolean primary key default true check (id),
  summary_stale boolean not null default true,
  cached        jsonb,
  cached_at     timestamptz
);
insert into private.dashboard_state default values;

create function private.mark_people_summary_stale() returns trigger
language plpgsql security definer set search_path = ''
as $$
begin
  update private.dashboard_state set summary_stale = true where not summary_stale;
  return null;
end
$$;

create trigger voters_people_summary after insert or delete or update of category, family_id
  on public.voters for each statement execute function private.mark_people_summary_stale();
create trigger families_people_summary after insert or delete or update of part_no, priority, is_hidden
  on public.families for each statement execute function private.mark_people_summary_stale();

create or replace function public.admin_dashboard() returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_today    date := private.today();
  v_settings public.campaign_settings;
  v_from     date;
  v_result   jsonb;
  v_state    private.dashboard_state;
begin
  if not private.is_admin() then
    raise exception 'NOT_AUTHORIZED' using errcode = '42501';
  end if;

  -- Every admin and open tab shares one answer, at most a minute old.
  select * into v_state from private.dashboard_state;
  if v_state.cached_at > now() - interval '60 seconds' then
    return v_state.cached;
  end if;

  -- People per booth, priority and category change only when the list
  -- does (imports, voters added in the field): recount them only then.
  if v_state.summary_stale then
    delete from private.people_summary where true; -- API requests need a WHERE (safeupdate)
    insert into private.people_summary (part_no, priority, category, people)
    select f.part_no, f.priority, vo.category, count(*)
    from public.voters vo join public.families f on f.id = vo.family_id
    where not f.is_hidden
    group by 1, 2, 3;
    update private.dashboard_state set summary_stale = false where id;
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
  -- Everyone listed, as counts (see private.people_summary).
  listed as (
    select s.*, s.category not in ('ALREADY_BACK', 'ON_DRAFT_ROLL') as to_visit
    from private.people_summary s
  ),
  -- Only the people visits have covered, with what was found.
  visited as (
    select f.part_no, f.priority, vo.category,
           vo.category not in ('ALREADY_BACK', 'ON_DRAFT_ROLL') as to_visit,
           pl.voter_outcome <> 'NOT_MET' as reached
    from person_latest pl
    join public.voters vo on vo.id = pl.voter_id
    join public.families f on f.id = vo.family_id
    where not f.is_hidden
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
        'people', (select coalesce(sum(people), 0) from listed where to_visit),
        'already_back', (select coalesce(sum(people), 0) from listed where category = 'ALREADY_BACK'),
        'on_draft_roll', (select coalesce(sum(people), 0) from listed where category = 'ON_DRAFT_ROLL'),
        'attempted', (select count(*) from visited where to_visit),
        'reached', (select count(*) from visited where to_visit and reached),
        'visits', (select count(*) from live_visits),
        'visits_today', (select count(*) from live_visits where day = v_today),
        'people_today', (select count(distinct voter_id) from visit_people where day = v_today),
        'people_met_today', (select count(distinct voter_id) from visit_people
                             where day = v_today and voter_outcome <> 'NOT_MET'),
        'new_voters', (select coalesce(sum(people), 0) from listed where category = 'NEW'),
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
      from (select l.priority, sum(l.people) n,
                   (select count(*) from visited v where v.to_visit and v.priority = l.priority) a,
                   (select count(*) from visited v where v.to_visit and v.reached and v.priority = l.priority) r
            from listed l where l.to_visit group by 1) t
    ),

    'by_category', (
      select coalesce(jsonb_agg(jsonb_build_object(
        'category', category, 'people', n, 'attempted', a, 'reached', r) order by n desc), '[]')
      from (select l.category, sum(l.people) n,
                   (select count(*) from visited v where v.category = l.category) a,
                   (select count(*) from visited v where v.reached and v.category = l.category) r
            from listed l group by 1) t
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
      left join (select l.part_no, sum(l.people) n,
                        coalesce(max(v.a), 0) a, coalesce(max(v.r), 0) r,
                        sum(l.people) filter (where l.priority = 1) - coalesce(max(v.r1), 0) p1_left
                 from listed l
                 left join (select part_no, count(*) a, count(*) filter (where reached) r,
                                   count(*) filter (where reached and priority = 1) r1
                            from visited where to_visit group by 1) v on v.part_no = l.part_no
                 where l.to_visit
                 group by l.part_no) p on p.part_no = b.part_no
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

  update private.dashboard_state set cached = v_result, cached_at = now() where id;
  return v_result;
end
$$;

revoke all on function public.admin_dashboard() from public, anon;
grant execute on function public.admin_dashboard() to authenticated;
