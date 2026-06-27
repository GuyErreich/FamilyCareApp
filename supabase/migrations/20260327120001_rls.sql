-- Row Level Security — family-scoped access

alter table public.families enable row level security;
alter table public.profiles enable row level security;
alter table public.family_members enable row level security;
alter table public.shifts enable row level security;
alter table public.unavailabilities enable row level security;
alter table public.notifications enable row level security;
alter table public.family_settings enable row level security;
alter table public.push_subscriptions enable row level security;

-- profiles
create policy profiles_select_own on public.profiles
  for select to authenticated
  using (id = auth.uid());

create policy profiles_select_family on public.profiles
  for select to authenticated
  using (family_id is not null and family_id = public.my_family_id());

create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- families
create policy families_select on public.families
  for select to authenticated
  using (public.is_family_member(id));

create policy families_insert on public.families
  for insert to authenticated
  with check (true);

create policy families_update on public.families
  for update to authenticated
  using (public.is_family_member(id))
  with check (public.is_family_member(id));

-- family_members
create policy family_members_all on public.family_members
  for all to authenticated
  using (public.is_family_member(family_id))
  with check (public.is_family_member(family_id));

-- shifts
create policy shifts_all on public.shifts
  for all to authenticated
  using (public.is_family_member(family_id))
  with check (public.is_family_member(family_id));

-- unavailabilities
create policy unavailabilities_all on public.unavailabilities
  for all to authenticated
  using (public.is_family_member(family_id))
  with check (public.is_family_member(family_id));

-- notifications
create policy notifications_select_own on public.notifications
  for select to authenticated
  using (user_id = auth.uid());

create policy notifications_insert on public.notifications
  for insert to authenticated
  with check (public.is_family_member(family_id));

create policy notifications_update_own on public.notifications
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- family_settings
create policy family_settings_all on public.family_settings
  for all to authenticated
  using (public.is_family_member(family_id))
  with check (public.is_family_member(family_id));

-- push_subscriptions
create policy push_subscriptions_all on public.push_subscriptions
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());
