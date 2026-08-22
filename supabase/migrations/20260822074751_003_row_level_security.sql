alter table public.brain_owners enable row level security;
alter table public.sources enable row level security;
alter table public.ingestion_batches enable row level security;
alter table public.entities enable row level security;
alter table public.entity_aliases enable row level security;
alter table public.records enable row level security;
alter table public.record_sources enable row level security;
alter table public.record_entities enable row level security;
alter table public.entity_relations enable row level security;
alter table public.record_relations enable row level security;
alter table public.audit_log enable row level security;

create or replace function public.can_access_owner(target_owner_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.brain_owners o
    where o.id = target_owner_id
      and o.auth_user_id = auth.uid()
  );
$$;

revoke all on function public.can_access_owner(uuid) from public;
grant execute on function public.can_access_owner(uuid) to authenticated;

create policy brain_owners_select on public.brain_owners
for select to authenticated
using (auth.uid() = auth_user_id);

create policy brain_owners_update on public.brain_owners
for update to authenticated
using (auth.uid() = auth_user_id)
with check (auth.uid() = auth_user_id);

create policy sources_select on public.sources for select to authenticated using (public.can_access_owner(owner_id));
create policy sources_insert on public.sources for insert to authenticated with check (public.can_access_owner(owner_id));
create policy sources_update on public.sources for update to authenticated using (public.can_access_owner(owner_id)) with check (public.can_access_owner(owner_id));

create policy ingestion_batches_select on public.ingestion_batches for select to authenticated using (public.can_access_owner(owner_id));
create policy ingestion_batches_insert on public.ingestion_batches for insert to authenticated with check (public.can_access_owner(owner_id));
create policy ingestion_batches_update on public.ingestion_batches for update to authenticated using (public.can_access_owner(owner_id)) with check (public.can_access_owner(owner_id));

create policy entities_select on public.entities for select to authenticated using (public.can_access_owner(owner_id));
create policy entities_insert on public.entities for insert to authenticated with check (public.can_access_owner(owner_id));
create policy entities_update on public.entities for update to authenticated using (public.can_access_owner(owner_id)) with check (public.can_access_owner(owner_id));

create policy entity_aliases_select on public.entity_aliases for select to authenticated using (public.can_access_owner(owner_id));
create policy entity_aliases_insert on public.entity_aliases for insert to authenticated with check (public.can_access_owner(owner_id));
create policy entity_aliases_update on public.entity_aliases for update to authenticated using (public.can_access_owner(owner_id)) with check (public.can_access_owner(owner_id));

create policy records_select on public.records for select to authenticated using (public.can_access_owner(owner_id));
create policy records_insert on public.records for insert to authenticated with check (public.can_access_owner(owner_id));
create policy records_update on public.records for update to authenticated using (public.can_access_owner(owner_id)) with check (public.can_access_owner(owner_id));

create policy record_sources_select on public.record_sources for select to authenticated using (public.can_access_owner(owner_id));
create policy record_sources_insert on public.record_sources for insert to authenticated with check (public.can_access_owner(owner_id));
create policy record_sources_update on public.record_sources for update to authenticated using (public.can_access_owner(owner_id)) with check (public.can_access_owner(owner_id));

create policy record_entities_select on public.record_entities for select to authenticated using (public.can_access_owner(owner_id));
create policy record_entities_insert on public.record_entities for insert to authenticated with check (public.can_access_owner(owner_id));
create policy record_entities_update on public.record_entities for update to authenticated using (public.can_access_owner(owner_id)) with check (public.can_access_owner(owner_id));

create policy entity_relations_select on public.entity_relations for select to authenticated using (public.can_access_owner(owner_id));
create policy entity_relations_insert on public.entity_relations for insert to authenticated with check (public.can_access_owner(owner_id));
create policy entity_relations_update on public.entity_relations for update to authenticated using (public.can_access_owner(owner_id)) with check (public.can_access_owner(owner_id));

create policy record_relations_select on public.record_relations for select to authenticated using (public.can_access_owner(owner_id));
create policy record_relations_insert on public.record_relations for insert to authenticated with check (public.can_access_owner(owner_id));
create policy record_relations_update on public.record_relations for update to authenticated using (public.can_access_owner(owner_id)) with check (public.can_access_owner(owner_id));

create policy audit_log_select on public.audit_log
for select to authenticated
using (public.can_access_owner(owner_id));

revoke update, delete on public.audit_log from anon, authenticated;
revoke delete on public.brain_owners, public.sources, public.ingestion_batches, public.entities, public.entity_aliases, public.records, public.record_sources, public.record_entities, public.entity_relations, public.record_relations from anon, authenticated;