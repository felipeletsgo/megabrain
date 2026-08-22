create or replace function public.audit_safe_json(p_data jsonb)
returns jsonb
language plpgsql
immutable
set search_path = public, extensions, pg_catalog
as $$
declare
  v_result jsonb := p_data;
  v_key text;
  v_sensitive_text_keys text[] := array[
    'normalized_content',
    'raw_excerpt',
    'title',
    'canonical_name',
    'description',
    'alias',
    'uri',
    'external_id',
    'display_name',
    'idempotency_key',
    'search_document'
  ];
begin
  if v_result is null then
    return null;
  end if;

  foreach v_key in array v_sensitive_text_keys loop
    if v_result ? v_key then
      v_result := (v_result - v_key) || jsonb_build_object(
        v_key || '_hash',
        encode(extensions.digest(coalesce(p_data->>v_key,''), 'sha256'), 'hex')
      );
    end if;
  end loop;

  if v_result ? 'attributes' then
    v_result := (v_result - 'attributes') || jsonb_build_object(
      'attributes_hash',
      encode(extensions.digest(coalesce((p_data->'attributes')::text,''), 'sha256'), 'hex')
    );
  end if;

  if v_result ? 'metadata' then
    v_result := (v_result - 'metadata') || jsonb_build_object(
      'metadata_hash',
      encode(extensions.digest(coalesce((p_data->'metadata')::text,''), 'sha256'), 'hex')
    );
  end if;

  if v_result ? 'result' then
    v_result := (v_result - 'result') || jsonb_build_object(
      'result_hash',
      encode(extensions.digest(coalesce((p_data->'result')::text,''), 'sha256'), 'hex')
    );
  end if;

  return v_result;
end;
$$;

revoke all on function public.audit_safe_json(jsonb) from public, anon, authenticated;

create or replace function public.soft_delete_record(
  p_owner_id uuid,
  p_record_id uuid,
  p_reason text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions, pg_catalog
as $$
declare
  v_relations_closed integer := 0;
  v_reason_hash text;
begin
  if p_owner_id is null or p_record_id is null then
    raise exception 'owner_id and record_id are required';
  end if;

  if not exists (
    select 1 from public.records
    where owner_id = p_owner_id
      and id = p_record_id
      and lifecycle <> 'deleted'
  ) then
    return jsonb_build_object(
      'status','not_found_or_already_deleted',
      'record_id',p_record_id
    );
  end if;

  if nullif(btrim(coalesce(p_reason,'')), '') is not null then
    v_reason_hash := encode(
      extensions.digest(btrim(p_reason), 'sha256'),
      'hex'
    );
  end if;

  update public.records
  set lifecycle = 'deleted',
      validity = 'retracted',
      valid_to = coalesce(valid_to, now()),
      metadata = case
        when v_reason_hash is null then metadata
        else metadata || jsonb_build_object('deletion_reason_hash', v_reason_hash)
      end
  where owner_id = p_owner_id
    and id = p_record_id;

  update public.record_relations
  set lifecycle = 'deleted',
      validity = 'retracted'
  where owner_id = p_owner_id
    and lifecycle <> 'deleted'
    and (source_record_id = p_record_id or target_record_id = p_record_id);

  get diagnostics v_relations_closed = row_count;

  return jsonb_build_object(
    'status','completed',
    'record_id',p_record_id,
    'lifecycle','deleted',
    'relations_closed',v_relations_closed
  );
end;
$$;

revoke all on function public.soft_delete_record(uuid, uuid, text) from public, anon, authenticated;
grant execute on function public.soft_delete_record(uuid, uuid, text) to service_role;

create or replace function public.forget_record(
  p_owner_id uuid,
  p_record_id uuid,
  p_confirm boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions, pg_catalog
as $$
declare
  v_source_ids uuid[] := array[]::uuid[];
  v_sources_scrubbed integer := 0;
begin
  if p_owner_id is null or p_record_id is null then
    raise exception 'owner_id and record_id are required';
  end if;

  if p_confirm is not true then
    raise exception 'explicit confirmation is required for irreversible forgetting';
  end if;

  if not exists (
    select 1 from public.records
    where owner_id = p_owner_id
      and id = p_record_id
  ) then
    return jsonb_build_object(
      'status','not_found',
      'record_id',p_record_id
    );
  end if;

  select coalesce(array_agg(distinct source_id), array[]::uuid[])
  into v_source_ids
  from public.record_sources
  where owner_id = p_owner_id
    and record_id = p_record_id;

  if cardinality(v_source_ids) > 0 then
    update public.sources
    set raw_excerpt = null,
        content_hash = null,
        external_id = null,
        uri = null,
        title = null,
        metadata = '{}'::jsonb
    where owner_id = p_owner_id
      and id = any(v_source_ids);

    get diagnostics v_sources_scrubbed = row_count;
  end if;

  delete from public.records
  where owner_id = p_owner_id
    and id = p_record_id;

  return jsonb_build_object(
    'status','forgotten',
    'record_id',p_record_id,
    'sources_scrubbed',v_sources_scrubbed,
    'irreversible',true
  );
end;
$$;

revoke all on function public.forget_record(uuid, uuid, boolean) from public, anon, authenticated;
grant execute on function public.forget_record(uuid, uuid, boolean) to service_role;
