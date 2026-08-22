create or replace function public.brain_integrity_report(
  p_owner_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, extensions, pg_catalog
as $$
declare
  v_self_count integer;
  v_active_records integer;
  v_entities integer;
  v_sources integer;
  v_failed_batches integer;
  v_duplicate_entity_groups integer;
  v_inferences_without_evidence integer;
  v_retracted_active integer;
  v_current_superseded integer;
  v_stale_external integer;
  v_records_without_source integer;
  v_status text;
begin
  if p_owner_id is null then
    raise exception 'owner_id is required';
  end if;

  if not exists (select 1 from public.brain_owners where id = p_owner_id) then
    raise exception 'owner does not exist';
  end if;

  select count(*) into v_self_count
  from public.entities
  where owner_id = p_owner_id
    and is_self = true
    and lifecycle <> 'deleted';

  select count(*) into v_active_records
  from public.records
  where owner_id = p_owner_id
    and lifecycle = 'active'
    and validity <> 'retracted';

  select count(*) into v_entities
  from public.entities
  where owner_id = p_owner_id
    and lifecycle <> 'deleted';

  select count(*) into v_sources
  from public.sources
  where owner_id = p_owner_id;

  select count(*) into v_failed_batches
  from public.ingestion_batches
  where owner_id = p_owner_id
    and batch_status = 'failed';

  select count(*) into v_duplicate_entity_groups
  from (
    select entity_type, lower(btrim(canonical_name)) as normalized_name
    from public.entities
    where owner_id = p_owner_id
      and lifecycle <> 'deleted'
    group by entity_type, lower(btrim(canonical_name))
    having count(*) > 1
  ) d;

  select count(*) into v_inferences_without_evidence
  from public.records r
  where r.owner_id = p_owner_id
    and r.record_type = 'inference'
    and r.lifecycle = 'active'
    and r.validity <> 'retracted'
    and not exists (
      select 1
      from public.record_relations rr
      where rr.owner_id = r.owner_id
        and rr.lifecycle = 'active'
        and rr.validity <> 'retracted'
        and (
          (rr.source_record_id = r.id and rr.relation_type in ('derived_from','related_to'))
          or
          (rr.target_record_id = r.id and rr.relation_type in ('supports','evidence_for'))
        )
    );

  select count(*) into v_retracted_active
  from public.records
  where owner_id = p_owner_id
    and lifecycle = 'active'
    and validity = 'retracted';

  select count(*) into v_current_superseded
  from public.records
  where owner_id = p_owner_id
    and lifecycle = 'superseded'
    and validity = 'current';

  select count(*) into v_stale_external
  from public.records
  where owner_id = p_owner_id
    and lifecycle <> 'deleted'
    and authority_type <> 'supabase'
    and sync_state in ('stale','error');

  select count(*) into v_records_without_source
  from public.records r
  where r.owner_id = p_owner_id
    and r.lifecycle <> 'deleted'
    and not exists (
      select 1
      from public.record_sources rs
      where rs.owner_id = r.owner_id
        and rs.record_id = r.id
    );

  v_status := case
    when v_self_count <> 1
      or v_inferences_without_evidence > 0
      or v_retracted_active > 0
      or v_current_superseded > 0
      then 'attention'
    when v_failed_batches > 0
      or v_duplicate_entity_groups > 0
      or v_stale_external > 0
      then 'warning'
    else 'healthy'
  end;

  return jsonb_build_object(
    'status', v_status,
    'counts', jsonb_build_object(
      'active_records', v_active_records,
      'entities', v_entities,
      'sources', v_sources,
      'records_without_source', v_records_without_source
    ),
    'checks', jsonb_build_object(
      'self_entity_count', v_self_count,
      'failed_batches', v_failed_batches,
      'duplicate_entity_groups', v_duplicate_entity_groups,
      'inferences_without_evidence', v_inferences_without_evidence,
      'active_retracted_records', v_retracted_active,
      'current_superseded_records', v_current_superseded,
      'stale_or_error_external_records', v_stale_external
    )
  );
end;
$$;

revoke all on function public.brain_integrity_report(uuid) from public, anon, authenticated;
grant execute on function public.brain_integrity_report(uuid) to service_role;
