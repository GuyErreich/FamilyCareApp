-- Family Care Scheduler — initial Postgres schema

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table public.families (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  grandpa_name text not null,
  invite_code text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  display_name text,
  family_id uuid references public.families (id) on delete set null,
  phone text,
  color_hex text not null default '#4A6741',
  avatar_url text,
  google_calendar_connected boolean not null default false,
  google_refresh_token text,
  schedule_days_showed integer not null default 3,
  created_at timestamptz not null default now()
);

create table public.family_members (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  user_id uuid references public.profiles (id) on delete set null,
  name text not null,
  phone text,
  color_hex text not null default '#4A6741',
  avatar_url text,
  role text not null default 'member',
  created_at timestamptz not null default now()
);

create table public.shifts (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  assigned_member_id uuid not null references public.family_members (id) on delete restrict,
  shift_date date not null,
  start_hour integer not null check (start_hour between 0 and 23),
  start_minute integer not null check (start_minute between 0 and 59),
  duration_minutes integer not null check (duration_minutes > 0),
  end_time timestamptz not null,
  notes text,
  reminder_offset_minutes integer[] not null default '{}',
  calendar_event_id text,
  status text not null default 'scheduled',
  repeat_rule jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.unavailabilities (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  member_id uuid not null references public.family_members (id) on delete cascade,
  block_date date not null,
  start_hour integer not null check (start_hour between 0 and 23),
  start_minute integer not null check (start_minute between 0 and 59),
  duration_minutes integer not null check (duration_minutes > 0),
  end_time timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  type text not null,
  shift_id uuid references public.shifts (id) on delete set null,
  title text not null,
  body text not null,
  read boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.family_settings (
  family_id uuid primary key references public.families (id) on delete cascade,
  coverage_fallback_member_ids uuid[] not null default '{}',
  updated_at timestamptz not null default now()
);

create table public.push_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  endpoint text not null,
  p256dh text not null,
  auth_key text not null,
  created_at timestamptz not null default now(),
  unique (user_id, endpoint)
);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

create index profiles_family_id_idx on public.profiles (family_id);
create index family_members_family_id_idx on public.family_members (family_id);
create index shifts_family_id_date_idx on public.shifts (family_id, shift_date);
create index unavailabilities_family_id_idx on public.unavailabilities (family_id);
create index notifications_user_id_created_idx on public.notifications (user_id, created_at desc);
create index families_invite_code_idx on public.families (invite_code);

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

create or replace function public.my_family_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select family_id from public.profiles where id = auth.uid();
$$;

create or replace function public.is_family_member(check_family_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and family_id = check_family_id
  );
$$;

create or replace function public.generate_invite_code()
returns text
language plpgsql
as $$
declare
  chars text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  result text := '';
  i integer;
begin
  for i in 1..6 loop
    result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
  end loop;
  return result;
end;
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name, avatar_url)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'),
    new.raw_user_meta_data ->> 'avatar_url'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger families_set_updated_at
  before update on public.families
  for each row execute function public.set_updated_at();

create trigger shifts_set_updated_at
  before update on public.shifts
  for each row execute function public.set_updated_at();

create trigger unavailabilities_set_updated_at
  before update on public.unavailabilities
  for each row execute function public.set_updated_at();

create trigger family_settings_set_updated_at
  before update on public.family_settings
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- RPC: create / join family
-- ---------------------------------------------------------------------------

create or replace function public.create_family(
  p_name text,
  p_grandpa_name text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_family_id uuid;
  v_code text;
  v_member_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  loop
    v_code := public.generate_invite_code();
    exit when not exists (select 1 from public.families where invite_code = v_code);
  end loop;

  insert into public.families (name, grandpa_name, invite_code)
  values (trim(p_name), trim(p_grandpa_name), v_code)
  returning id into v_family_id;

  update public.profiles
  set family_id = v_family_id
  where id = auth.uid();

  insert into public.family_members (family_id, user_id, name, color_hex, role)
  values (
    v_family_id,
    auth.uid(),
    coalesce(
      (select display_name from public.profiles where id = auth.uid()),
      (select email from public.profiles where id = auth.uid())
    ),
    coalesce((select color_hex from public.profiles where id = auth.uid()), '#4A6741'),
    'owner'
  )
  returning id into v_member_id;

  insert into public.family_settings (family_id)
  values (v_family_id);

  return v_family_id;
end;
$$;

create or replace function public.join_family(p_invite_code text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_family_id uuid;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  select id into v_family_id
  from public.families
  where invite_code = upper(trim(p_invite_code));

  if v_family_id is null then
    raise exception 'Invalid invite code';
  end if;

  update public.profiles
  set family_id = v_family_id
  where id = auth.uid();

  insert into public.family_members (family_id, user_id, name, color_hex, role)
  values (
    v_family_id,
    auth.uid(),
    coalesce(
      (select display_name from public.profiles where id = auth.uid()),
      (select email from public.profiles where id = auth.uid())
    ),
    coalesce((select color_hex from public.profiles where id = auth.uid()), '#4A6741'),
    'member'
  );

  return v_family_id;
end;
$$;

grant execute on function public.create_family(text, text) to authenticated;
grant execute on function public.join_family(text) to authenticated;
