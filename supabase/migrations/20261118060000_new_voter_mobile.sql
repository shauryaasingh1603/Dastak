-- A voter added in the field can come with a mobile number (spec section 6,
-- "नया मतदाता जोड़ें"). Like numbers recorded during visits, it is kept only
-- with the voter's consent, is never sent back down to phones, and falls
-- under the same retention rule (deleted 30 days after the final roll).

alter table public.voters
  add column mobile text,
  add column mobile_consent boolean not null default false,
  add constraint voters_mobile_format check (mobile ~ '^[6-9][0-9]{9}$'),
  add constraint voters_mobile_consent check (mobile is null or mobile_consent);

create or replace function private.push_voter(p_me public.users, p_id uuid, p_data jsonb) returns void
language plpgsql security definer set search_path = ''
as $$
declare
  v_family uuid := (p_data ->> 'family_id')::uuid;
begin
  if exists (select 1 from public.voters where id = p_id) then
    return; -- already received
  end if;
  perform private.require_visible_family(v_family);

  insert into public.voters (id, family_id, epic, name_hi, relation_type, relative_name_hi, age, gender,
                             source_list, created_by, mobile, mobile_consent)
  values (p_id, v_family, nullif(upper(trim(p_data ->> 'epic')), ''), trim(p_data ->> 'name_hi'),
          p_data ->> 'relation_type', nullif(trim(p_data ->> 'relative_name_hi'), ''),
          (p_data ->> 'age')::int, p_data ->> 'gender', 'NEW', p_me.id,
          nullif(p_data ->> 'mobile', ''), coalesce((p_data ->> 'mobile_consent')::boolean, false));
end
$$;

create or replace function public.sync_push(p_items jsonb, p_device_now timestamptz default null) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_me         public.users;
  v_settings   public.campaign_settings;
  v_item       jsonb;
  v_id         uuid;
  v_code       text;
  v_constraint text;
  v_results    jsonb := '[]';
  v_accepted   int := 0;
  -- Server time is the truth for deadlines; a phone clock more than 10 minutes
  -- off is recorded on the visits it sends.
  v_skew       boolean := p_device_now is not null
                          and abs(extract(epoch from (now() - p_device_now))) > 600;
begin
  select * into v_me from public.users
  where id = private.current_user_id() and role in ('volunteer', 'bla2');
  if not found then
    raise exception 'NOT_AUTHORIZED' using errcode = '42501';
  end if;
  if jsonb_typeof(p_items) is distinct from 'array' or jsonb_array_length(p_items) > 50 then
    raise exception 'BAD_BATCH' using errcode = '22023';
  end if;
  select * into v_settings from public.campaign_settings;

  for v_item in select value from jsonb_array_elements(p_items) loop
    v_code := 'OK';
    v_id := null;
    begin
      v_id := (v_item ->> 'uuid')::uuid;
      case v_item ->> 'entity'
        when 'voter'      then perform private.push_voter(v_me, v_id, v_item -> 'data');
        when 'visit'      then perform private.push_visit(v_me, v_settings, v_id, v_item -> 'data', v_skew);
        when 'form'       then perform private.push_form(v_me, v_settings, v_id, v_item -> 'data');
        when 'form_event' then perform private.push_form_event(v_me, v_settings, v_id, v_item -> 'data');
        else perform private.sync_reject('INVALID');
      end case;
    exception
      when raise_exception then
        v_code := sqlerrm;
      when unique_violation then
        get stacked diagnostics v_constraint = constraint_name;
        v_code := case v_constraint
          when 'forms_reference_no_key'  then 'DUPLICATE_REFERENCE'
          when 'forms_one_open_per_type' then 'DUPLICATE_FORM'
          when 'voters_epic_key'         then 'DUPLICATE_EPIC'
          else 'INVALID' end;
      when check_violation then
        get stacked diagnostics v_constraint = constraint_name;
        v_code := case v_constraint
          when 'forms_check'               then 'RECEIPT_REQUIRED'
          when 'visits_check'              then 'REVISIT_REQUIRED'
          when 'visit_voters_check'        then 'MOBILE_CONSENT'
          when 'visit_voters_mobile_check' then 'INVALID_MOBILE'
          when 'voters_mobile_consent'     then 'MOBILE_CONSENT'
          when 'voters_mobile_format'      then 'INVALID_MOBILE'
          else 'INVALID' end;
      when foreign_key_violation then
        v_code := 'UNKNOWN_RECORD';
      when others then
        v_code := 'INVALID';
    end;

    if v_code = 'OK' then
      v_accepted := v_accepted + 1;
      v_results := v_results || jsonb_build_object('uuid', v_item ->> 'uuid', 'ok', true);
    else
      v_results := v_results || jsonb_build_object(
        'uuid', v_item ->> 'uuid', 'ok', false, 'code', v_code, 'message_hi', private.sync_message_hi(v_code));
    end if;
  end loop;

  insert into public.audit_log (user_id, action, entity, detail)
  values (v_me.id, 'sync_push', 'outbox',
          jsonb_build_object('accepted', v_accepted, 'rejected', jsonb_array_length(p_items) - v_accepted,
                             'clock_skew', v_skew));

  return jsonb_build_object('server_time', now(), 'results', v_results);
end
$$;

