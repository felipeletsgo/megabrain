alter function public.ingest_memory_bundle(uuid, text, jsonb)
rename to ingest_memory_bundle_serialized_inner;

revoke execute on function public.ingest_memory_bundle_serialized_inner(uuid, text, jsonb) from service_role;
revoke execute on function public.ingest_memory_bundle_core(uuid, text, jsonb) from service_role;

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

  return public.ingest_memory_bundle_serialized_inner(
    p_owner_id,
    p_idempotency_key,
    p_bundle
  );
end;
$$;

revoke all on function public.ingest_memory_bundle(uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.ingest_memory_bundle(uuid, text, jsonb) to service_role;
