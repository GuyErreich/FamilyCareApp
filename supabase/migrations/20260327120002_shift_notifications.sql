-- Shift change notifications (in-app) — ports functions/index.js behavior

create or replace function public.resolve_fallback_plan(
  chain uuid[],
  dropped_id uuid
)
returns table(primary_member_id uuid, backup_member_ids uuid[])
language plpgsql
as $$
declare
  without_dropped uuid[];
  drop_index integer;
  after_drop uuid[];
  before_drop uuid[];
begin
  without_dropped := array(select unnest(chain) except select dropped_id);

  if coalesce(array_length(without_dropped, 1), 0) = 0 then
    return query select null::uuid, '{}'::uuid[];
    return;
  end if;

  drop_index := array_position(chain, dropped_id);
  if drop_index is null then
    return query
      select without_dropped[1],
        without_dropped[2:coalesce(array_length(without_dropped, 1), 0)];
    return;
  end if;

  after_drop := array(
    select unnest(chain[drop_index + 1:coalesce(array_length(chain, 1), 0)])
    except select dropped_id
  );
  if coalesce(array_length(after_drop, 1), 0) > 0 then
    return query
      select after_drop[1],
        after_drop[2:coalesce(array_length(after_drop, 1), 0)];
    return;
  end if;

  before_drop := array(
    select unnest(chain[1:drop_index - 1])
    except select dropped_id
  );
  if coalesce(array_length(before_drop, 1), 0) = 0 then
    return query select null::uuid, '{}'::uuid[];
    return;
  end if;

  return query
    select before_drop[1],
      before_drop[2:coalesce(array_length(before_drop, 1), 0)];
end;
$$;

create or replace function public.companion_name(p_member_id uuid, p_family_id uuid)
returns text
language sql
stable
as $$
  select coalesce(
    (select fm.name from public.family_members fm where fm.id = p_member_id),
    (select p.display_name from public.profiles p
     join public.family_members fm on fm.user_id = p.id
     where fm.id = p_member_id),
    'A companion'
  );
$$;

create or replace function public.format_shift_when(
  p_date date,
  p_start_hour integer,
  p_start_minute integer,
  p_duration_minutes integer
)
returns text
language plpgsql
as $$
declare
  v_start timestamptz;
  v_end timestamptz;
begin
  v_start := p_date + make_time(p_start_hour, p_start_minute, 0);
  v_end := v_start + (p_duration_minutes || ' minutes')::interval;
  return to_char(v_start, 'Dy Mon DD') || ' '
    || to_char(v_start, 'HH12:MI AM') || '–'
    || to_char(v_end, 'HH12:MI AM');
end;
$$;

create or replace function public.insert_notification(
  p_family_id uuid,
  p_user_id uuid,
  p_type text,
  p_shift_id uuid,
  p_title text,
  p_body text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.notifications (family_id, user_id, type, shift_id, title, body)
  values (p_family_id, p_user_id, p_type, p_shift_id, p_title, p_body);
end;
$$;

create or replace function public.notify_family_members(
  p_family_id uuid,
  p_shift_id uuid,
  p_title text,
  p_body text,
  p_type text,
  p_exclude_user_id uuid default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  r record;
begin
  for r in
    select id from public.profiles
    where family_id = p_family_id
      and (p_exclude_user_id is null or id <> p_exclude_user_id)
  loop
    perform public.insert_notification(
      p_family_id, r.id, p_type, p_shift_id, p_title, p_body
    );
  end loop;
end;
$$;

create or replace function public.resolve_recipient_user_id(p_member_id uuid)
returns uuid
language sql
stable
as $$
  select coalesce(
    (select user_id from public.family_members where id = p_member_id),
    null
  );
$$;

create or replace function public.handle_shift_opened(p_old public.shifts)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_chain uuid[];
  v_plan record;
  v_name text;
  v_when text;
  v_member_id uuid;
  v_user_id uuid;
  v_title text;
  v_body text;
  v_backup uuid;
begin
  select coverage_fallback_member_ids into v_chain
  from public.family_settings
  where family_id = p_old.family_id;

  v_name := public.companion_name(p_old.assigned_member_id, p_old.family_id);
  v_when := public.format_shift_when(
    p_old.shift_date, p_old.start_hour, p_old.start_minute, p_old.duration_minutes
  );

  select * into v_plan
  from public.resolve_fallback_plan(
    coalesce(v_chain, '{}'),
    p_old.assigned_member_id
  );

  if v_plan.primary_member_id is null
    and coalesce(array_length(v_plan.backup_member_ids, 1), 0) = 0 then
    perform public.notify_family_members(
      p_old.family_id,
      p_old.id,
      'Shift needs coverage',
      v_name || ' can''t make their shift on ' || v_when || '. Can you take it?',
      'shiftCancelled',
      public.resolve_recipient_user_id(p_old.assigned_member_id)
    );
    return;
  end if;

  v_member_id := v_plan.primary_member_id;
  v_user_id := public.resolve_recipient_user_id(v_member_id);
  if v_user_id is not null then
    perform public.insert_notification(
      p_old.family_id,
      v_user_id,
      'shiftNeedsCoverage',
      p_old.id,
      'You''re up next for coverage',
      v_name || ' can''t make their shift on ' || v_when
        || '. You''re first on the fallback plan — can you cover?'
    );
  end if;

  if v_plan.backup_member_ids is not null then
    foreach v_backup in array v_plan.backup_member_ids loop
      v_user_id := public.resolve_recipient_user_id(v_backup);
      if v_user_id is not null then
        perform public.insert_notification(
          p_old.family_id,
          v_user_id,
          'shiftNeedsCoverage',
          p_old.id,
          'Backup coverage needed',
          v_name || ' can''t make their shift on ' || v_when
            || '. You''re on the family backup list.'
        );
      end if;
    end loop;
  end if;
end;
$$;

create or replace function public.handle_shift_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'DELETE' then
    perform public.handle_shift_opened(old);
    return old;
  end if;

  if tg_op = 'INSERT' then
    perform public.notify_family_members(
      new.family_id,
      new.id,
      'New shift',
      'A new companion shift was created.',
      'shiftCreated'
    );
    return new;
  end if;

  if old.assigned_member_id is distinct from new.assigned_member_id then
    perform public.notify_family_members(
      new.family_id,
      new.id,
      'Companion changed',
      'A shift companion was updated.',
      'companionChanged'
    );
  else
    perform public.notify_family_members(
      new.family_id,
      new.id,
      'Shift updated',
      'A companion shift was updated.',
      'shiftUpdated'
    );
  end if;

  return new;
end;
$$;

create trigger shifts_notify_change
  after insert or update or delete on public.shifts
  for each row execute function public.handle_shift_change();
