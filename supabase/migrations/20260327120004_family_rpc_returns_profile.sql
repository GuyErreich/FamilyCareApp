-- create/join family must verify profile update and return the updated profile row.
-- Postgres requires DROP when changing a function's return type.

drop function if exists public.create_family(text, text);
drop function if exists public.join_family(text);

create function public.create_family(
  p_name text,
  p_grandpa_name text
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_family_id uuid;
  v_code text;
  v_profile public.profiles;
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

  if not found then
    raise exception 'Profile not found or not updated';
  end if;

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
  );

  insert into public.family_settings (family_id)
  values (v_family_id);

  select * into v_profile
  from public.profiles
  where id = auth.uid();

  return v_profile;
end;
$$;

create function public.join_family(p_invite_code text)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_family_id uuid;
  v_profile public.profiles;
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

  if not found then
    raise exception 'Profile not found or not updated';
  end if;

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

  select * into v_profile
  from public.profiles
  where id = auth.uid();

  return v_profile;
end;
$$;

create or replace function public.get_my_profile()
returns public.profiles
language sql
stable
security definer
set search_path = public
as $$
  select *
  from public.profiles
  where id = auth.uid();
$$;

grant execute on function public.create_family(text, text) to authenticated;
grant execute on function public.join_family(text) to authenticated;
grant execute on function public.get_my_profile() to authenticated;
