-- Loading the visit list from tools/import/import_visit_list.py output.
--
-- The list is too large to send through the database console, so these two
-- functions take it in batches over the API. They do nothing without a
-- one-time import token (only its hash is stored, with an expiry); each
-- import run inserts a fresh token and expires it when done.

create table private.import_tokens (
  token_hash text primary key,
  expires_at timestamptz not null
);
alter table private.import_tokens enable row level security;

create function private.import_allowed(p_token text) returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from private.import_tokens
    where token_hash = encode(extensions.digest(coalesce(p_token, ''), 'sha256'), 'hex')
      and expires_at > now()
  )
$$;

-- Booth names from the workbook's Booth Summary.
create function public.import_booths(p_token text, p_booths jsonb) returns int
language plpgsql security definer set search_path = ''
as $$
declare
  v_count int;
begin
  if not private.import_allowed(p_token) then
    raise exception 'IMPORT_NOT_ALLOWED' using errcode = '42501';
  end if;
  insert into public.booths (part_no, name_hi, polling_station_hi)
  select b.part_no, 'बूथ ' || b.part_no, b.polling_station_hi
  from jsonb_to_recordset(p_booths) as b(part_no int, polling_station_hi text)
  on conflict (part_no) do update set polling_station_hi = excluded.polling_station_hi;
  get diagnostics v_count = row_count;
  return v_count;
end
$$;

-- One batch of people: a record (family of one) and a voter each. Safe to
-- send a batch twice: records that already exist are skipped, with their voter.
create function public.import_people(p_token text, p_people jsonb) returns int
language plpgsql security definer set search_path = ''
as $$
declare
  v_count int;
begin
  if not private.import_allowed(p_token) then
    raise exception 'IMPORT_NOT_ALLOWED' using errcode = '42501';
  end if;
  with input as (
    select * from jsonb_to_recordset(p_people) as x(
      code text, part int, house text, name text, priority int, review boolean, epic text, roll_ref text,
      relation text, relative text, age int, gender text, source text, asdd_reason text,
      old_part int, old_serial int, likely_part int, confidence text)
  ), fam as (
    insert into public.families (code, part_no, house_no, head_name_hi, priority, needs_review)
    select code, part, house, name, priority, review from input
    on conflict (code) do nothing
    returning id, code
  )
  insert into public.voters (family_id, epic, roll_ref, name_hi, relation_type, relative_name_hi, age, gender,
                             source_list, asdd_reason, old_part_no, old_serial, likely_new_part, match_confidence)
  select fam.id, i.epic, i.roll_ref, i.name, i.relation, i.relative, i.age, i.gender,
         i.source, i.asdd_reason, i.old_part, i.old_serial, i.likely_part, i.confidence
  from input i join fam using (code);
  get diagnostics v_count = row_count;
  return v_count;
end
$$;

revoke execute on function public.import_booths(text, jsonb), public.import_people(text, jsonb) from public, authenticated;
grant execute on function public.import_booths(text, jsonb), public.import_people(text, jsonb) to anon;
