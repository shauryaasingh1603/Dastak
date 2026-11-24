-- Quality flags: patterns in a volunteer's work that suggest shortcuts or
-- made-up data, raised for an admin to look into.
--
-- The checks run for a volunteer each time their phone sends work (and when
-- an ECI screenshot has been read), so a flag reaches the admin site within
-- moments. An admin marks each flag "fine" (OK) or "a problem" (PROBLEM),
-- with a note. A flag marked fine opens again if more of the same turns up.
--
-- What is checked (HIGH / MEDIUM / LOW):
--   SAME_MOBILE         HIGH    one phone number recorded for 3+ households
--   OWN_NUMBER          HIGH    the volunteer's own number recorded for voters
--   TEAM_NUMBER         MEDIUM  another team member's number recorded
--   DUPLICATE_NEW_VOTER HIGH    the same new voter added twice
--   ECI_REF_REUSED      HIGH    one ECI reference number on more than one form
--   SCREENSHOT_REUSED   HIGH    the same screenshot file on more than one form
--   PHOTO_REUSED        HIGH    the same face photo on more than one form
--   ECI_NOT_ECI         MEDIUM  the "screenshot" is not an ECI application
--   ECI_NAME_MISMATCH   MEDIUM  the name on the screenshot is someone else
--   ECI_OTHER_AC        MEDIUM  the application is for another constituency
--   ECI_UNREADABLE      LOW     the screenshot could not be read
--   ONE_SPOT            MEDIUM  10+ households in a day recorded from one spot
--   TOO_FAST            MEDIUM  8+ households within 5 minutes
--   FAR_FROM_BOOTH      MEDIUM  visits 2+ km from where the booth's visits are
--   NO_LOCATION         LOW     3+ visits in a day without a location
--   ODD_HOURS           LOW     2+ visits in a day between 9 pm and 7 am
--   MOSTLY_NOT_MET      LOW     15+ visits in a day, 90%+ "nobody met"
--   NUMBERS_DECLINED    LOW     10+ people met in a week, 80%+ without a number
--   REPEATED_TEXT       LOW     the same remark written for 5+ households

create table public.quality_flags (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.users (id),
  kind        text not null,
  severity    text not null check (severity in ('HIGH', 'MEDIUM', 'LOW')),
  dedupe_key  text not null unique,
  count       int not null default 1,
  summary     text not null,
  detail      jsonb not null default '{}',
  status      text not null default 'OPEN' check (status in ('OPEN', 'OK', 'PROBLEM')),
  note        text,
  reviewed_by uuid references public.users (id),
  reviewed_at timestamptz,
  first_seen  timestamptz not null default now(),
  last_seen   timestamptz not null default now()
);
create index quality_flags_status on public.quality_flags (status, severity);
create index quality_flags_user on public.quality_flags (user_id);
alter table public.quality_flags enable row level security;
revoke all on public.quality_flags from anon, authenticated;
create index if not exists voters_created_by_idx on public.voters (created_by) where created_by is not null;
create index if not exists forms_filed_by_idx on public.forms (filed_by_user_id);

-- Helpers ---------------------------------------------------------------------

-- The last ten digits of a phone number, or null.
create function private.norm_mobile(p text) returns text
language sql immutable set search_path = ''
as $$
  select case when length(d) >= 10 then right(d, 10) end
  from (select regexp_replace(coalesce(p, ''), '\D', '', 'g') d) x
$$;

-- Distance in metres between two points.
create function private.metres(lat1 float8, lng1 float8, lat2 float8, lng2 float8) returns float8
language sql immutable set search_path = ''
as $$
  select 6371000 * 2 * asin(sqrt(
    power(sin(radians(lat2 - lat1) / 2), 2) +
    cos(radians(lat1)) * cos(radians(lat2)) * power(sin(radians(lng2 - lng1) / 2), 2)))
$$;

-- The people with these ids, for showing on a flag.
create function private.flag_people(p_ids uuid[]) returns jsonb
language sql stable security definer set search_path = ''
as $$
  select coalesce(jsonb_agg(jsonb_build_object('id', v.id, 'name', v.name_hi, 'part_no', f.part_no,
                                               'house_no', f.house_no) order by f.part_no, v.name_hi), '[]')
  from (select v.* from public.voters v where v.id = any (p_ids) limit 40) v
  join public.families f on f.id = v.family_id
$$;

-- Every phone number a volunteer recorded, with the household and person.
create function private.user_numbers(p_user uuid)
returns table (mobile text, family_id uuid, voter_id uuid)
language sql stable security definer set search_path = ''
as $$
  select private.norm_mobile(vv.mobile), vi.family_id, vv.voter_id
  from public.visits vi join public.visit_voters vv on vv.visit_id = vi.id
  where vi.user_id = p_user and vv.mobile is not null
  union all
  select private.norm_mobile(vi.contact_mobile), vi.family_id, vv.voter_id
  from public.visits vi join public.visit_voters vv on vv.visit_id = vi.id
  where vi.user_id = p_user and vi.contact_mobile is not null
  union all
  select private.norm_mobile(v.mobile), v.family_id, v.id
  from public.voters v
  where v.created_by = p_user and v.mobile is not null
$$;

-- Records a flag, or updates it with the latest evidence. A flag an admin
-- marked fine opens again when more of the same turns up.
create function private.raise_flag(p_user uuid, p_kind text, p_severity text, p_key text,
                                   p_count int, p_summary text, p_detail jsonb) returns void
language sql security definer set search_path = ''
as $$
  insert into public.quality_flags as q (user_id, kind, severity, dedupe_key, count, summary, detail)
  values (p_user, p_kind, p_severity, p_key, p_count, p_summary, p_detail)
  on conflict (dedupe_key) do update set
    count = excluded.count, summary = excluded.summary, detail = excluded.detail,
    last_seen = case when excluded.count > q.count then now() else q.last_seen end,
    status = case when q.status = 'OK' and excluded.count > q.count then 'OPEN' else q.status end
  where q.count is distinct from excluded.count or q.detail is distinct from excluded.detail
$$;

-- The checks --------------------------------------------------------------------

create function private.scan_quality(p_user uuid) returns void
language plpgsql security definer set search_path = ''
as $$
declare
  r      record;
  v_from timestamptz := now() - interval '7 days';
begin
  -- Phone numbers ---------------------------------------------------------------
  for r in
    select n.mobile, count(distinct n.family_id) households, array_agg(distinct n.voter_id) voters
    from private.user_numbers(p_user) n
    where n.mobile is not null
    group by n.mobile having count(distinct n.family_id) >= 3
  loop
    perform private.raise_flag(p_user, 'SAME_MOBILE', 'HIGH', 'SAME_MOBILE:' || p_user || ':' || r.mobile,
      r.households::int,
      format('The same phone number %s was recorded for %s different households.', r.mobile, r.households),
      jsonb_build_object('mobile', r.mobile, 'people', private.flag_people(r.voters)));
  end loop;

  for r in
    select n.mobile, u.id team_id, u.name team_name, count(distinct n.family_id) households,
           array_agg(distinct n.voter_id) voters
    from private.user_numbers(p_user) n
    join public.users u on private.norm_mobile(u.mobile) = n.mobile
    group by n.mobile, u.id, u.name
  loop
    if r.team_id = p_user then
      perform private.raise_flag(p_user, 'OWN_NUMBER', 'HIGH', 'OWN_NUMBER:' || p_user || ':' || r.mobile,
        r.households::int,
        format('The volunteer''s own phone number was recorded for %s household(s).', r.households),
        jsonb_build_object('mobile', r.mobile, 'people', private.flag_people(r.voters)));
    else
      perform private.raise_flag(p_user, 'TEAM_NUMBER', 'MEDIUM', 'TEAM_NUMBER:' || p_user || ':' || r.mobile,
        r.households::int,
        format('The phone number of team member %s was recorded for %s household(s).', r.team_name, r.households),
        jsonb_build_object('mobile', r.mobile, 'team_member', r.team_name, 'people', private.flag_people(r.voters)));
    end if;
  end loop;

  -- New voters added twice --------------------------------------------------------
  for r in
    select lower(trim(v.name_hi)) nm, lower(trim(coalesce(v.relative_name_hi, ''))) rel,
           count(*) n, array_agg(v.id) voters
    from public.voters v
    where v.created_by = p_user
    group by 1, 2 having count(*) >= 2
  loop
    perform private.raise_flag(p_user, 'DUPLICATE_NEW_VOTER', 'HIGH',
      'DUPLICATE_NEW_VOTER:' || p_user || ':' || md5(r.nm || '|' || r.rel), r.n::int,
      format('The same new voter was added %s times.', r.n),
      jsonb_build_object('people', private.flag_people(r.voters)));
  end loop;

  -- ECI screenshots -----------------------------------------------------------------
  for r in
    select fo.id, fo.voter_id, fo.eci_status, fo.eci_name, fo.eci_name_matches, fo.eci_ac, vo.name_hi
    from public.forms fo join public.voters vo on vo.id = fo.voter_id
    where fo.filed_by_user_id = p_user and fo.eci_status in ('READ', 'FAILED', 'NOT_ECI')
  loop
    if r.eci_status = 'NOT_ECI' then
      perform private.raise_flag(p_user, 'ECI_NOT_ECI', 'MEDIUM', 'ECI_NOT_ECI:' || r.id, 1,
        'The image added as the ECI screenshot is not an ECI application.',
        jsonb_build_object('form_id', r.id, 'people', private.flag_people(array[r.voter_id])));
    elsif r.eci_status = 'FAILED' then
      perform private.raise_flag(p_user, 'ECI_UNREADABLE', 'LOW', 'ECI_UNREADABLE:' || r.id, 1,
        'The ECI screenshot could not be read; check it by hand.',
        jsonb_build_object('form_id', r.id, 'people', private.flag_people(array[r.voter_id])));
    end if;
    if r.eci_name_matches = false then
      perform private.raise_flag(p_user, 'ECI_NAME_MISMATCH', 'MEDIUM', 'ECI_NAME_MISMATCH:' || r.id, 1,
        format('The ECI screenshot is for "%s", which does not look like %s.', r.eci_name, r.name_hi),
        jsonb_build_object('form_id', r.id, 'eci_name', r.eci_name, 'people', private.flag_people(array[r.voter_id])));
    end if;
    if r.eci_ac is not null and r.eci_ac !~* '(zafrabad|371)' then
      perform private.raise_flag(p_user, 'ECI_OTHER_AC', 'MEDIUM', 'ECI_OTHER_AC:' || r.id, 1,
        format('The ECI application is for constituency "%s", not 371 Zafrabad.', r.eci_ac),
        jsonb_build_object('form_id', r.id, 'ac', r.eci_ac, 'people', private.flag_people(array[r.voter_id])));
    end if;
  end loop;

  -- One reference number on several forms.
  for r in
    select x.ref, count(*) n, array_agg(x.voter_id) voters, array_agg(distinct u.name) filers
    from (select fo.id, fo.voter_id, fo.filed_by_user_id, coalesce(fo.eci_reference_no, fo.reference_no) ref
          from public.forms fo) x
    join public.users u on u.id = x.filed_by_user_id
    where x.ref in (select coalesce(eci_reference_no, reference_no) from public.forms
                    where filed_by_user_id = p_user)
    group by x.ref having count(*) >= 2
  loop
    perform private.raise_flag(p_user, 'ECI_REF_REUSED', 'HIGH', 'ECI_REF_REUSED:' || r.ref, r.n::int,
      format('ECI reference number %s is on %s forms.', r.ref, r.n),
      jsonb_build_object('reference', r.ref, 'volunteers', to_jsonb(r.filers),
                         'people', private.flag_people(r.voters)));
  end loop;

  -- The same image file on several forms (same contents, same checksum).
  for r in
    select o.metadata ->> 'eTag' etag, (o.name like '%-eci.jpg') eci, count(*) n,
           array_agg(fo.voter_id) voters
    from storage.objects o
    join public.forms fo on fo.id::text = split_part(replace(o.name, '-eci.jpg', '.jpg'), '.', 1)
    where o.bucket_id = 'form-photos' and o.metadata ->> 'eTag' is not null
      and o.metadata ->> 'eTag' in (
        select o2.metadata ->> 'eTag' from storage.objects o2
        join public.forms f2 on f2.id::text = split_part(replace(o2.name, '-eci.jpg', '.jpg'), '.', 1)
        where o2.bucket_id = 'form-photos' and f2.filed_by_user_id = p_user)
    group by 1, 2 having count(*) >= 2
  loop
    if r.eci then
      perform private.raise_flag(p_user, 'SCREENSHOT_REUSED', 'HIGH', 'SCREENSHOT_REUSED:' || r.etag, r.n::int,
        format('The same ECI screenshot was added to %s forms.', r.n),
        jsonb_build_object('people', private.flag_people(r.voters)));
    else
      perform private.raise_flag(p_user, 'PHOTO_REUSED', 'HIGH', 'PHOTO_REUSED:' || r.etag, r.n::int,
        format('The same face photo was added to %s forms.', r.n),
        jsonb_build_object('people', private.flag_people(r.voters)));
    end if;
  end loop;

  -- Where and when visits were recorded (the last week) -----------------------------
  -- Many households from one spot: the most households within 20 m of any
  -- one visit that day.
  for r in
    select d, max(n) n from (
      select (a.visited_at at time zone 'Asia/Kolkata')::date d,
             (select count(distinct b.family_id) from public.visits b
              where b.user_id = p_user and b.gps_lat is not null
                and (b.visited_at at time zone 'Asia/Kolkata')::date = (a.visited_at at time zone 'Asia/Kolkata')::date
                and private.metres(a.gps_lat, a.gps_lng, b.gps_lat, b.gps_lng) <= 20) n
      from public.visits a
      where a.user_id = p_user and a.gps_lat is not null and a.visited_at > v_from
    ) x group by d having max(n) >= 10
  loop
    perform private.raise_flag(p_user, 'ONE_SPOT', 'MEDIUM', 'ONE_SPOT:' || p_user || ':' || r.d, r.n::int,
      format('On %s, %s households were recorded from one spot (within 20 m). Check they were visited in person.',
             to_char(r.d, 'DD Mon'), r.n),
      jsonb_build_object('day', r.d));
  end loop;

  -- Too fast: the most households within any 5 minutes that day.
  for r in
    select d, max(n) n from (
      select (a.visited_at at time zone 'Asia/Kolkata')::date d,
             (select count(distinct b.family_id) from public.visits b
              where b.user_id = p_user
                and b.visited_at >= a.visited_at and b.visited_at < a.visited_at + interval '5 minutes') n
      from public.visits a
      where a.user_id = p_user and a.visited_at > v_from
    ) x group by d having max(n) >= 8
  loop
    perform private.raise_flag(p_user, 'TOO_FAST', 'MEDIUM', 'TOO_FAST:' || p_user || ':' || r.d, r.n::int,
      format('On %s, %s households were recorded within 5 minutes.', to_char(r.d, 'DD Mon'), r.n),
      jsonb_build_object('day', r.d));
  end loop;

  -- Far from the booth: more than 2 km from the middle of everyone's visits
  -- in that booth (once a booth has 5 located visits).
  for r in
    with centre as (
      select f.part_no,
             percentile_cont(0.5) within group (order by vi.gps_lat) lat,
             percentile_cont(0.5) within group (order by vi.gps_lng) lng
      from public.visits vi join public.families f on f.id = vi.family_id
      where vi.gps_lat is not null and coalesce(vi.gps_accuracy_m, 0) <= 100
      group by f.part_no having count(*) >= 5
    )
    select (vi.visited_at at time zone 'Asia/Kolkata')::date d, count(*) n,
           round((max(private.metres(vi.gps_lat, vi.gps_lng, c.lat, c.lng)) / 1000.0)::numeric, 1) km,
           array_agg(distinct f.part_no) parts
    from public.visits vi
    join public.families f on f.id = vi.family_id
    join centre c on c.part_no = f.part_no
    where vi.user_id = p_user and vi.visited_at > v_from and vi.gps_lat is not null
      and coalesce(vi.gps_accuracy_m, 0) <= 100
      and private.metres(vi.gps_lat, vi.gps_lng, c.lat, c.lng) > 2000
    group by 1
  loop
    perform private.raise_flag(p_user, 'FAR_FROM_BOOTH', 'MEDIUM', 'FAR_FROM_BOOTH:' || p_user || ':' || r.d, r.n::int,
      format('On %s, %s visit(s) were recorded up to %s km away from the booth''s area.', to_char(r.d, 'DD Mon'), r.n, r.km),
      jsonb_build_object('day', r.d, 'booths', to_jsonb(r.parts)));
  end loop;

  for r in
    select (visited_at at time zone 'Asia/Kolkata')::date d,
           count(*) filter (where gps_lat is null) no_gps,
           count(*) filter (where extract(hour from visited_at at time zone 'Asia/Kolkata') >= 21
                              or extract(hour from visited_at at time zone 'Asia/Kolkata') < 7) late,
           count(*) total,
           count(*) filter (where outcome = 'NOT_MET') not_met
    from public.visits
    where user_id = p_user and visited_at > v_from
    group by 1
  loop
    if r.no_gps >= 3 then
      perform private.raise_flag(p_user, 'NO_LOCATION', 'LOW', 'NO_LOCATION:' || p_user || ':' || r.d, r.no_gps::int,
        format('On %s, %s visits were saved without a location.', to_char(r.d, 'DD Mon'), r.no_gps),
        jsonb_build_object('day', r.d));
    end if;
    if r.late >= 2 then
      perform private.raise_flag(p_user, 'ODD_HOURS', 'LOW', 'ODD_HOURS:' || p_user || ':' || r.d, r.late::int,
        format('On %s, %s visits were recorded between 9 pm and 7 am.', to_char(r.d, 'DD Mon'), r.late),
        jsonb_build_object('day', r.d));
    end if;
    if r.total >= 15 and r.not_met >= 0.9 * r.total then
      perform private.raise_flag(p_user, 'MOSTLY_NOT_MET', 'LOW', 'MOSTLY_NOT_MET:' || p_user || ':' || r.d, r.total::int,
        format('On %s, %s of %s visits were "nobody met".', to_char(r.d, 'DD Mon'), r.not_met, r.total),
        jsonb_build_object('day', r.d));
    end if;
  end loop;

  -- Numbers declined: people met in the last week with no number taken.
  for r in
    select count(*) met,
           count(*) filter (where vi.contact_mobile is null
                              and not exists (select 1 from public.visit_voters vv
                                              where vv.visit_id = vi.id and vv.mobile is not null)) no_number
    from public.visits vi
    where vi.user_id = p_user and vi.visited_at > v_from and vi.outcome <> 'NOT_MET'
  loop
    if r.met >= 10 and r.no_number >= 0.8 * r.met then
      perform private.raise_flag(p_user, 'NUMBERS_DECLINED', 'LOW',
        'NUMBERS_DECLINED:' || p_user || ':' || to_char(private.today(), 'IYYY-IW'), r.no_number::int,
        format('This week %s of %s people met gave no phone number.', r.no_number, r.met),
        jsonb_build_object('met', r.met, 'no_number', r.no_number));
    end if;
  end loop;

  -- The same remark copied across households.
  for r in
    select lower(trim(remarks)) t, count(distinct family_id) n
    from public.visits
    where user_id = p_user and length(trim(coalesce(remarks, ''))) >= 3
    group by 1 having count(distinct family_id) >= 5
  loop
    perform private.raise_flag(p_user, 'REPEATED_TEXT', 'LOW', 'REPEATED_TEXT:' || p_user || ':' || md5(r.t), r.n::int,
      format('The same remark "%s" was written for %s households.', left(r.t, 80), r.n),
      jsonb_build_object('text', left(r.t, 200)));
  end loop;
end
$$;

-- Run the checks after each sync and after a screenshot is read. A failing
-- check never stops the volunteer's work from being saved.
create function private.scan_quality_safely(p_user uuid) returns void
language plpgsql security definer set search_path = ''
as $$
begin
  perform private.scan_quality(p_user);
exception when others then
  raise warning 'scan_quality failed for %: %', p_user, sqlerrm;
end
$$;

do $do$
declare
  d text := pg_get_functiondef('public.sync_push(jsonb, timestamptz)'::regprocedure);
  a text := $q$  return jsonb_build_object('server_time', now(), 'results', v_results);$q$;
begin
  if position(a in d) = 0 then raise exception 'sync_push: expected text not found'; end if;
  execute replace(d, a, $q$  perform private.scan_quality_safely(v_me.id);
$q$ || a);

  d := pg_get_functiondef('public.eci_record(uuid, jsonb)'::regprocedure);
  a := $q$  return jsonb_build_object('ok', true);$q$;
  if position(a in d) = 0 then raise exception 'eci_record: expected text not found'; end if;
  execute replace(d, a, $q$  perform private.scan_quality_safely(v_form.filed_by_user_id);
$q$ || a);
end
$do$;

-- Admin site ------------------------------------------------------------------------

-- Flags with a given status ('OPEN', 'OK', 'PROBLEM' or 'ALL'), most serious
-- first, and a count per volunteer.
create function public.admin_flags(p_status text default 'OPEN') returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'NOT_AUTHORIZED' using errcode = '42501';
  end if;
  return jsonb_build_object(
    'flags', coalesce((
      select jsonb_agg(jsonb_build_object(
               'id', q.id, 'user_id', q.user_id, 'volunteer', u.name, 'volunteer_mobile', u.mobile,
               'kind', q.kind, 'severity', q.severity, 'count', q.count, 'summary', q.summary,
               'detail', q.detail, 'status', q.status, 'note', q.note, 'reviewed_by', r.name,
               'reviewed_at', q.reviewed_at, 'first_seen', q.first_seen, 'last_seen', q.last_seen)
             order by case q.severity when 'HIGH' then 0 when 'MEDIUM' then 1 else 2 end, q.last_seen desc)
      from public.quality_flags q
      join public.users u on u.id = q.user_id
      left join public.users r on r.id = q.reviewed_by
      where p_status = 'ALL' or q.status = p_status), '[]'),
    'volunteers', coalesce((
      select jsonb_agg(x order by x.high desc, x.open desc, x.name)
      from (select u.id user_id, u.name,
                   count(*) filter (where q.status = 'OPEN') open,
                   count(*) filter (where q.status = 'OPEN' and q.severity = 'HIGH') high,
                   count(*) filter (where q.status = 'PROBLEM') problem,
                   count(*) filter (where q.status = 'OK') ok
            from public.quality_flags q join public.users u on u.id = q.user_id
            group by u.id, u.name) x), '[]'));
end
$$;

create function public.admin_open_flags() returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'NOT_AUTHORIZED' using errcode = '42501';
  end if;
  return (select jsonb_build_object('open', count(*), 'high', count(*) filter (where severity = 'HIGH'))
          from public.quality_flags where status = 'OPEN');
end
$$;

create function public.admin_review_flag(p_flag uuid, p_status text, p_note text default null) returns void
language plpgsql security definer set search_path = ''
as $$
begin
  if not private.is_admin() then
    raise exception 'NOT_AUTHORIZED' using errcode = '42501';
  end if;
  if p_status not in ('OPEN', 'OK', 'PROBLEM') then
    raise exception 'BAD_STATUS' using errcode = '22023';
  end if;
  update public.quality_flags
  set status = p_status, note = left(nullif(trim(p_note), ''), 1000),
      reviewed_by = case when p_status = 'OPEN' then null else private.current_user_id() end,
      reviewed_at = case when p_status = 'OPEN' then null else now() end
  where id = p_flag;
end
$$;

-- Runs every check for every field volunteer now.
create function public.admin_scan_quality() returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  u record;
begin
  if not private.is_admin() then
    raise exception 'NOT_AUTHORIZED' using errcode = '42501';
  end if;
  for u in select id from public.users where role in ('volunteer', 'bla2') loop
    perform private.scan_quality_safely(u.id);
  end loop;
  return public.admin_open_flags();
end
$$;

revoke all on function private.scan_quality(uuid), private.scan_quality_safely(uuid), private.raise_flag(uuid, text, text, text, int, text, jsonb),
  private.user_numbers(uuid), private.flag_people(uuid[]) from public, anon, authenticated;
revoke all on function public.admin_flags(text), public.admin_open_flags(), public.admin_review_flag(uuid, text, text),
  public.admin_scan_quality() from public, anon;
grant execute on function public.admin_flags(text), public.admin_open_flags(), public.admin_review_flag(uuid, text, text),
  public.admin_scan_quality() to authenticated;
