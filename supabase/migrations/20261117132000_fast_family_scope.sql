-- The first family rule called a function for every family in the table, so a
-- volunteer's list took about 6 seconds at 19,000 families. Work out the
-- caller's booths once per query instead, so the part_no index can be used.

-- Booths the caller holds in full.
create function private.my_parts() returns int[]
language sql stable security definer set search_path = ''
as $$
  select coalesce(array_agg(distinct a.part_no), '{}')
  from public.assignments a
  where a.user_id = private.current_user_id()
    and a.section_no is null
    and a.from_date <= private.today()
    and (a.to_date is null or a.to_date >= private.today())
$$;

-- Single sections the caller holds, as 'part:section' keys.
create function private.my_sections() returns text[]
language sql stable security definer set search_path = ''
as $$
  select coalesce(array_agg(distinct a.part_no || ':' || a.section_no), '{}')
  from public.assignments a
  where a.user_id = private.current_user_id()
    and a.section_no is not null
    and a.from_date <= private.today()
    and (a.to_date is null or a.to_date >= private.today())
$$;

grant execute on function private.my_parts(), private.my_sections() to authenticated;

drop policy scoped_read on public.families;
create policy scoped_read on public.families for select to authenticated
  using (
    part_no = any ((select private.my_parts())::int[])
    or assigned_user_id = (select private.current_user_id())
    or (section_no is not null
        and (part_no || ':' || section_no) = any ((select private.my_sections())::text[]))
  );

drop function private.can_see_family(int, int, uuid);
