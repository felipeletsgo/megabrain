alter table public.records
add column authority_type text not null default 'supabase'
  check (authority_type in ('supabase','calendar','task_manager','email','contacts','file','integration','external')),
add column external_ref text,
add column sync_state text not null default 'native'
  check (sync_state in ('native','linked','stale','error')),
add column last_synced_at timestamptz;

create unique index records_external_authority_uidx
on public.records(owner_id, authority_type, external_ref)
where external_ref is not null and lifecycle <> 'deleted';

create index records_owner_authority_idx
on public.records(owner_id, authority_type, sync_state);

create or replace function public.ingest_memory_bundle(
  p_owner_id uuid,
  p_idempotency_key text,
  p_bundle jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions, pg_catalog
as $$
declare
  v_result jsonb;
  v_record jsonb;
  v_client_key text;
  v_record_id uuid;
  v_record_map jsonb;
begin
  if p_owner_id is null then
    raise exception 'owner_id is required';
  end if;

  if p_idempotency_key is null or btrim(p_idempotency_key) = '' then
    raise exception 'idempotency_key is required';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_owner_id::text || ':' || p_idempotency_key, 0)
  );

  v_result := public.ingest_memory_bundle_serialized_inner(
    p_owner_id,
    p_idempotency_key,
    p_bundle
  );

  if v_result->>'status' <> 'completed' then
    return v_result;
  end if;

  if coalesce((v_result->>'idempotent_replay')::boolean, false) then
    return v_result;
  end if;

  v_record_map := coalesce(v_result->'record_map', '{}'::jsonb);

  if p_bundle ? 'records' and jsonb_typeof(p_bundle->'records') = 'array' then
    for v_record in select value from jsonb_array_elements(p_bundle->'records') loop
      v_client_key := nullif(v_record->>'client_key','');

      if v_client_key is not null and v_record_map ? v_client_key then
        v_record_id := (v_record_map->>v_client_key)::uuid;

        if v_record ? 'authority_type'
          or v_record ? 'external_ref'
          or v_record ? 'sync_state'
          or v_record ? 'last_synced_at' then

          update public.records
          set authority_type = coalesce(nullif(v_record->>'authority_type',''), authority_type),
              external_ref = case
                when v_record ? 'external_ref' then nullif(v_record->>'external_ref','')
                else external_ref
              end,
              sync_state = coalesce(nullif(v_record->>'sync_state',''), sync_state),
              last_synced_at = case
                when nullif(v_record->>'last_synced_at','') is not null
                  then (v_record->>'last_synced_at')::timestamptz
                when v_record ? 'last_synced_at' then null
                else last_synced_at
              end
          where owner_id = p_owner_id
            and id = v_record_id;
        end if;
      end if;
    end loop;
  end if;

  return v_result;
end;
$$;

revoke all on function public.ingest_memory_bundle(uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.ingest_memory_bundle(uuid, text, jsonb) to service_role;
