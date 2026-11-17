-- Mock visit list near the real campaign's scale: about 19,300 families and
-- 52,100 voters across the 443 booths. Every name is invented and every EPIC
-- starts with MOCK. Deterministic, so re-running on an empty database gives the
-- same rows. Run it only against an empty families table; remove it all with
-- supabase/seed/clear_field_data.sql before loading the real list.
--
-- Priority mix follows the spec: 1 = possibly deleted (high confidence),
-- 2 = ASDD shifted, 3 = ASDD untraceable, 4 = possibly deleted (medium/low).

insert into public.booths (part_no, name_hi, polling_station_hi)
select g, 'बूथ ' || g, 'प्राथमिक विद्यालय, मतदान केंद्र ' || g
from generate_series(1, 443) g
on conflict (part_no) do nothing;

with m as (
  select
    array['राम','श्याम','मोहन','सुरेश','रमेश','दिनेश','महेश','राजेश','अनिल','सुनील','विजय','अजय','संजय',
          'मनोज','प्रमोद','अशोक','राकेश','मुकेश','पंकज','दीपक','इमरान','सलीम','अकरम','जावेद','नसीम','शकील'] as male,
    array['सीता','गीता','रीता','सुनीता','अनीता','कमला','विमला','शांति','सावित्री','उर्मिला','पूनम','रेखा',
          'ममता','सरोज','किरन','आशा','उषा','मीना','रुख़साना','शबनम','नसरीन','सलमा','फ़ातिमा','ज़रीना'] as female,
    array['यादव','मौर्य','सिंह','पाल','गुप्ता','वर्मा','मिश्रा','तिवारी','पांडेय','चौहान','राजभर','बिंद','निषाद',
          'पटेल','विश्वकर्मा','प्रजापति','अंसारी','ख़ान','सिद्दीक़ी','शेख़','गौतम','सोनकर','कुशवाहा','दुबे'] as surname
),
fam as (
  select
    format('371-%s-F%s', lpad(b.part_no::text, 3, '0'), lpad(n::text, 4, '0')) as code,
    b.part_no,
    n,
    m.male[1 + h.a % array_length(m.male, 1)] as head_first,
    m.male[1 + h.d % array_length(m.male, 1)] as grandfather,
    m.surname[1 + h.b % array_length(m.surname, 1)] as surname,
    case when h.c % 100 < 5 then 1 when h.c % 100 < 69 then 2 when h.c % 100 < 91 then 3 else 4 end as priority,
    (array[1, 2, 2, 2, 3, 3, 3, 3, 4, 4])[1 + h.e % 10] as size,
    35 + h.f % 36 as head_age,
    h.g as seed
  from public.booths b
  cross join m
  cross join lateral generate_series(1, 40 + (b.part_no * 7) % 14) n
  cross join lateral (
    select
      hashtext('a' || b.part_no || '-' || n)::bigint & 2147483647 as a,
      hashtext('b' || b.part_no || '-' || n)::bigint & 2147483647 as b,
      hashtext('c' || b.part_no || '-' || n)::bigint & 2147483647 as c,
      hashtext('d' || b.part_no || '-' || n)::bigint & 2147483647 as d,
      hashtext('e' || b.part_no || '-' || n)::bigint & 2147483647 as e,
      hashtext('f' || b.part_no || '-' || n)::bigint & 2147483647 as f,
      hashtext('g' || b.part_no || '-' || n)::bigint & 2147483647 as g
  ) h
),
ins as (
  insert into public.families (code, part_no, section_no, house_no, head_name_hi, priority)
  select code, part_no, 1 + ((n - 1) / 14) % 4, (1 + (n * 37 + part_no) % 240)::text,
         head_first || ' ' || surname, priority
  from fam
  returning id, code
),
members as (
  select
    ins.id as family_id, fam.*, k,
    hashtext('k' || fam.code || '-' || k)::bigint & 2147483647 as r,
    row_number() over (order by fam.part_no, fam.n, k) as seq,
    row_number() over (partition by fam.part_no order by fam.n, k) as serial
  from fam
  join ins using (code)
  cross join lateral generate_series(1, fam.size) k
)
insert into public.voters (
  family_id, epic, roll_ref, name_hi, relation_type, relative_name_hi, age, gender,
  source_list, asdd_reason, old_part_no, old_serial, likely_new_part, match_confidence
)
select
  mb.family_id,
  case when mb.r % 100 < 85 then 'MOCK' || lpad(mb.seq::text, 7, '0') end,
  format('P%s-S%s', lpad(mb.part_no::text, 3, '0'), lpad(mb.serial::text, 4, '0')),
  case
    when mb.k = 1 then mb.head_first
    when mb.k = 2 or mb.r % 2 = 0 then m.female[1 + mb.r % array_length(m.female, 1)]
    else m.male[1 + mb.r % array_length(m.male, 1)]
  end || ' ' || mb.surname,
  case when mb.k = 2 then 'H' else 'F' end,
  case when mb.k = 1 then mb.grandfather else mb.head_first end || ' ' || mb.surname,
  case
    when mb.k = 1 then mb.head_age
    when mb.k = 2 then greatest(21, mb.head_age - 2 - (mb.r % 5)::int)
    else 18 + (mb.r % greatest(1, least(17, mb.head_age - 34)))::int
  end,
  case when mb.k = 1 then 'M' when mb.k = 2 or mb.r % 2 = 0 then 'F' else 'M' end,
  case when mb.priority in (1, 4) then 'POSS_DEL' else 'ASDD' end,
  case mb.priority when 2 then 'SHIFTED' when 3 then 'UNTRACEABLE' end,
  mb.part_no,
  mb.serial,
  mb.part_no,
  case when mb.priority = 1 then 'HIGH'
       when mb.priority = 4 then case when mb.seed % 8 = 0 then 'LOW' else 'MEDIUM' end end
from members mb
cross join m;
