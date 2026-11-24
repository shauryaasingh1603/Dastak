-- Admin website: one person's full record, one volunteer's work over a
-- period, and filtered exports. Admins only; read-only.

-- Everything about one person: details, booth and house, every visit that
-- covered them (who, when, where, contact, phones, docs, notes), their
-- forms with history and photo, and the household seen with them.
create function public.admin_person(p_voter uuid) returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_result jsonb;
begin
  if not private.is_admin() then
    raise exception 'NOT_AUTHORIZED' using errcode = '42501';
  end if;

  select jsonb_build_object(
    'voter', jsonb_build_object(
      'id', vo.id, 'name', vo.name_hi, 'relation', vo.relation_type, 'relative', vo.relative_name_hi,
      'age', vo.age, 'gender', vo.gender, 'epic', vo.epic, 'category', vo.category,
      'source', vo.source_list, 'confidence', vo.match_confidence, 'closest', vo.closest_2026,
      'draft_part', vo.draft_part, 'draft_section', vo.draft_section,
      'old_part', vo.old_part_no, 'old_serial', vo.old_serial,
      'new_reason', vo.new_reason, 'new_reason_note', vo.new_reason_note,
      'mobile', vo.mobile, 'added_by', (select u.name from public.users u where u.id = vo.created_by),
      'added_at', case when vo.source_list = 'NEW' then vo.created_at end),
    'household', jsonb_build_object(
      'code', f.code, 'part_no', f.part_no, 'house_no', f.house_no, 'hidden', f.is_hidden,
      'needs_review', f.needs_review, 'priority', f.priority,
      'polling_station', (select b.polling_station_hi from public.booths b where b.part_no = f.part_no)),
    'visits', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', vi.id, 'visited_at', vi.visited_at, 'received_at', vi.received_at,
        'volunteer', u.name, 'volunteer_mobile', u.mobile,
        'outcome', vv.voter_outcome, 'docs', to_jsonb(vv.docs_seen), 'mobile', vv.mobile,
        'met_person', vi.met_person, 'contact_name', vi.contact_name,
        'contact_relation', vi.contact_relation, 'contact_mobile', vi.contact_mobile,
        'contact_refused', vi.contact_refused, 'remarks', vi.remarks, 'revisit_on', vi.revisit_on,
        'gps_lat', vi.gps_lat, 'gps_lng', vi.gps_lng, 'gps_accuracy_m', vi.gps_accuracy_m,
        'flags', to_jsonb(vi.flags),
        'members', (select jsonb_agg(jsonb_build_object('id', o.id, 'name', o.name_hi, 'outcome', x.voter_outcome)
                                     order by o.name_hi)
                    from public.visit_voters x join public.voters o on o.id = x.voter_id
                    where x.visit_id = vi.id and x.voter_id <> vo.id))
        order by vi.visited_at desc)
      from public.visit_voters vv
      join public.visits vi on vi.id = vv.visit_id
      join public.users u on u.id = vi.user_id
      where vv.voter_id = vo.id), '[]'),
    'forms', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', fo.id, 'type', fo.form_type, 'status', fo.current_status, 'route', fo.route,
        'reference_no', fo.reference_no, 'filed_on', fo.filed_on, 'created_at', fo.created_at,
        'filed_by', (select u.name from public.users u where u.id = fo.filed_by_user_id),
        'photo_path', fo.photo_path, 'photo_at', fo.photo_at,
        'events', (select jsonb_agg(jsonb_build_object(
                     'status', e.status, 'at', e.changed_at, 'note', e.note,
                     'by', (select u.name from public.users u where u.id = e.changed_by)) order by e.changed_at)
                   from public.form_events e where e.form_id = fo.id))
        order by fo.created_at)
      from public.forms fo where fo.voter_id = vo.id), '[]'),
    'same_record', coalesce((
      select jsonb_agg(jsonb_build_object('id', o.id, 'name', o.name_hi, 'age', o.age,
                                          'relation', o.relation_type, 'relative', o.relative_name_hi))
      from public.voters o where o.family_id = vo.family_id and o.id <> vo.id), '[]')
  ) into v_result
  from public.voters vo
  join public.families f on f.id = vo.family_id
  where vo.id = p_voter;

  return v_result;
end
$$;

-- Flat rows for the activity page and the CSV export. p_kind 'visits': one
-- row per person per visit; 'forms': one row per form, with the applicant's
-- latest visit. Filters (all optional): from / to (India dates: visit date,
-- or form date), user_id, parts (array), form_type, status, category,
-- outcome, photo ('yes' / 'no'), met ('yes' / 'no').
create function public.admin_rows(p_kind text, p_filters jsonb default '{}') returns jsonb
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_from    date := nullif(p_filters ->> 'from', '')::date;
  v_to      date := nullif(p_filters ->> 'to', '')::date;
  v_user    uuid := nullif(p_filters ->> 'user_id', '')::uuid;
  v_parts   int[] := case when jsonb_typeof(p_filters -> 'parts') = 'array'
                          and jsonb_array_length(p_filters -> 'parts') > 0
                          then (select array_agg(x::int) from jsonb_array_elements_text(p_filters -> 'parts') x) end;
  v_type    text := nullif(p_filters ->> 'form_type', '');
  v_status  text := nullif(p_filters ->> 'status', '');
  v_cat     text := nullif(p_filters ->> 'category', '');
  v_outcome text := nullif(p_filters ->> 'outcome', '');
  v_photo   text := nullif(p_filters ->> 'photo', '');
  v_met     text := nullif(p_filters ->> 'met', '');
  v_result  jsonb;
begin
  if not private.is_admin() then
    raise exception 'NOT_AUTHORIZED' using errcode = '42501';
  end if;

  if p_kind = 'visits' then
    select coalesce(jsonb_agg(r order by r ->> 'visited_at' desc), '[]') into v_result
    from (
      select jsonb_build_object(
        'visit_id', vi.id, 'voter_id', vo.id,
        'visited_at', vi.visited_at, 'received_at', vi.received_at,
        'volunteer', u.name, 'volunteer_mobile', u.mobile,
        'part_no', f.part_no, 'polling_station', b.polling_station_hi, 'house_no', f.house_no,
        'name', vo.name_hi, 'relation', vo.relation_type, 'relative', vo.relative_name_hi,
        'age', vo.age, 'gender', vo.gender, 'epic', vo.epic, 'category', vo.category,
        'new_reason', vo.new_reason, 'draft_part', vo.draft_part, 'draft_section', vo.draft_section,
        'outcome', vv.voter_outcome, 'docs', array_to_string(vv.docs_seen, ', '),
        'person_mobile', coalesce(vv.mobile, vo.mobile),
        'met_person', vi.met_person, 'contact_name', vi.contact_name, 'contact_relation', vi.contact_relation,
        'contact_mobile', vi.contact_mobile, 'contact_refused', vi.contact_refused,
        'remarks', vi.remarks, 'revisit_on', vi.revisit_on,
        'gps_lat', vi.gps_lat, 'gps_lng', vi.gps_lng, 'gps_accuracy_m', vi.gps_accuracy_m,
        'flags', array_to_string(vi.flags, ', '),
        'form_type', fo.form_type, 'form_status', fo.current_status, 'form_route', fo.route,
        'reference_no', fo.reference_no, 'filed_on', fo.filed_on, 'has_photo', fo.photo_path is not null
      ) as r
      from public.visits vi
      join public.visit_voters vv on vv.visit_id = vi.id
      join public.voters vo on vo.id = vv.voter_id
      join public.families f on f.id = vo.family_id
      join public.users u on u.id = vi.user_id
      left join public.booths b on b.part_no = f.part_no
      left join lateral (select * from public.forms x where x.voter_id = vo.id
                         order by x.created_at desc limit 1) fo on true
      where (v_from is null or (vi.visited_at at time zone 'Asia/Kolkata')::date >= v_from)
        and (v_to is null or (vi.visited_at at time zone 'Asia/Kolkata')::date <= v_to)
        and (v_user is null or vi.user_id = v_user)
        and (v_parts is null or f.part_no = any (v_parts))
        and (v_type is null or fo.form_type = v_type)
        and (v_status is null or fo.current_status = v_status)
        and (v_cat is null or vo.category = v_cat)
        and (v_outcome is null or vv.voter_outcome = v_outcome)
        and (v_photo is null or (v_photo = 'yes') = (fo.photo_path is not null))
        and (v_met is null or (v_met = 'yes') = (vv.voter_outcome <> 'NOT_MET'))
      limit 50000
    ) t;
  elsif p_kind = 'forms' then
    select coalesce(jsonb_agg(r order by r ->> 'created_at' desc), '[]') into v_result
    from (
      select jsonb_build_object(
        'form_id', fo.id, 'voter_id', vo.id,
        'form_type', fo.form_type, 'form_status', fo.current_status, 'form_route', fo.route,
        'reference_no', fo.reference_no, 'filed_on', fo.filed_on, 'created_at', fo.created_at,
        'filed_by', u.name, 'filed_by_mobile', u.mobile, 'has_photo', fo.photo_path is not null,
        'part_no', f.part_no, 'polling_station', b.polling_station_hi, 'house_no', f.house_no,
        'name', vo.name_hi, 'relation', vo.relation_type, 'relative', vo.relative_name_hi,
        'age', vo.age, 'gender', vo.gender, 'epic', vo.epic, 'category', vo.category,
        'new_reason', vo.new_reason, 'new_reason_note', vo.new_reason_note,
        'draft_part', vo.draft_part, 'draft_section', vo.draft_section,
        'person_mobile', coalesce(lv.mobile, vo.mobile),
        'visited_at', lv.visited_at, 'outcome', lv.voter_outcome, 'docs', array_to_string(lv.docs_seen, ', '),
        'contact_name', lv.contact_name, 'contact_relation', lv.contact_relation,
        'contact_mobile', lv.contact_mobile, 'contact_refused', lv.contact_refused, 'remarks', lv.remarks,
        'gps_lat', lv.gps_lat, 'gps_lng', lv.gps_lng
      ) as r
      from public.forms fo
      join public.voters vo on vo.id = fo.voter_id
      join public.families f on f.id = vo.family_id
      join public.users u on u.id = fo.filed_by_user_id
      left join public.booths b on b.part_no = f.part_no
      left join lateral (
        select vv.mobile, vv.voter_outcome, vv.docs_seen, vi.visited_at, vi.contact_name, vi.contact_relation,
               vi.contact_mobile, vi.contact_refused, vi.remarks, vi.gps_lat, vi.gps_lng
        from public.visit_voters vv join public.visits vi on vi.id = vv.visit_id
        where vv.voter_id = vo.id order by vi.visited_at desc limit 1) lv on true
      where (v_from is null or (fo.created_at at time zone 'Asia/Kolkata')::date >= v_from)
        and (v_to is null or (fo.created_at at time zone 'Asia/Kolkata')::date <= v_to)
        and (v_user is null or fo.filed_by_user_id = v_user)
        and (v_parts is null or f.part_no = any (v_parts))
        and (v_type is null or fo.form_type = v_type)
        and (v_status is null or fo.current_status = v_status)
        and (v_cat is null or vo.category = v_cat)
        and (v_outcome is null or lv.voter_outcome = v_outcome)
        and (v_photo is null or (v_photo = 'yes') = (fo.photo_path is not null))
      limit 50000
    ) t;
  else
    raise exception 'BAD_KIND' using errcode = '22023';
  end if;

  return v_result;
end
$$;

revoke all on function public.admin_person(uuid), public.admin_rows(text, jsonb) from public, anon;
grant execute on function public.admin_person(uuid), public.admin_rows(text, jsonb) to authenticated;
