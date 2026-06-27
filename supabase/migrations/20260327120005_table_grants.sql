-- PostgREST requires table-level GRANTs; RLS alone is not enough.

grant usage on schema public to postgres, anon, authenticated, service_role;

grant select, insert, update, delete on table public.families to authenticated;
grant select, insert, update, delete on table public.profiles to authenticated;
grant select, insert, update, delete on table public.family_members to authenticated;
grant select, insert, update, delete on table public.shifts to authenticated;
grant select, insert, update, delete on table public.unavailabilities to authenticated;
grant select, insert, update, delete on table public.notifications to authenticated;
grant select, insert, update, delete on table public.family_settings to authenticated;
grant select, insert, update, delete on table public.push_subscriptions to authenticated;

grant all on table public.families to service_role;
grant all on table public.profiles to service_role;
grant all on table public.family_members to service_role;
grant all on table public.shifts to service_role;
grant all on table public.unavailabilities to service_role;
grant all on table public.notifications to service_role;
grant all on table public.family_settings to service_role;
grant all on table public.push_subscriptions to service_role;

alter default privileges in schema public
  grant select, insert, update, delete on tables to authenticated;

alter default privileges in schema public
  grant all on tables to service_role;
