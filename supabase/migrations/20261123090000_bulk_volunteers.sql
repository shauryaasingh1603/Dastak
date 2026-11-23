-- Registering many volunteers at once from a sheet (admin website, Field
-- team page). Admins only. Each row: name, mobile, role (volunteer or bla2,
-- default volunteer), booths (part numbers).
--
-- With p_commit = false nothing is saved: every row comes back with what is
-- wrong with it, for the preview. With p_commit = true the rows without a
-- problem are registered with their booths, in one transaction, and the
-- others are left out and reported.

create function public.admin_register_volunteers(p_rows jsonb, p_commit boolean default false) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_admin   uuid := private.current_user_id();
  v_row     jsonb;
  v_index   int := 0;
  v_name    text;
  v_mobile  text;
  v_role    text;
  v_booths  int[];
  v_error   text;
  v_seen    text[] := '{}';
  v_user    uuid;
  v_results jsonb := '[]';
  v_created int := 0;
begin
  if not private.is_admin() then
    raise exception 'NOT_AUTHORIZED' using errcode = '42501';
  end if;
  if jsonb_typeof(p_rows) is distinct from 'array' or jsonb_array_length(p_rows) > 2000 then
    raise exception 'BAD_BATCH' using errcode = '22023';
  end if;

  for v_row in select value from jsonb_array_elements(p_rows) loop
    v_index  := v_index + 1;
    v_error  := null;
    v_name   := nullif(trim(v_row ->> 'name'), '');
    v_mobile := right(regexp_replace(coalesce(v_row ->> 'mobile', ''), '\D', '', 'g'), 10);
    v_role   := lower(coalesce(nullif(trim(v_row ->> 'role'), ''), 'volunteer'));
    v_role   := case when v_role in ('bla2', 'bla-2', 'bla 2') then 'bla2' else v_role end;
    v_booths := coalesce((select array_agg(distinct x::int order by x::int)
                          from jsonb_array_elements_text(coalesce(v_row -> 'booths', '[]')) x
                          where x ~ '^\d+$'), '{}');

    if v_name is null then
      v_error := 'NAME_MISSING';
    elsif v_mobile !~ '^[6-9][0-9]{9}$' then
      v_error := 'MOBILE_INVALID';
    elsif v_mobile = any (v_seen) then
      v_error := 'MOBILE_REPEATED';
    elsif exists (select 1 from public.users u where u.mobile = v_mobile) then
      v_error := 'MOBILE_TAKEN';
    elsif v_role not in ('volunteer', 'bla2') then
      v_error := 'ROLE_INVALID';
    elsif exists (select 1 from jsonb_array_elements_text(coalesce(v_row -> 'booths', '[]')) x
                  where x !~ '^\d+$')
          or exists (select 1 from unnest(v_booths) b
                     where not exists (select 1 from public.booths x where x.part_no = b)) then
      v_error := 'BOOTH_INVALID';
    end if;
    v_seen := v_seen || v_mobile;

    if v_error is null and p_commit then
      insert into public.users (name, mobile, role, created_by)
      values (v_name, v_mobile, v_role, v_admin)
      returning id into v_user;
      insert into public.assignments (user_id, part_no, created_by)
      select v_user, b, v_admin from unnest(v_booths) b;
      v_created := v_created + 1;
    end if;

    v_results := v_results || jsonb_build_object(
      'row', v_index, 'name', v_name, 'mobile', v_mobile, 'role', v_role,
      'booths', to_jsonb(v_booths), 'error', v_error);
  end loop;

  return jsonb_build_object('created', v_created, 'rows', v_results);
end
$$;

revoke all on function public.admin_register_volunteers(jsonb, boolean) from public, anon;
grant execute on function public.admin_register_volunteers(jsonb, boolean) to authenticated;
