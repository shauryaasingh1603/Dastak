-- visible_family_ids() was a SQL function whose "me" CTE got inlined, so the
-- caller's booths were looked up again for every one of ~19,000 families:
-- about 8 seconds, enough to hit the statement timeout in sync_pull. Look
-- them up once, then filter.
create or replace function private.visible_family_ids() returns setof uuid
language plpgsql stable security definer set search_path = ''
as $$
declare
  v_me    uuid := private.current_user_id();
  v_parts int[];
  v_secs  text[];
begin
  if v_me is null then
    return;
  end if;
  v_parts := private.my_parts();
  v_secs := private.my_sections();
  return query
    select f.id
    from public.families f
    where not f.is_hidden
      and (f.part_no = any (v_parts)
           or f.assigned_user_id = v_me
           or (f.section_no is not null and (f.part_no || ':' || f.section_no) = any (v_secs)));
end
$$;
