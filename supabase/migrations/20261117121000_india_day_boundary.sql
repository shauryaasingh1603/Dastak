-- The campaign runs on Indian time; the database clock is UTC. Use one helper
-- for "today" so an assignment made after midnight IST takes effect at once.
create function private.today() returns date
language sql stable set search_path = ''
as $$ select (now() at time zone 'Asia/Kolkata')::date $$;

grant execute on function private.today() to authenticated, service_role;

alter table public.assignments alter column from_date set default private.today();

create or replace function private.can_see_family(p_part int, p_section int, p_assigned uuid) returns boolean
language sql stable security definer set search_path = ''
as $$
  select case
    when me.id is null then false
    when p_assigned = me.id then true
    else exists (
      select 1 from public.assignments a
      where a.user_id = me.id
        and a.part_no = p_part
        and (a.section_no is null or a.section_no = p_section)
        and a.from_date <= private.today()
        and (a.to_date is null or a.to_date >= private.today())
    )
  end
  from (select private.current_user_id() as id) me
$$;
