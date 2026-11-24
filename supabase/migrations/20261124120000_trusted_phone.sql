-- Approved phones sign back in without waiting for an admin, for 35 days.
--
-- When an admin approves a sign-in, that phone becomes the volunteer's
-- trusted phone until 35 days after the approval. A later sign-in request
-- from the same phone (same device id, and the device key only that phone
-- holds) is approved at once. A different phone or browser still needs an
-- admin, so knowing someone's mobile number is not enough to sign in as
-- them. "Sign out phone" and deactivation end the trust immediately;
-- approving another phone moves it there.

alter table public.users
  add column trusted_device_id text,
  add column trusted_key_hash text,
  add column trusted_until timestamptz;

alter table public.login_requests
  add column device_key_hash text,
  add column auto_approved boolean not null default false;

create function private.end_trust_on_revoke() returns trigger
language plpgsql set search_path = ''
as $$
begin
  if (old.active_session_id is not null and new.active_session_id is null)
     or (old.is_active and not new.is_active) then
    new.trusted_device_id := null;
    new.trusted_key_hash := null;
    new.trusted_until := null;
  end if;
  return new;
end
$$;
create trigger users_end_trust before update on public.users
  for each row execute function private.end_trust_on_revoke();

-- The phone now also sends its long-lived device key (old app versions do
-- not, and simply wait for an admin as before).
drop function public.request_login(text, text, text, text);

create function public.request_login(
  p_mobile text, p_device_id text, p_device_secret text, p_device_model text default null,
  p_device_key text default null
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_mobile   text := right(regexp_replace(coalesce(p_mobile, ''), '\D', '', 'g'), 10);
  v_user     public.users;
  v_code     text;
  v_id       uuid;
  v_key_hash text := case when length(coalesce(p_device_key, '')) >= 32
                          then encode(extensions.digest(p_device_key, 'sha256'), 'hex') end;
  v_trusted  boolean;
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

  -- coalesce: with no trusted phone yet the comparisons are null, not false.
  v_trusted := coalesce(v_key_hash is not null
                        and v_user.trusted_until > now()
                        and v_user.trusted_device_id = p_device_id
                        and v_user.trusted_key_hash = v_key_hash, false);

  v_code := lpad(floor(random() * 10000)::int::text, 4, '0');

  insert into public.login_requests (user_id, device_id, device_model, secret_hash, match_code,
                                     device_key_hash, status, decided_at, auto_approved)
  values (v_user.id, p_device_id, left(p_device_model, 80),
          encode(extensions.digest(p_device_secret, 'sha256'), 'hex'), v_code, v_key_hash,
          case when v_trusted then 'approved' else 'pending' end,
          case when v_trusted then now() end, v_trusted)
  returning id into v_id;

  if v_trusted then
    perform private.audit('auto_approve_login', 'login_requests', v_id::text,
      jsonb_build_object('user_id', v_user.id, 'device_id', p_device_id,
                         'trusted_until', v_user.trusted_until));
  end if;

  return jsonb_build_object('ok', true, 'request_id', v_id, 'match_code', v_code,
                            'auto_approved', v_trusted);
end
$$;

revoke execute on function public.request_login(text, text, text, text, text) from public;
grant execute on function public.request_login(text, text, text, text, text) to anon, authenticated;

-- Claiming an admin-approved request makes that phone the trusted one, for
-- 35 days from the approval. Claiming an automatic approval keeps the date.
create or replace function public.login_request_consume(
  p_request_id uuid, p_device_secret text, p_auth_user_id uuid, p_session_id uuid
) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_req public.login_requests;
begin
  update public.login_requests
  set status = 'consumed', consumed_at = now()
  where id = p_request_id and status = 'approved'
    and secret_hash = encode(extensions.digest(coalesce(p_device_secret, ''), 'sha256'), 'hex')
  returning * into v_req;
  if not found then
    return jsonb_build_object('ok', false);
  end if;

  update public.users
  set auth_user_id = p_auth_user_id, active_session_id = p_session_id,
      device_id = v_req.device_id, device_model = v_req.device_model, last_login_at = now(),
      trusted_device_id = case when v_req.auto_approved then trusted_device_id else v_req.device_id end,
      trusted_key_hash  = case when v_req.auto_approved then trusted_key_hash else v_req.device_key_hash end,
      trusted_until     = case when v_req.auto_approved then trusted_until
                               when v_req.device_key_hash is null then null
                               else v_req.decided_at + interval '35 days' end
  where id = v_req.user_id;

  insert into public.audit_log (user_id, action, entity, entity_id, detail)
  values (v_req.user_id, 'login', 'users', v_req.user_id::text,
          jsonb_build_object('device_id', v_req.device_id, 'request_id', v_req.id,
                             'auto_approved', v_req.auto_approved));

  return jsonb_build_object('ok', true);
end
$$;

revoke execute on function public.login_request_consume(uuid, text, uuid, uuid) from public, anon, authenticated;
