-- MegaBrain hardening invariants.
-- Use only fictitious data.
-- This script MUST end with ROLLBACK.

begin;

do $$
declare
  v_owner uuid := (public.get_primary_brain_identity()->>'owner_id')::uuid;
  v_result jsonb;
  v_replay jsonb;
  v_record_id uuid;
  v_person_id uuid;
  v_source_id uuid;
  v_count integer;
  v_authority text;
  v_external_ref text;
  v_search_count integer;
  v_forget jsonb;
begin
  v_result := public.ingest_memory_bundle(
    v_owner,
    'audit-hardening-test-1',
    jsonb_build_object(
      'source', jsonb_build_object(
        'source_type','conversation',
        'external_id','audit-hardening-source-1',
        'title','Fonte fictícia',
        'raw_excerpt','Conversei com Marcos sobre o projeto de teste.'
      ),
      'entities', jsonb_build_array(
        jsonb_build_object(
          'client_key','person_marcos',
          'entity_type','person',
          'canonical_name','Marcos Teste',
          'aliases',jsonb_build_array(
            jsonb_build_object('alias','Marcão','alias_type','nickname')
          )
        )
      ),
      'records', jsonb_build_array(
        jsonb_build_object(
          'client_key','event_1',
          'record_type','event',
          'title','Conversa com Marcos',
          'normalized_content','Conversou com Marcos sobre o projeto de teste.',
          'certainty','confirmed',
          'validity','current',
          'authority_type','integration',
          'external_ref','integration:event:001',
          'sync_state','linked',
          'last_synced_at',now()::text
        )
      ),
      'record_entities', jsonb_build_array(
        jsonb_build_object('record','event_1','entity','self','role','subject'),
        jsonb_build_object('record','event_1','entity','person_marcos','role','participant')
      )
    )
  );

  if v_result->>'status' <> 'completed' then
    raise exception 'ingestion failed: %', v_result;
  end if;

  v_record_id := (v_result->'record_map'->>'event_1')::uuid;
  v_person_id := (v_result->'entity_map'->>'person_marcos')::uuid;
  v_source_id := (v_result->>'source_id')::uuid;

  select authority_type, external_ref
  into v_authority, v_external_ref
  from public.records
  where owner_id = v_owner
    and id = v_record_id;

  if v_authority <> 'integration'
    or v_external_ref <> 'integration:event:001' then
    raise exception 'authority metadata was not persisted';
  end if;

  v_replay := public.ingest_memory_bundle(
    v_owner,
    'audit-hardening-test-1',
    jsonb_build_object('records','[]'::jsonb)
  );

  if coalesce((v_replay->>'idempotent_replay')::boolean,false) is not true then
    raise exception 'idempotent replay was not detected';
  end if;

  select count(*) into v_count
  from public.find_entities(v_owner,'Marcoz Teste',array['person']::text[],10)
  where entity_id = v_person_id
    and score > 0.15;

  if v_count <> 1 then
    raise exception 'fuzzy entity search failed';
  end if;

  select count(*) into v_search_count
  from public.search_memory(v_owner,'Converza Marcos',null,null,null,null,20)
  where record_id = v_record_id;

  if v_search_count <> 1 then
    raise exception 'resilient memory search failed';
  end if;

  perform public.soft_delete_record(
    v_owner,
    v_record_id,
    'motivo fictício sensível'
  );

  select count(*) into v_count
  from public.search_current_memory(v_owner,'Marcos',null,null,20)
  where record_id = v_record_id;

  if v_count <> 0 then
    raise exception 'soft-deleted record remained in current search';
  end if;

  v_result := public.ingest_memory_bundle(
    v_owner,
    'audit-hardening-test-2',
    jsonb_build_object(
      'source', jsonb_build_object(
        'source_type','conversation',
        'external_id','audit-hardening-source-2',
        'title','Fonte a esquecer',
        'raw_excerpt','Conteúdo fictício que deve desaparecer.'
      ),
      'records', jsonb_build_array(
        jsonb_build_object(
          'client_key','fact_1',
          'record_type','fact',
          'title','Fato fictício',
          'normalized_content','Conteúdo fictício para teste de esquecimento.'
        )
      ),
      'record_entities', jsonb_build_array(
        jsonb_build_object('record','fact_1','entity','self','role','subject')
      )
    )
  );

  v_record_id := (v_result->'record_map'->>'fact_1')::uuid;
  v_source_id := (v_result->>'source_id')::uuid;

  v_forget := public.forget_record(v_owner,v_record_id,true);

  if v_forget->>'status' <> 'forgotten' then
    raise exception 'forget_record failed';
  end if;

  select count(*) into v_count
  from public.records
  where owner_id = v_owner
    and id = v_record_id;

  if v_count <> 0 then
    raise exception 'forgotten record still exists';
  end if;

  select count(*) into v_count
  from public.sources
  where owner_id = v_owner
    and id = v_source_id
    and (
      raw_excerpt is not null
      or external_id is not null
      or uri is not null
      or title is not null
      or content_hash is not null
    );

  if v_count <> 0 then
    raise exception 'linked source was not scrubbed';
  end if;

  if (public.brain_integrity_report(v_owner)->>'status') not in ('healthy','warning') then
    raise exception 'integrity report returned attention during controlled test: %',
      public.brain_integrity_report(v_owner);
  end if;

  -- Controlled vocabulary MUST reject an unknown role.
  begin
    insert into public.record_entities(owner_id, record_id, entity_id, role)
    values (v_owner, (select id from public.records where owner_id=v_owner limit 1), v_person_id, 'unknown_role_for_test');
    raise exception 'controlled role vocabulary did not reject unknown value';
  exception
    when foreign_key_violation then
      null;
  end;
end $$;

select 'audit_hardening_invariants_ok' as result;

rollback;
