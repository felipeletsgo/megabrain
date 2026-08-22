revoke insert, update, delete, truncate on table public.sources from anon, authenticated;
revoke insert, update, delete, truncate on table public.ingestion_batches from anon, authenticated;
revoke insert, update, delete, truncate on table public.entities from anon, authenticated;
revoke insert, update, delete, truncate on table public.entity_aliases from anon, authenticated;
revoke insert, update, delete, truncate on table public.records from anon, authenticated;
revoke insert, update, delete, truncate on table public.record_sources from anon, authenticated;
revoke insert, update, delete, truncate on table public.record_entities from anon, authenticated;
revoke insert, update, delete, truncate on table public.entity_relations from anon, authenticated;
revoke insert, update, delete, truncate on table public.record_relations from anon, authenticated;
revoke insert, update, delete, truncate on table public.audit_log from anon, authenticated;

revoke update on table public.brain_owners from anon, authenticated;
grant update (display_name, metadata) on table public.brain_owners to authenticated;
