create or replace function public.audit_safe_json(p_data jsonb)
returns jsonb
language plpgsql
immutable
set search_path = public
as $$
declare
  v_result jsonb := p_data;
begin
  if v_result is null then
    return null;
  end if;

  if v_result ? 'normalized_content' then
    v_result := (v_result - 'normalized_content') || jsonb_build_object(
      'normalized_content_hash', encode(digest(coalesce(p_data->>'normalized_content',''), 'sha256'), 'hex')
    );
  end if;

  if v_result ? 'raw_excerpt' then
    v_result := (v_result - 'raw_excerpt') || jsonb_build_object(
      'raw_excerpt_hash', encode(digest(coalesce(p_data->>'raw_excerpt',''), 'sha256'), 'hex')
    );
  end if;

  if v_result ? 'attributes' then
    v_result := (v_result - 'attributes') || jsonb_build_object(
      'attributes_hash', encode(digest(coalesce((p_data->'attributes')::text,''), 'sha256'), 'hex')
    );
  end if;

  if v_result ? 'metadata' then
    v_result := (v_result - 'metadata') || jsonb_build_object(
      'metadata_hash', encode(digest(coalesce((p_data->'metadata')::text,''), 'sha256'), 'hex')
    );
  end if;

  return v_result;
end;
$$;

revoke all on function public.audit_safe_json(jsonb) from public, anon, authenticated;

create or replace function public.write_audit_log()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_owner_id uuid;
  v_object_id uuid;
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
    case when tg_op in ('UPDATE','DELETE') then public.audit_safe_json(to_jsonb(old)) else null end,
    case when tg_op in ('INSERT','UPDATE') then public.audit_safe_json(to_jsonb(new)) else null end,
    null
  );

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

revoke all on function public.write_audit_log() from public, anon, authenticated;

create index audit_log_owner_source_idx on public.audit_log(owner_id, source_id);
create index entity_aliases_owner_source_idx on public.entity_aliases(owner_id, source_id);
create index entity_relations_owner_source_ref_idx on public.entity_relations(owner_id, source_id);
create index ingestion_batches_owner_source_idx on public.ingestion_batches(owner_id, source_id);
create index record_relations_owner_source_ref_idx on public.record_relations(owner_id, source_id);
create index record_sources_owner_record_idx on public.record_sources(owner_id, record_id);
create index record_sources_owner_source_idx on public.record_sources(owner_id, source_id);
create index records_owner_batch_idx on public.records(owner_id, ingestion_batch_id);

drop policy if exists brain_owners_select on public.brain_owners;
create policy brain_owners_select on public.brain_owners
for select to authenticated
using ((select auth.uid()) = auth_user_id);

drop policy if exists brain_owners_update on public.brain_owners;
create policy brain_owners_update on public.brain_owners
for update to authenticated
using ((select auth.uid()) = auth_user_id)
with check ((select auth.uid()) = auth_user_id);