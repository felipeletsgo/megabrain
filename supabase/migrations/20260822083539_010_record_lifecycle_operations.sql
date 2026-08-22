create or replace function public.supersede_record(
  p_owner_id uuid,
  p_old_record_id uuid,
  p_new_record_id uuid,
  p_is_correction boolean default false,
  p_source_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_relation_id uuid;
  v_old_validity text;
begin
  if p_owner_id is null or p_old_record_id is null or p_new_record_id is null then
    raise exception 'owner_id, old_record_id and new_record_id are required';
  end if;

  if p_old_record_id = p_new_record_id then
    raise exception 'old_record_id and new_record_id must be different';
  end if;

  if not exists (
    select 1 from public.records
    where owner_id = p_owner_id
      and id = p_old_record_id
      and lifecycle <> 'deleted'
  ) then
    raise exception 'old record does not exist for this owner';
  end if;

  if not exists (
    select 1 from public.records
    where owner_id = p_owner_id
      and id = p_new_record_id
      and lifecycle <> 'deleted'
  ) then
    raise exception 'new record does not exist for this owner';
  end if;

  if p_source_id is not null and not exists (
    select 1 from public.sources
    where owner_id = p_owner_id and id = p_source_id
  ) then
    raise exception 'source does not exist for this owner';
  end if;

  v_old_validity := case when p_is_correction then 'retracted' else 'outdated' end;

  update public.records
  set lifecycle = 'superseded',
      validity = v_old_validity,
      valid_to = coalesce(valid_to, now())
  where owner_id = p_owner_id
    and id = p_old_record_id;

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
    p_new_record_id,
    p_old_record_id,
    'supersedes',
    'confirmed',
    'current',
    'active',
    p_source_id,
    jsonb_build_object('mode', case when p_is_correction then 'correction' else 'change' end)
  )
  on conflict (source_record_id, target_record_id, relation_type)
  do update set
    certainty = excluded.certainty,
    validity = excluded.validity,
    lifecycle = excluded.lifecycle,
    source_id = coalesce(excluded.source_id, public.record_relations.source_id),
    attributes = public.record_relations.attributes || excluded.attributes,
    updated_at = now()
  returning id into v_relation_id;

  return jsonb_build_object(
    'status','completed',
    'old_record_id',p_old_record_id,
    'new_record_id',p_new_record_id,
    'old_lifecycle','superseded',
    'old_validity',v_old_validity,
    'relation_id',v_relation_id,
    'mode',case when p_is_correction then 'correction' else 'change' end
  );
end;
$$;

create or replace function public.soft_delete_record(
  p_owner_id uuid,
  p_record_id uuid,
  p_reason text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_relations_closed integer := 0;
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

  update public.records
  set lifecycle = 'deleted',
      validity = 'retracted',
      valid_to = coalesce(valid_to, now()),
      metadata = case
        when nullif(btrim(coalesce(p_reason,'')), '') is null then metadata
        else metadata || jsonb_build_object('deletion_reason', p_reason)
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

revoke all on function public.supersede_record(uuid, uuid, uuid, boolean, uuid) from public, anon, authenticated;
revoke all on function public.soft_delete_record(uuid, uuid, text) from public, anon, authenticated;

grant execute on function public.supersede_record(uuid, uuid, uuid, boolean, uuid) to service_role;
grant execute on function public.soft_delete_record(uuid, uuid, text) to service_role;
