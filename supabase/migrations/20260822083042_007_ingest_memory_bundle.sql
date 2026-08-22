alter table public.ingestion_batches
add column if not exists result jsonb;

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
  v_batch_id uuid;
  v_existing_status text;
  v_existing_result jsonb;
  v_source_id uuid;
  v_source jsonb;
  v_entity jsonb;
  v_record jsonb;
  v_link jsonb;
  v_relation jsonb;
  v_entity_id uuid;
  v_record_id uuid;
  v_source_record_id uuid;
  v_target_record_id uuid;
  v_source_entity_id uuid;
  v_target_entity_id uuid;
  v_entity_map jsonb := '{}'::jsonb;
  v_record_map jsonb := '{}'::jsonb;
  v_entities_created integer := 0;
  v_records_created integer := 0;
  v_entity_links_created integer := 0;
  v_record_relations_created integer := 0;
  v_entity_relations_created integer := 0;
  v_result jsonb;
  v_client_key text;
  v_ref text;
  v_self_id uuid;
  v_source_external_id text;
  v_source_type text;
begin
  if p_owner_id is null then
    raise exception 'owner_id is required';
  end if;

  if p_idempotency_key is null or btrim(p_idempotency_key) = '' then
    raise exception 'idempotency_key is required';
  end if;

  if p_bundle is null or jsonb_typeof(p_bundle) <> 'object' then
    raise exception 'bundle must be a JSON object';
  end if;

  if not exists (select 1 from public.brain_owners where id = p_owner_id) then
    raise exception 'owner does not exist';
  end if;

  select id
  into v_self_id
  from public.entities
  where owner_id = p_owner_id
    and is_self = true
    and lifecycle <> 'deleted'
  limit 1;

  if v_self_id is null then
    raise exception 'self entity does not exist for owner';
  end if;

  select id, batch_status, result
  into v_batch_id, v_existing_status, v_existing_result
  from public.ingestion_batches
  where owner_id = p_owner_id
    and idempotency_key = p_idempotency_key
  for update;

  if v_batch_id is not null and v_existing_status = 'completed' then
    return coalesce(v_existing_result, jsonb_build_object(
      'status','completed',
      'batch_id',v_batch_id,
      'idempotent_replay',true
    ));
  end if;

  if v_batch_id is null then
    insert into public.ingestion_batches(owner_id, idempotency_key, batch_status, metadata)
    values (p_owner_id, p_idempotency_key, 'pending', coalesce(p_bundle->'batch_metadata','{}'::jsonb))
    returning id into v_batch_id;
  else
    update public.ingestion_batches
    set batch_status = 'pending', completed_at = null, result = null
    where id = v_batch_id;
  end if;

  begin
    v_source := p_bundle->'source';

    if v_source is not null and jsonb_typeof(v_source) = 'object' then
      v_source_type := coalesce(nullif(v_source->>'source_type',''), 'conversation');
      v_source_external_id := nullif(v_source->>'external_id','');

      if v_source_external_id is not null then
        select id
        into v_source_id
        from public.sources
        where owner_id = p_owner_id
          and source_type = v_source_type
          and external_id = v_source_external_id
        limit 1;
      end if;

      if v_source_id is null then
        insert into public.sources(
          owner_id,
          source_type,
          external_id,
          uri,
          title,
          raw_excerpt,
          content_hash,
          captured_at,
          metadata
        )
        values (
          p_owner_id,
          v_source_type,
          v_source_external_id,
          nullif(v_source->>'uri',''),
          nullif(v_source->>'title',''),
          v_source->>'raw_excerpt',
          coalesce(nullif(v_source->>'content_hash',''),
            case when v_source ? 'raw_excerpt'
              then encode(extensions.digest(coalesce(v_source->>'raw_excerpt',''), 'sha256'), 'hex')
              else null end),
          coalesce((v_source->>'captured_at')::timestamptz, now()),
          coalesce(v_source->'metadata','{}'::jsonb)
        )
        returning id into v_source_id;
      end if;

      update public.ingestion_batches
      set source_id = v_source_id
      where id = v_batch_id;
    end if;

    v_entity_map := jsonb_build_object('self', v_self_id::text);

    if p_bundle ? 'entities' then
      if jsonb_typeof(p_bundle->'entities') <> 'array' then
        raise exception 'entities must be an array';
      end if;

      for v_entity in select value from jsonb_array_elements(p_bundle->'entities') loop
        v_client_key := nullif(v_entity->>'client_key','');
        if v_client_key is null then
          raise exception 'entity.client_key is required';
        end if;

        if v_client_key = 'self' then
          v_entity_map := v_entity_map || jsonb_build_object(v_client_key, v_self_id::text);
          continue;
        end if;

        if v_entity ? 'entity_id' and nullif(v_entity->>'entity_id','') is not null then
          v_entity_id := (v_entity->>'entity_id')::uuid;
          if not exists (
            select 1 from public.entities
            where owner_id = p_owner_id and id = v_entity_id and lifecycle <> 'deleted'
          ) then
            raise exception 'entity_id % is invalid for this owner', v_entity_id;
          end if;
        else
          if nullif(v_entity->>'entity_type','') is null then
            raise exception 'entity_type is required for new entity %', v_client_key;
          end if;
          if nullif(v_entity->>'canonical_name','') is null then
            raise exception 'canonical_name is required for new entity %', v_client_key;
          end if;

          insert into public.entities(
            owner_id,
            entity_type,
            canonical_name,
            description,
            is_self,
            lifecycle,
            attributes,
            valid_from,
            valid_to
          )
          values (
            p_owner_id,
            v_entity->>'entity_type',
            v_entity->>'canonical_name',
            nullif(v_entity->>'description',''),
            false,
            coalesce(nullif(v_entity->>'lifecycle',''),'active'),
            coalesce(v_entity->'attributes','{}'::jsonb),
            nullif(v_entity->>'valid_from','')::timestamptz,
            nullif(v_entity->>'valid_to','')::timestamptz
          )
          returning id into v_entity_id;

          v_entities_created := v_entities_created + 1;

          if v_source_id is not null then
            insert into public.entity_aliases(owner_id, entity_id, alias, alias_type, source_id)
            select p_owner_id, v_entity_id, a.value->>'alias', nullif(a.value->>'alias_type',''), v_source_id
            from jsonb_array_elements(coalesce(v_entity->'aliases','[]'::jsonb)) a(value)
            where nullif(a.value->>'alias','') is not null
            on conflict do nothing;
          else
            insert into public.entity_aliases(owner_id, entity_id, alias, alias_type)
            select p_owner_id, v_entity_id, a.value->>'alias', nullif(a.value->>'alias_type','')
            from jsonb_array_elements(coalesce(v_entity->'aliases','[]'::jsonb)) a(value)
            where nullif(a.value->>'alias','') is not null
            on conflict do nothing;
          end if;
        end if;

        v_entity_map := v_entity_map || jsonb_build_object(v_client_key, v_entity_id::text);
      end loop;
    end if;

    if p_bundle ? 'records' then
      if jsonb_typeof(p_bundle->'records') <> 'array' then
        raise exception 'records must be an array';
      end if;

      for v_record in select value from jsonb_array_elements(p_bundle->'records') loop
        v_client_key := nullif(v_record->>'client_key','');
        if v_client_key is null then
          raise exception 'record.client_key is required';
        end if;
        if nullif(v_record->>'record_type','') is null then
          raise exception 'record_type is required for record %', v_client_key;
        end if;

        insert into public.records(
          owner_id,
          ingestion_batch_id,
          record_type,
          title,
          normalized_content,
          domain_status,
          certainty,
          validity,
          lifecycle,
          record_date,
          occurred_at,
          occurred_end_at,
          valid_from,
          valid_to,
          idempotency_key,
          attributes,
          metadata
        )
        values (
          p_owner_id,
          v_batch_id,
          v_record->>'record_type',
          nullif(v_record->>'title',''),
          v_record->>'normalized_content',
          nullif(v_record->>'domain_status',''),
          coalesce(nullif(v_record->>'certainty',''),'confirmed'),
          coalesce(nullif(v_record->>'validity',''),'current'),
          coalesce(nullif(v_record->>'lifecycle',''),'active'),
          nullif(v_record->>'record_date','')::date,
          nullif(v_record->>'occurred_at','')::timestamptz,
          nullif(v_record->>'occurred_end_at','')::timestamptz,
          nullif(v_record->>'valid_from','')::timestamptz,
          nullif(v_record->>'valid_to','')::timestamptz,
          p_idempotency_key || ':' || v_client_key,
          coalesce(v_record->'attributes','{}'::jsonb),
          coalesce(v_record->'metadata','{}'::jsonb)
        )
        returning id into v_record_id;

        v_records_created := v_records_created + 1;
        v_record_map := v_record_map || jsonb_build_object(v_client_key, v_record_id::text);

        if v_source_id is not null then
          insert into public.record_sources(owner_id, record_id, source_id, source_role)
          values (
            p_owner_id,
            v_record_id,
            v_source_id,
            coalesce(nullif(v_record->>'source_role',''),'primary')
          )
          on conflict do nothing;
        end if;
      end loop;
    end if;

    if p_bundle ? 'record_entities' then
      if jsonb_typeof(p_bundle->'record_entities') <> 'array' then
        raise exception 'record_entities must be an array';
      end if;

      for v_link in select value from jsonb_array_elements(p_bundle->'record_entities') loop
        v_ref := nullif(v_link->>'record','');
        if v_ref is null or not (v_record_map ? v_ref) then
          raise exception 'unknown record reference in record_entities: %', v_ref;
        end if;
        v_record_id := (v_record_map->>v_ref)::uuid;

        v_ref := nullif(v_link->>'entity','');
        if v_ref is null or not (v_entity_map ? v_ref) then
          raise exception 'unknown entity reference in record_entities: %', v_ref;
        end if;
        v_entity_id := (v_entity_map->>v_ref)::uuid;

        insert into public.record_entities(owner_id, record_id, entity_id, role, attributes)
        values (
          p_owner_id,
          v_record_id,
          v_entity_id,
          coalesce(nullif(v_link->>'role',''),'related'),
          coalesce(v_link->'attributes','{}'::jsonb)
        )
        on conflict do nothing;

        v_entity_links_created := v_entity_links_created + 1;
      end loop;
    end if;

    if p_bundle ? 'record_relations' then
      if jsonb_typeof(p_bundle->'record_relations') <> 'array' then
        raise exception 'record_relations must be an array';
      end if;

      for v_relation in select value from jsonb_array_elements(p_bundle->'record_relations') loop
        v_ref := nullif(v_relation->>'source_record','');
        if v_ref is null or not (v_record_map ? v_ref) then
          raise exception 'unknown source_record reference: %', v_ref;
        end if;
        v_source_record_id := (v_record_map->>v_ref)::uuid;

        v_ref := nullif(v_relation->>'target_record','');
        if v_ref is null or not (v_record_map ? v_ref) then
          raise exception 'unknown target_record reference: %', v_ref;
        end if;
        v_target_record_id := (v_record_map->>v_ref)::uuid;

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

        v_record_relations_created := v_record_relations_created + 1;
      end loop;
    end if;

    if p_bundle ? 'entity_relations' then
      if jsonb_typeof(p_bundle->'entity_relations') <> 'array' then
        raise exception 'entity_relations must be an array';
      end if;

      for v_relation in select value from jsonb_array_elements(p_bundle->'entity_relations') loop
        v_ref := nullif(v_relation->>'source_entity','');
        if v_ref is null or not (v_entity_map ? v_ref) then
          raise exception 'unknown source_entity reference: %', v_ref;
        end if;
        v_source_entity_id := (v_entity_map->>v_ref)::uuid;

        v_ref := nullif(v_relation->>'target_entity','');
        if v_ref is null or not (v_entity_map ? v_ref) then
          raise exception 'unknown target_entity reference: %', v_ref;
        end if;
        v_target_entity_id := (v_entity_map->>v_ref)::uuid;

        insert into public.entity_relations(
          owner_id,
          source_entity_id,
          target_entity_id,
          relation_type,
          domain_status,
          certainty,
          validity,
          lifecycle,
          valid_from,
          valid_to,
          source_id,
          attributes
        )
        values (
          p_owner_id,
          v_source_entity_id,
          v_target_entity_id,
          v_relation->>'relation_type',
          nullif(v_relation->>'domain_status',''),
          coalesce(nullif(v_relation->>'certainty',''),'confirmed'),
          coalesce(nullif(v_relation->>'validity',''),'current'),
          coalesce(nullif(v_relation->>'lifecycle',''),'active'),
          nullif(v_relation->>'valid_from','')::timestamptz,
          nullif(v_relation->>'valid_to','')::timestamptz,
          v_source_id,
          coalesce(v_relation->'attributes','{}'::jsonb)
        )
        on conflict do nothing;

        v_entity_relations_created := v_entity_relations_created + 1;
      end loop;
    end if;

    v_result := jsonb_build_object(
      'status','completed',
      'batch_id',v_batch_id,
      'source_id',v_source_id,
      'entity_map',v_entity_map,
      'record_map',v_record_map,
      'counts',jsonb_build_object(
        'entities_created',v_entities_created,
        'records_created',v_records_created,
        'record_entity_links_created',v_entity_links_created,
        'record_relations_created',v_record_relations_created,
        'entity_relations_created',v_entity_relations_created
      ),
      'idempotent_replay',false
    );

    update public.ingestion_batches
    set batch_status = 'completed',
        completed_at = now(),
        result = v_result
    where id = v_batch_id;

    return v_result;

  exception when others then
    update public.ingestion_batches
    set batch_status = 'failed',
        completed_at = now(),
        result = jsonb_build_object(
          'status','failed',
          'batch_id',v_batch_id,
          'error',sqlerrm
        )
    where id = v_batch_id;

    return jsonb_build_object(
      'status','failed',
      'batch_id',v_batch_id,
      'error',sqlerrm
    );
  end;
end;
$$;

revoke all on function public.ingest_memory_bundle(uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.ingest_memory_bundle(uuid, text, jsonb) to service_role;
