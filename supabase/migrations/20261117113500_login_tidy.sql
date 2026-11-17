-- Record which admin created a user or assignment without the client sending it.
grant usage on schema private to service_role;
grant execute on function private.current_user_id() to service_role;
alter table public.users       alter column created_by set default private.current_user_id();
alter table public.assignments alter column created_by set default private.current_user_id();

-- Do not reveal a volunteer's name to someone who only knows their number.
create or replace function public.request_login(
  p_mobile text, p_device_id text, p_device_secret text, p_device_model text default null
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_mobile text := right(regexp_replace(coalesce(p_mobile, ''), '\D', '', 'g'), 10);
  v_user   public.users;
  v_code   text;
  v_id     uuid;
begin
  if length(coalesce(p_device_secret, '')) < 32 or length(coalesce(p_device_id, '')) < 8 then
    return jsonb_build_object('ok', false, 'code', 'BAD_REQUEST');
  end if;

  select * into v_user from public.users
  where mobile = v_mobile and role in ('volunteer', 'bla2') and is_active;
  if not found then
    return jsonb_build_object('ok', false, 'code', 'NOT_REGISTERED');
  end if;

  if (select count(*) from public.login_requests
      where user_id = v_user.id and created_at > now() - interval '1 hour') >= 10 then
    return jsonb_build_object('ok', false, 'code', 'TOO_MANY');
  end if;

  -- A new request from the same phone replaces its earlier pending one.
  update public.login_requests set status = 'expired'
  where user_id = v_user.id and device_id = p_device_id and status = 'pending';

  v_code := lpad(floor(random() * 10000)::int::text, 4, '0');

  insert into public.login_requests (user_id, device_id, device_model, secret_hash, match_code)
  values (v_user.id, p_device_id, left(p_device_model, 80),
          encode(extensions.digest(p_device_secret, 'sha256'), 'hex'), v_code)
  returning id into v_id;

  return jsonb_build_object('ok', true, 'request_id', v_id, 'match_code', v_code);
end
$$;
