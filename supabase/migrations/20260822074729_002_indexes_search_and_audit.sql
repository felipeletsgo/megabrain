create index entities_owner_type_idx on public.entities(owner_id, entity_type);
create index entities_owner_name_idx on public.entities(owner_id, lower(canonical_name));
create index entity_aliases_owner_alias_idx on public.entity_aliases(owner_id, lower(alias));
create index records_owner_type_idx on public.records(owner_id, record_type);
create index records_owner_date_idx on public.records(owner_id, record_date desc);
create index records_owner_occurred_idx on public.records(owner_id, occurred_at desc);
create index records_owner_lifecycle_idx on public.records(owner_id, lifecycle, validity);
create index records_attributes_gin_idx on public.records using gin(attributes);
create index records_metadata_gin_idx on public.records using gin(metadata);
create index record_entities_record_idx on public.record_entities(owner_id, record_id);
create index record_entities_entity_idx on public.record_entities(owner_id, entity_id);
create index entity_relations_source_idx on public.entity_relations(owner_id, source_entity_id, relation_type);
create index entity_relations_target_idx on public.entity_relations(owner_id, target_entity_id, relation_type);
create index record_relations_source_idx on public.record_relations(owner_id, source_record_id, relation_type);
create index record_relations_target_idx on public.record_relations(owner_id, target_record_id, relation_type);
create index sources_owner_type_idx on public.sources(owner_id, source_type);
create index ingestion_batches_owner_status_idx on public.ingestion_batches(owner_id, batch_status);
create index audit_log_owner_created_idx on public.audit_log(owner_id, created_at desc);

alter table public.records
add column search_document tsvector generated always as (
  setweight(to_tsvector('portuguese', coalesce(title,'')), 'A') ||
  setweight(to_tsvector('portuguese', coalesce(normalized_content,'')), 'B')
) stored;

create index records_search_document_gin_idx on public.records using gin(search_document);

create or replace function public.write_audit_log()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_owner_id uuid;
  v_object_id uuid;
  v_source_id uuid;
begin
  if tg_op = 'DELETE' then
    v_owner_id := old.owner_id;
    v_object_id := old.id;
  else
    v_owner_id := new.owner_id;
    v_object_id := new.id;
  end if;

  insert into public.audit_log(
    owner_id,
    object_type,
    object_id,
    operation,
    before_data,
    after_data,
    source_id
  ) values (
    v_owner_id,
    tg_table_name,
    v_object_id,
    lower(tg_op),
    case when tg_op in ('UPDATE','DELETE') then to_jsonb(old) else null end,
    case when tg_op in ('INSERT','UPDATE') then to_jsonb(new) else null end,
    v_source_id
  );

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

create trigger audit_sources before insert or update or delete on public.sources for each row execute function public.write_audit_log();
create trigger audit_entities before insert or update or delete on public.entities for each row execute function public.write_audit_log();
create trigger audit_entity_aliases before insert or update or delete on public.entity_aliases for each row execute function public.write_audit_log();
create trigger audit_records before insert or update or delete on public.records for each row execute function public.write_audit_log();
create trigger audit_record_sources before insert or update or delete on public.record_sources for each row execute function public.write_audit_log();
create trigger audit_record_entities before insert or update or delete on public.record_entities for each row execute function public.write_audit_log();
create trigger audit_entity_relations before insert or update or delete on public.entity_relations for each row execute function public.write_audit_log();
create trigger audit_record_relations before insert or update or delete on public.record_relations for each row execute function public.write_audit_log();

create or replace function public.prevent_audit_mutation()
returns trigger
language plpgsql
as $$
begin
  raise exception 'audit_log is append-only';
end;
$$;

create trigger audit_log_append_only
before update or delete on public.audit_log
for each row execute function public.prevent_audit_mutation();