-- The app now takes a fresh, full-accuracy GPS fix when a visit is saved, and
-- only once precise location is allowed. A visit saved when no fix came in
-- time is flagged GPS_TIMEOUT (distinct from GPS_OFF, location switched off).

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
