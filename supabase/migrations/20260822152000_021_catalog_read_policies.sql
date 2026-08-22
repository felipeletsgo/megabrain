create policy record_entity_role_catalog_read
on public.record_entity_role_catalog
for select
to anon, authenticated
using (active = true);

create policy record_relation_type_catalog_read
on public.record_relation_type_catalog
for select
to anon, authenticated
using (active = true);

create policy entity_relation_type_catalog_read
on public.entity_relation_type_catalog
for select
to anon, authenticated
using (active = true);
