alter function public.ingest_memory_bundle(uuid, text, jsonb)
rename to ingest_memory_bundle_core;

revoke all on function public.ingest_memory_bundle_core(uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.ingest_memory_bundle_core(uuid, text, jsonb) to service_role;

create or replace function public.ingest_memory_bundle(
  p_owner_id uuid,
  p_idempotency_key text,
  p_bundle jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_result jsonb;
  v_was_completed boolean := false;
  v_relation jsonb;
  v_ref text;
  v_source_record_id uuid;
  v_target_record_id uuid;
  v_source_id uuid;
  v_record_map jsonb := '{}'::jsonb;
  v_cross_relations_created integer := 0;
begin
  select exists (
    select 1
    from public.ingestion_batches
    where owner_id = p_owner_id
      and idempotency_key = p_idempotency_key
      and batch_status = 'completed'
  ) into v_was_completed;

  v_result := public.ingest_memory_bundle_core(
    p_owner_id,
    p_idempotency_key,
    p_bundle - 'historical_record_relations'
  );

  if v_result->>'status' <> 'completed' then
    return v_result;
  end if;

  if v_was_completed then
    return v_result || jsonb_build_object('idempotent_replay', true);
  end if;

  v_record_map := coalesce(v_result->'record_map', '{}'::jsonb);
  v_source_id := nullif(v_result->>'source_id','')::uuid;

  if p_bundle ? 'historical_record_relations' then
    if jsonb_typeof(p_bundle->'historical_record_relations') <> 'array' then
      raise exception 'historical_record_relations must be an array';
    end if;

    for v_relation in
      select value from jsonb_array_elements(p_bundle->'historical_record_relations')
    loop
      if nullif(v_relation->>'relation_type','') is null then
        raise exception 'relation_type is required in historical_record_relations';
      end if;

      v_ref := nullif(v_relation->>'source_record','');
      if v_ref is null then
        raise exception 'source_record is required in historical_record_relations';
      end if;

      if v_record_map ? v_ref then
        v_source_record_id := (v_record_map->>v_ref)::uuid;
      else
        begin
          v_source_record_id := v_ref::uuid;
        exception when invalid_text_representation then
          raise exception 'unknown source_record reference: %', v_ref;
        end;

        if not exists (
          select 1 from public.records
          where owner_id = p_owner_id
            and id = v_source_record_id
            and lifecycle <> 'deleted'
        ) then
          raise exception 'source_record % is invalid for this owner', v_source_record_id;
        end if;
      end if;

      v_ref := nullif(v_relation->>'target_record','');
      if v_ref is null then
        raise exception 'target_record is required in historical_record_relations';
      end if;

      if v_record_map ? v_ref then
        v_target_record_id := (v_record_map->>v_ref)::uuid;
      else
        begin
          v_target_record_id := v_ref::uuid;
        exception when invalid_text_representation then
          raise exception 'unknown target_record reference: %', v_ref;
        end;

        if not exists (
          select 1 from public.records
          where owner_id = p_owner_id
            and id = v_target_record_id
            and lifecycle <> 'deleted'
        ) then
          raise exception 'target_record % is invalid for this owner', v_target_record_id;
        end if;
      end if;

      insert into public.record_relations(
        owner_id,
        source_record_id,
        target_record_id,
        relation_type,
        certainty,
        validity,
        lifecycle,
        source_id,
        attributes
      )
      values (
        p_owner_id,
        v_source_record_id,
        v_target_record_id,
        v_relation->>'relation_type',
        coalesce(nullif(v_relation->>'certainty',''),'confirmed'),
        coalesce(nullif(v_relation->>'validity',''),'current'),
        coalesce(nullif(v_relation->>'lifecycle',''),'active'),
        v_source_id,
        coalesce(v_relation->'attributes','{}'::jsonb)
      )
      on conflict do nothing;

      if found then
        v_cross_relations_created := v_cross_relations_created + 1;
      end if;
    end loop;
  end if;

  v_result := jsonb_set(
    v_result,
    '{counts,historical_record_relations_created}',
    to_jsonb(v_cross_relations_created),
    true
  );

  update public.ingestion_batches
  set result = v_result
  where owner_id = p_owner_id
    and idempotency_key = p_idempotency_key;

  return v_result;
end;
$$;

revoke all on function public.ingest_memory_bundle(uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.ingest_memory_bundle(uuid, text, jsonb) to service_role;
