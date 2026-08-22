create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.prevent_audit_mutation()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  raise exception 'audit_log is append-only';
end;
$$;

create or replace function public.can_access_owner(target_owner_id uuid)
returns boolean
language sql
stable
security invoker
set search_path = public
as $$
  select exists (
    select 1
    from public.brain_owners o
    where o.id = target_owner_id
      and o.auth_user_id = auth.uid()
  );
$$;

revoke all on function public.can_access_owner(uuid) from public, anon;
grant execute on function public.can_access_owner(uuid) to authenticated;

revoke all on function public.write_audit_log() from public, anon, authenticated;

revoke execute on function public.rls_auto_enable() from public, anon, authenticated;