alter table public.brain_owners
add column if not exists is_primary boolean not null default false;

create unique index if not exists brain_owners_one_primary_uidx
on public.brain_owners(is_primary)
where is_primary = true;

update public.brain_owners
set is_primary = true
where id = (
  select id
  from public.brain_owners
  order by created_at
  limit 1
)
and not exists (
  select 1 from public.brain_owners where is_primary = true
);

create or replace function public.get_primary_brain_identity()
returns jsonb
language plpgsql
stable
security definer
set search_path = public, extensions
as $$
declare
  v_owner_id uuid;
  v_self_id uuid;
  v_display_name text;
begin
  select id, display_name
  into v_owner_id, v_display_name
  from public.brain_owners
  where is_primary = true
  limit 1;

  if v_owner_id is null then
    raise exception 'primary brain owner is not configured';
  end if;

  select id
  into v_self_id
  from public.entities
  where owner_id = v_owner_id
    and is_self = true
    and lifecycle <> 'deleted'
  limit 1;

  if v_self_id is null then
    raise exception 'self entity is not configured for primary brain owner';
  end if;

  return jsonb_build_object(
    'owner_id', v_owner_id,
    'self_entity_id', v_self_id,
    'display_name', v_display_name
  );
end;
$$;

revoke all on function public.get_primary_brain_identity() from public, anon, authenticated;
grant execute on function public.get_primary_brain_identity() to service_role;
