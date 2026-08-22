create or replace function public.audit_safe_json(p_data jsonb)
returns jsonb
language plpgsql
immutable
set search_path = public, extensions
as $$
declare
  v_result jsonb := p_data;
begin
  if v_result is null then
    return null;
  end if;

  if v_result ? 'normalized_content' then
    v_result := (v_result - 'normalized_content') || jsonb_build_object(
      'normalized_content_hash', encode(extensions.digest(coalesce(p_data->>'normalized_content',''), 'sha256'), 'hex')
    );
  end if;

  if v_result ? 'raw_excerpt' then
    v_result := (v_result - 'raw_excerpt') || jsonb_build_object(
      'raw_excerpt_hash', encode(extensions.digest(coalesce(p_data->>'raw_excerpt',''), 'sha256'), 'hex')
    );
  end if;

  if v_result ? 'attributes' then
    v_result := (v_result - 'attributes') || jsonb_build_object(
      'attributes_hash', encode(extensions.digest(coalesce((p_data->'attributes')::text,''), 'sha256'), 'hex')
    );
  end if;

  if v_result ? 'metadata' then
    v_result := (v_result - 'metadata') || jsonb_build_object(
      'metadata_hash', encode(extensions.digest(coalesce((p_data->'metadata')::text,''), 'sha256'), 'hex')
    );
  end if;

  return v_result;
end;
$$;

revoke all on function public.audit_safe_json(jsonb) from public, anon, authenticated;