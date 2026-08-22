create index record_entities_role_idx
on public.record_entities(role);

create index record_relations_type_idx
on public.record_relations(relation_type);

create index entity_relations_type_idx
on public.entity_relations(relation_type);
