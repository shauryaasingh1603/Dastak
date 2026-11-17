-- Dastak: core schema, access rules and device-approval login.
--
-- Conventions
--   * Every row created on a phone carries a client-generated UUID, so a retried
--     sync is a no-op.
--   * Visits and form events are append-only. An "edit" is a new visit row that
--     points at the one it replaces (visits.supersedes).
--   * Fixed values are stored as codes (text + check); the apps show Hindi labels.

create schema if not exists private;

-- ---------------------------------------------------------------------------
-- Master data
-- ---------------------------------------------------------------------------

create table public.booths (
  part_no            int primary key check (part_no between 1 and 443),
  name_hi            text not null,
  polling_station_hi text,
  old_part_nos       int[] not null default '{}'
);

create table public.users (
  id                uuid primary key default gen_random_uuid(),
  auth_user_id      uuid unique references auth.users (id) on delete set null,
  name              text not null,
  mobile            text unique check (mobile ~ '^[6-9][0-9]{9}$'),
  email             text unique,
  role              text not null check (role in ('volunteer', 'bla2', 'admin')),
  is_active         boolean not null default true,
  -- Field users are bound to the one device session an admin approved.
  active_session_id uuid,
  device_id         text,
  device_model      text,
  last_login_at     timestamptz,
  created_at        timestamptz not null default now(),
  created_by        uuid references public.users (id),
  updated_at        timestamptz not null default now(),
  check (role = 'admin' or mobile is not null),
  check (role <> 'admin' or email is not null)
);

create table public.assignments (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.users (id),
  part_no    int  not null references public.booths (part_no),
  section_no int,
  from_date  date not null default current_date,
  to_date    date,
  created_at timestamptz not null default now(),
  created_by uuid references public.users (id),
  check (to_date is null or to_date >= from_date)
);
create index assignments_user_idx on public.assignments (user_id);
create index assignments_part_idx on public.assignments (part_no);

create table public.families (
  id               uuid primary key default gen_random_uuid(),
  -- Display code, e.g. 371-045-F0123. Issued once at import and never reused,
  -- so re-running the import cannot orphan recorded visits.
  code             text not null unique,
  part_no          int  not null references public.booths (part_no),
  section_no       int,
  house_no         text,
  head_name_hi     text,
  assigned_user_id uuid references public.users (id),
  priority         smallint not null default 4 check (priority between 1 and 4),
  is_hidden        boolean not null default false,
  needs_review     boolean not null default false,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create index families_part_idx     on public.families (part_no, section_no);
create index families_assigned_idx on public.families (assigned_user_id);
create index families_updated_idx  on public.families (updated_at);

create table public.voters (
  id               uuid primary key default gen_random_uuid(),
  family_id        uuid not null references public.families (id),
  epic             text unique,
  -- P{old_part}-S{old_serial} for roll voters; null for voters added in the field.
  roll_ref         text unique,
  name_hi          text not null,
  relation_type    text check (relation_type in ('F', 'H', 'M', 'O')),
  relative_name_hi text,
  age              int check (age between 0 and 130),
  gender           text check (gender in ('M', 'F', 'O')),
  source_list      text not null check (source_list in ('ASDD', 'POSS_DEL', 'NEW')),
  asdd_reason      text check (asdd_reason in ('UNTRACEABLE', 'SHIFTED')),
  old_part_no      int,
  old_serial       int,
  likely_new_part  int,
  match_confidence text check (match_confidence in ('HIGH', 'MEDIUM', 'LOW')),
  already_on_roll  boolean not null default false,
  created_by       uuid references public.users (id),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create index voters_family_idx  on public.voters (family_id);
create index voters_updated_idx on public.voters (updated_at);

-- ---------------------------------------------------------------------------
-- Field records
-- ---------------------------------------------------------------------------

create table public.visits (
  id             uuid primary key,
  family_id      uuid not null references public.families (id),
  user_id        uuid not null references public.users (id),
  visited_at     timestamptz not null,               -- phone clock
  received_at    timestamptz not null default now(), -- server clock
  gps_lat        double precision,
  gps_lng        double precision,
  gps_accuracy_m real,
  met_person     text,
  outcome        text not null check (outcome in
                   ('ELIGIBLE', 'CORRECTION', 'MOVED_IN', 'SHIFTED', 'DEAD', 'NOT_MET', 'ALREADY_ON_ROLL')),
  remarks        text,
  revisit_on     date,
  supersedes     uuid references public.visits (id),
  flags          text[] not null default '{}',
  check (outcome <> 'NOT_MET' or revisit_on is not null)
);
create index visits_family_idx   on public.visits (family_id);
create index visits_user_idx     on public.visits (user_id, visited_at);
create index visits_received_idx on public.visits (received_at);

create table public.visit_voters (
  visit_id      uuid not null references public.visits (id),
  voter_id      uuid not null references public.voters (id),
  voter_outcome text not null check (voter_outcome in
                  ('ELIGIBLE', 'CORRECTION', 'MOVED_IN', 'SHIFTED', 'DEAD', 'NOT_MET', 'ALREADY_ON_ROLL')),
  docs_seen     text[] not null default '{}',
  mobile        text check (mobile ~ '^[6-9][0-9]{9}$'),
  mobile_consent boolean not null default false,
  primary key (visit_id, voter_id),
  check (mobile is null or mobile_consent)
);
create index visit_voters_voter_idx on public.visit_voters (voter_id);

create table public.forms (
  id                 uuid primary key,
  voter_id           uuid not null references public.voters (id),
  -- Form 7 is allowed here but not offered in the app until the client decides.
  form_type          text not null check (form_type in ('6', '7', '8')),
  route              text check (route in ('BLA2', 'SELF', 'ONLINE')),
  reference_no       text unique,
  filed_on           date,
  filed_by_user_id   uuid not null references public.users (id),
  receipt_photo_path text,
  current_status     text not null default 'FILLED' check (current_status in
                       ('FILLED', 'SUBMITTED', 'IN_ERO_LIST', 'ACCEPTED', 'REJECTED', 'HEARING')),
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  -- R1: a form cannot move past FILLED without a receipt / reference number.
  check (current_status = 'FILLED' or reference_no is not null)
);
-- R6: one open form of each type per voter.
create unique index forms_one_open_per_type
  on public.forms (voter_id, form_type)
  where current_status not in ('ACCEPTED', 'REJECTED');
create index forms_voter_idx   on public.forms (voter_id);
create index forms_updated_idx on public.forms (updated_at);

create table public.form_events (
  id         uuid primary key,
  form_id    uuid not null references public.forms (id),
  status     text not null check (status in
               ('FILLED', 'SUBMITTED', 'IN_ERO_LIST', 'ACCEPTED', 'REJECTED', 'HEARING')),
  changed_by uuid not null references public.users (id),
  changed_at timestamptz not null default now(),
  client_ts  timestamptz,
  note       text
);
create index form_events_form_idx on public.form_events (form_id, changed_at);

-- ---------------------------------------------------------------------------
-- Login requests and audit
-- ---------------------------------------------------------------------------

create table public.login_requests (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.users (id),
  device_id    text not null,
  device_model text,
  secret_hash  text not null,
  match_code   text not null,
  status       text not null default 'pending' check (status in
                 ('pending', 'approved', 'rejected', 'consumed', 'expired')),
  created_at   timestamptz not null default now(),
  decided_at   timestamptz,
  decided_by   uuid references public.users (id),
  consumed_at  timestamptz
);
create index login_requests_status_idx on public.login_requests (status, created_at);
create index login_requests_user_idx   on public.login_requests (user_id, created_at);

create table public.audit_log (
  id        bigint generated always as identity primary key,
  at        timestamptz not null default now(),
  user_id   uuid,
  action    text not null,
  entity    text,
  entity_id text,
  detail    jsonb
);
create index audit_log_at_idx on public.audit_log (at);

create table private.bootstrap (
  id        boolean primary key default true check (id),
  code_hash text not null,
  used_at   timestamptz
);

-- ---------------------------------------------------------------------------
-- Helpers used by the access rules
-- ---------------------------------------------------------------------------

-- The caller's users.id, or null when they must not see anything: unknown,
-- deactivated, or a field user on a session other than the approved one.
create function private.current_user_id() returns uuid
language sql stable security definer set search_path = ''
as $$
  select u.id
  from public.users u
  where u.auth_user_id = (select auth.uid())
    and u.is_active
    and (u.role = 'admin'
         or u.active_session_id::text = ((select auth.jwt()) ->> 'session_id'))
$$;

create function private.is_admin() returns boolean
language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.users u
    where u.auth_user_id = (select auth.uid()) and u.is_active and u.role = 'admin'
  )
$$;

-- A field user sees a family if it is assigned to them, or it sits in a booth
-- (or booth section) they currently hold.
create function private.can_see_family(p_part int, p_section int, p_assigned uuid) returns boolean
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
        and a.from_date <= current_date
        and (a.to_date is null or a.to_date >= current_date)
    )
  end
  from (select private.current_user_id() as id) me
$$;

create function private.audit(p_action text, p_entity text, p_entity_id text, p_detail jsonb default null)
returns void
language sql security definer set search_path = ''
as $$
  insert into public.audit_log (user_id, action, entity, entity_id, detail)
  values (private.current_user_id(), p_action, p_entity, p_entity_id, p_detail)
$$;

create function private.touch_updated_at() returns trigger
language plpgsql set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end
$$;

create trigger users_touch    before update on public.users    for each row execute function private.touch_updated_at();
create trigger families_touch before update on public.families for each row execute function private.touch_updated_at();
create trigger voters_touch   before update on public.voters   for each row execute function private.touch_updated_at();
create trigger forms_touch    before update on public.forms    for each row execute function private.touch_updated_at();

create function private.audit_row() returns trigger
language plpgsql security definer set search_path = ''
as $$
declare
  v_row jsonb := to_jsonb(coalesce(new, old));
begin
  perform private.audit(
    lower(tg_op) || '_' || tg_table_name,
    tg_table_name,
    v_row ->> 'id',
    case when tg_op = 'UPDATE' then jsonb_build_object('old', to_jsonb(old), 'new', to_jsonb(new)) else v_row end
  );
  return coalesce(new, old);
end
$$;

create trigger users_audit       after insert or update or delete on public.users       for each row execute function private.audit_row();
create trigger assignments_audit after insert or update or delete on public.assignments for each row execute function private.audit_row();

-- ---------------------------------------------------------------------------
-- Row-level security
-- ---------------------------------------------------------------------------

alter table public.booths         enable row level security;
alter table public.users          enable row level security;
alter table public.assignments    enable row level security;
alter table public.families       enable row level security;
alter table public.voters         enable row level security;
alter table public.visits         enable row level security;
alter table public.visit_voters   enable row level security;
alter table public.forms          enable row level security;
alter table public.form_events    enable row level security;
alter table public.login_requests enable row level security;
alter table public.audit_log      enable row level security;
alter table private.bootstrap     enable row level security;

revoke all on all tables in schema public from anon, authenticated;
grant all on all tables in schema public to service_role;
grant usage on schema private to authenticated;
grant execute on function private.current_user_id(), private.is_admin(),
  private.can_see_family(int, int, uuid) to authenticated;

grant select on public.booths, public.users, public.assignments, public.families,
  public.voters, public.visits, public.visit_voters, public.forms, public.form_events,
  public.login_requests, public.audit_log to authenticated;
grant insert, update, delete on public.booths, public.assignments to authenticated;
grant insert, update on public.users, public.families, public.voters to authenticated;

-- Admins: everything they have a grant for.
create policy admin_all on public.booths         for all to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy admin_all on public.users          for all to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy admin_all on public.assignments    for all to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy admin_all on public.families       for all to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy admin_all on public.voters         for all to authenticated using ((select private.is_admin())) with check ((select private.is_admin()));
create policy admin_read on public.visits         for select to authenticated using ((select private.is_admin()));
create policy admin_read on public.visit_voters   for select to authenticated using ((select private.is_admin()));
create policy admin_read on public.forms          for select to authenticated using ((select private.is_admin()));
create policy admin_read on public.form_events    for select to authenticated using ((select private.is_admin()));
create policy admin_read on public.login_requests for select to authenticated using ((select private.is_admin()));
create policy admin_read on public.audit_log      for select to authenticated using ((select private.is_admin()));

-- Field users: their own profile, their own booths, and nothing else.
create policy self_read on public.users for select to authenticated
  using (id = (select private.current_user_id()));

create policy member_read on public.booths for select to authenticated
  using ((select private.current_user_id()) is not null);

create policy own_read on public.assignments for select to authenticated
  using (user_id = (select private.current_user_id()));

create policy scoped_read on public.families for select to authenticated
  using (private.can_see_family(part_no, section_no, assigned_user_id));

-- Child rows follow their parent: visible only if the family is visible.
create policy scoped_read on public.voters for select to authenticated
  using (exists (select 1 from public.families f where f.id = voters.family_id));

create policy scoped_read on public.visits for select to authenticated
  using (exists (select 1 from public.families f where f.id = visits.family_id));

create policy scoped_read on public.visit_voters for select to authenticated
  using (exists (select 1 from public.visits v where v.id = visit_voters.visit_id));

create policy scoped_read on public.forms for select to authenticated
  using (exists (select 1 from public.voters v where v.id = forms.voter_id));

create policy scoped_read on public.form_events for select to authenticated
  using (exists (select 1 from public.forms f where f.id = form_events.form_id));

-- ---------------------------------------------------------------------------
-- Device-approval login
-- ---------------------------------------------------------------------------

-- Step 1 (phone, not signed in): ask to sign in as a registered mobile number.
-- Returns a 4-digit code that the admin sees next to the request.
create function public.request_login(
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

  return jsonb_build_object('ok', true, 'request_id', v_id, 'match_code', v_code, 'name', v_user.name);
end
$$;

-- Step 2 (admin website): approve or reject.
create function public.decide_login_request(p_request_id uuid, p_approve boolean) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_admin uuid := private.current_user_id();
  v_req   public.login_requests;
begin
  if not private.is_admin() then
    raise exception 'admin only' using errcode = '42501';
  end if;

  update public.login_requests
  set status = case when p_approve then 'approved' else 'rejected' end,
      decided_at = now(), decided_by = v_admin
  where id = p_request_id and status = 'pending' and created_at > now() - interval '24 hours'
  returning * into v_req;

  if not found then
    return jsonb_build_object('ok', false, 'code', 'NOT_PENDING');
  end if;

  perform private.audit(
    case when p_approve then 'approve_login' else 'reject_login' end,
    'login_requests', v_req.id::text,
    jsonb_build_object('user_id', v_req.user_id, 'device_id', v_req.device_id));

  return jsonb_build_object('ok', true, 'status', v_req.status);
end
$$;

-- Step 3 is the login-status Edge Function: the phone polls it with its secret
-- and, once approved, receives a session. These three functions back it and
-- are callable by the service role only.

create function public.login_request_peek(p_request_id uuid, p_device_secret text) returns jsonb
language plpgsql security definer set search_path = ''
as $$
declare
  v_req  public.login_requests;
  v_user public.users;
begin
  select * into v_req from public.login_requests
  where id = p_request_id
    and secret_hash = encode(extensions.digest(coalesce(p_device_secret, ''), 'sha256'), 'hex');
  if not found then
    return jsonb_build_object('status', 'unknown');
  end if;

  if v_req.status = 'pending' and v_req.created_at < now() - interval '24 hours' then
    update public.login_requests set status = 'expired' where id = v_req.id;
    return jsonb_build_object('status', 'expired');
  end if;
  if v_req.status = 'approved' and v_req.decided_at < now() - interval '24 hours' then
    update public.login_requests set status = 'expired' where id = v_req.id;
    return jsonb_build_object('status', 'expired');
  end if;

  select * into v_user from public.users where id = v_req.user_id;
  if not v_user.is_active then
    return jsonb_build_object('status', 'rejected');
  end if;

  return jsonb_build_object(
    'status', v_req.status,
    'user', jsonb_build_object('id', v_user.id, 'name', v_user.name, 'role', v_user.role,
                               'mobile', v_user.mobile, 'auth_user_id', v_user.auth_user_id));
end
$$;

-- Claims an approved request exactly once and binds the user to the new session.
create function public.login_request_consume(
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
      device_id = v_req.device_id, device_model = v_req.device_model, last_login_at = now()
  where id = v_req.user_id;

  insert into public.audit_log (user_id, action, entity, entity_id, detail)
  values (v_req.user_id, 'login', 'users', v_req.user_id::text,
          jsonb_build_object('device_id', v_req.device_id, 'request_id', v_req.id));

  return jsonb_build_object('ok', true);
end
$$;

-- First-admin setup: succeeds once, with the setup code, while no admin exists.
create function public.bootstrap_claim(p_code text) returns boolean
language plpgsql security definer set search_path = ''
as $$
begin
  if exists (select 1 from public.users where role = 'admin') then
    return false;
  end if;
  update private.bootstrap set used_at = now()
  where used_at is null and code_hash = encode(extensions.digest(coalesce(p_code, ''), 'sha256'), 'hex');
  return found;
end
$$;

create function public.bootstrap_release() returns void
language sql security definer set search_path = ''
as $$
  update private.bootstrap set used_at = null
  where not exists (select 1 from public.users where role = 'admin')
$$;

revoke execute on function
  public.request_login(text, text, text, text),
  public.decide_login_request(uuid, boolean),
  public.login_request_peek(uuid, text),
  public.login_request_consume(uuid, text, uuid, uuid),
  public.bootstrap_claim(text),
  public.bootstrap_release()
  from public, anon, authenticated;

grant execute on function public.request_login(text, text, text, text) to anon, authenticated;
grant execute on function public.decide_login_request(uuid, boolean) to authenticated;
grant execute on function
  public.login_request_peek(uuid, text),
  public.login_request_consume(uuid, text, uuid, uuid),
  public.bootstrap_claim(text),
  public.bootstrap_release()
  to service_role;
