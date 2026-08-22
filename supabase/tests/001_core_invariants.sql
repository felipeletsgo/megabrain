begin;

do $$
declare
  v_identity jsonb;
  v_owner uuid;
  v_first jsonb;
  v_replay jsonb;
  v_second jsonb;
  v_first_record uuid;
  v_second_record uuid;
  v_person uuid;
  v_count integer;
  v_ctx jsonb;
begin
  v_identity := public.get_primary_brain_identity();
  v_owner := (v_identity->>'owner_id')::uuid;

  if v_owner is null then
    raise exception 'primary owner was not resolved';
  end if;

  if (v_identity->>'self_entity_id') is null then
    raise exception 'self entity was not resolved';
  end if;

  v_first := public.ingest_memory_bundle(
    v_owner,
    'test:core:first',
    jsonb_build_object(
      'source', jsonb_build_object(
        'source_type','conversation',
        'external_id','test-core-first',
        'raw_excerpt','Conversei com Pessoa Teste sobre Projeto Teste.'
      ),
      'entities', jsonb_build_array(
        jsonb_build_object(
          'client_key','person',
          'entity_type','person',
          'canonical_name','Pessoa Teste',
          'aliases',jsonb_build_array(
            jsonb_build_object('alias','Pessoa Alias','alias_type','test')
          )
        ),
        jsonb_build_object(
          'client_key','topic',
          'entity_type','topic',
          'canonical_name','Projeto Teste'
        )
      ),
      'records', jsonb_build_array(
        jsonb_build_object(
          'client_key','event',
          'record_type','event',
          'normalized_content','Conversou com Pessoa Teste sobre Projeto Teste.',
          'record_date','2026-01-01'
        )
      ),
      'record_entities', jsonb_build_array(
        jsonb_build_object('record','event','entity','self','role','participant'),
        jsonb_build_object('record','event','entity','person','role','participant'),
        jsonb_build_object('record','event','entity','topic','role','subject')
      )
    )
  );

  if v_first->>'status' <> 'completed' then
    raise exception 'first ingestion failed: %', v_first;
  end if;

  v_first_record := (v_first->'record_map'->>'event')::uuid;
  v_person := (v_first->'entity_map'->>'person')::uuid;

  v_replay := public.ingest_memory_bundle(v_owner, 'test:core:first', '{}'::jsonb);

  if v_replay->>'idempotent_replay' <> 'true' then
    raise exception 'idempotent replay was not detected';
  end if;

  select count(*) into v_count
  from public.find_entities(v_owner, 'Pessoa Alias', array['person'], 10)
  where entity_id = v_person;

  if v_count <> 1 then
    raise exception 'entity alias resolution failed';
  end if;

  select count(*) into v_count
  from public.search_memory(v_owner, 'Projeto Teste', array['event'], array[v_person], null, null, 20)
  where record_id = v_first_record;

  if v_count <> 1 then
    raise exception 'memory retrieval failed';
  end if;

  v_ctx := public.get_record_context(v_owner, v_first_record, false);

  if v_ctx is null or jsonb_array_length(v_ctx->'entities') <> 3 then
    raise exception 'record context is invalid';
  end if;

  if (v_ctx->'sources'->0) ? 'raw_excerpt' then
    raise exception 'raw source leaked by default';
  end if;

  v_second := public.ingest_memory_bundle(
    v_owner,
    'test:core:second',
    jsonb_build_object(
      'source',jsonb_build_object(
        'source_type','conversation',
        'external_id','test-core-second',
        'raw_excerpt','Correção do registro de teste.'
      ),
      'records',jsonb_build_array(
        jsonb_build_object(
          'client_key','corrected',
          'record_type','event',
          'normalized_content','Registro de teste corrigido.'
        )
      ),
      'record_entities',jsonb_build_array(
        jsonb_build_object('record','corrected','entity','self','role','subject')
      )
    )
  );

  v_second_record := (v_second->'record_map'->>'corrected')::uuid;

  perform public.supersede_record(
    v_owner,
    v_first_record,
    v_second_record,
    true,
    (v_second->>'source_id')::uuid
  );

  select count(*) into v_count
  from public.records
  where owner_id = v_owner
    and id = v_first_record
    and lifecycle = 'superseded'
    and validity = 'retracted';

  if v_count <> 1 then
    raise exception 'correction state is invalid';
  end if;

  perform public.soft_delete_record(v_owner, v_second_record, 'test');

  select count(*) into v_count
  from public.search_memory(v_owner, null, null, null, null, null, 100)
  where record_id in (v_first_record, v_second_record);

  if v_count <> 0 then
    raise exception 'inactive records leaked into normal retrieval';
  end if;
end;
$$;

select 'core_invariants_ok' as result;

rollback;