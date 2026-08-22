revoke all on table public.brain_owners from anon;
revoke all on table public.sources from anon;
revoke all on table public.ingestion_batches from anon;
revoke all on table public.entities from anon;
revoke all on table public.entity_aliases from anon;
revoke all on table public.records from anon;
revoke all on table public.record_sources from anon;
revoke all on table public.record_entities from anon;
revoke all on table public.entity_relations from anon;
revoke all on table public.record_relations from anon;
revoke all on table public.audit_log from anon;

revoke insert, delete, truncate, references, trigger on table public.brain_owners from authenticated;
revoke references, trigger on table public.sources from authenticated;
revoke references, trigger on table public.ingestion_batches from authenticated;
revoke references, trigger on table public.entities from authenticated;
revoke references, trigger on table public.entity_aliases from authenticated;
revoke references, trigger on table public.records from authenticated;
revoke references, trigger on table public.record_sources from authenticated;
revoke references, trigger on table public.record_entities from authenticated;
revoke references, trigger on table public.entity_relations from authenticated;
revoke references, trigger on table public.record_relations from authenticated;
revoke references, trigger on table public.audit_log from authenticated;

grant select on table public.brain_owners to authenticated;
grant update (display_name, metadata) on table public.brain_owners to authenticated;
