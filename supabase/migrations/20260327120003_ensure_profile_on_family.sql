-- Ensure profile row exists before create/join family (Google OAuth users may lack a profile row).

create or replace function public.ensure_profile_for_auth_user()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  insert into public.profiles (id, email, display_name, avatar_url)
  select
    u.id,
    coalesce(u.email, ''),
    coalesce(u.raw_user_meta_data ->> 'full_name', u.raw_user_meta_data ->> 'name'),
    u.raw_user_meta_data ->> 'avatar_url'
  from auth.users u
  where u.id = auth.uid()
  on conflict (id) do nothing;
end;
$$;

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

  perform public.ensure_profile_for_auth_user();

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

  perform public.ensure_profile_for_auth_user();

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

grant execute on function public.ensure_profile_for_auth_user() to authenticated;
