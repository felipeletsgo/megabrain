create or replace function public.find_entities(
  p_owner_id uuid,
  p_query text,
  p_entity_types text[] default null,
  p_limit integer default 10
)
returns table (
  entity_id uuid,
  entity_type text,
  canonical_name text,
  is_self boolean,
  lifecycle text,
  aliases jsonb,
  score real
)
language sql
stable
security definer
set search_path = public, extensions
as $$
  with q as (
    select lower(btrim(coalesce(p_query,''))) as value
  )
  select
    e.id as entity_id,
    e.entity_type,
    e.canonical_name,
    e.is_self,
    e.lifecycle,
    coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'alias', ea.alias,
            'alias_type', ea.alias_type
          )
          order by ea.alias
        )
        from public.entity_aliases ea
        where ea.owner_id = e.owner_id
          and ea.entity_id = e.id
      ),
      '[]'::jsonb
    ) as aliases,
    greatest(
      case
        when lower(e.canonical_name) = q.value and q.value <> '' then 1.0
        when lower(e.canonical_name) like q.value || '%' and q.value <> '' then 0.85
        when lower(e.canonical_name) like '%' || q.value || '%' and q.value <> '' then 0.70
        when q.value = '' then 0.10
        else 0.0
      end,
      coalesce(
        (
          select max(
            case
              when lower(ea.alias) = q.value and q.value <> '' then 0.95
              when lower(ea.alias) like q.value || '%' and q.value <> '' then 0.80
              when lower(ea.alias) like '%' || q.value || '%' and q.value <> '' then 0.65
              else 0.0
            end
          )
          from public.entity_aliases ea
          where ea.owner_id = e.owner_id
            and ea.entity_id = e.id
        ),
        0.0
      )
    )::real as score
  from public.entities e
  cross join q
  where e.owner_id = p_owner_id
    and e.lifecycle <> 'deleted'
    and (p_entity_types is null or e.entity_type = any(p_entity_types))
    and (
      q.value = ''
      or lower(e.canonical_name) like '%' || q.value || '%'
      or exists (
        select 1
        from public.entity_aliases ea
        where ea.owner_id = e.owner_id
          and ea.entity_id = e.id
          and lower(ea.alias) like '%' || q.value || '%'
      )
    )
  order by score desc, e.is_self desc, e.canonical_name
  limit greatest(1, least(coalesce(p_limit,10),50));
$$;

create or replace function public.search_memory(
  p_owner_id uuid,
  p_query text default null,
  p_record_types text[] default null,
  p_entity_ids uuid[] default null,
  p_from timestamptz default null,
  p_to timestamptz default null,
  p_limit integer default 20
)
returns table (
  record_id uuid,
  record_type text,
  title text,
  normalized_content text,
  domain_status text,
  certainty text,
  validity text,
  lifecycle text,
  record_date date,
  occurred_at timestamptz,
  valid_from timestamptz,
  valid_to timestamptz,
  rank real,
  entities jsonb,
  source_refs jsonb
)
language sql
stable
security definer
set search_path = public, extensions
as $$
  with params as (
    select
      nullif(btrim(coalesce(p_query,'')), '') as query_text,
      case
        when nullif(btrim(coalesce(p_query,'')), '') is null then null::tsquery
        else websearch_to_tsquery('portuguese', btrim(p_query))
      end as query_ts
  )
  select
    r.id as record_id,
    r.record_type,
    r.title,
    r.normalized_content,
    r.domain_status,
    r.certainty,
    r.validity,
    r.lifecycle,
    r.record_date,
    r.occurred_at,
    r.valid_from,
    r.valid_to,
    case
      when params.query_ts is null then 0.0
      else ts_rank_cd(r.search_document, params.query_ts)
    end::real as rank,
    coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'entity_id', e.id,
            'entity_type', e.entity_type,
            'canonical_name', e.canonical_name,
            'is_self', e.is_self,
            'role', re.role
          )
          order by e.is_self desc, e.canonical_name
        )
        from public.record_entities re
        join public.entities e
          on e.owner_id = re.owner_id
         and e.id = re.entity_id
        where re.owner_id = r.owner_id
          and re.record_id = r.id
          and e.lifecycle <> 'deleted'
      ),
      '[]'::jsonb
    ) as entities,
    coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'source_id', s.id,
            'source_type', s.source_type,
            'external_id', s.external_id,
            'title', s.title,
            'captured_at', s.captured_at,
            'source_role', rs.source_role
          )
          order by s.captured_at desc
        )
        from public.record_sources rs
        join public.sources s
          on s.owner_id = rs.owner_id
         and s.id = rs.source_id
        where rs.owner_id = r.owner_id
          and rs.record_id = r.id
      ),
      '[]'::jsonb
    ) as source_refs
  from public.records r
  cross join params
  where r.owner_id = p_owner_id
    and r.lifecycle <> 'deleted'
    and r.validity <> 'retracted'
    and (p_record_types is null or r.record_type = any(p_record_types))
    and (
      p_entity_ids is null
      or exists (
        select 1
        from public.record_entities re
        where re.owner_id = r.owner_id
          and re.record_id = r.id
          and re.entity_id = any(p_entity_ids)
      )
    )
    and (
      p_from is null
      or coalesce(r.occurred_at, r.valid_from, r.created_at) >= p_from
    )
    and (
      p_to is null
      or coalesce(r.occurred_at, r.valid_from, r.created_at) <= p_to
    )
    and (
      params.query_ts is null
      or r.search_document @@ params.query_ts
    )
  order by
    case
      when params.query_ts is null then 0.0
      else ts_rank_cd(r.search_document, params.query_ts)
    end desc,
    coalesce(r.occurred_at, r.valid_from, r.created_at) desc
  limit greatest(1, least(coalesce(p_limit,20),100));
$$;

create or replace function public.get_record_context(
  p_owner_id uuid,
  p_record_id uuid,
  p_include_raw_source boolean default false
)
returns jsonb
language sql
stable
security definer
set search_path = public, extensions
as $$
  select jsonb_build_object(
    'record', jsonb_build_object(
      'id', r.id,
      'record_type', r.record_type,
      'title', r.title,
      'normalized_content', r.normalized_content,
      'domain_status', r.domain_status,
      'certainty', r.certainty,
      'validity', r.validity,
      'lifecycle', r.lifecycle,
      'record_date', r.record_date,
      'occurred_at', r.occurred_at,
      'occurred_end_at', r.occurred_end_at,
      'valid_from', r.valid_from,
      'valid_to', r.valid_to,
      'attributes', r.attributes,
      'created_at', r.created_at,
      'updated_at', r.updated_at
    ),
    'entities', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'entity_id', e.id,
            'entity_type', e.entity_type,
            'canonical_name', e.canonical_name,
            'is_self', e.is_self,
            'role', re.role,
            'attributes', re.attributes
          )
          order by e.is_self desc, e.canonical_name
        )
        from public.record_entities re
        join public.entities e
          on e.owner_id = re.owner_id
         and e.id = re.entity_id
        where re.owner_id = r.owner_id
          and re.record_id = r.id
      ),
      '[]'::jsonb
    ),
    'sources', coalesce(
      (
        select jsonb_agg(
          jsonb_strip_nulls(
            jsonb_build_object(
              'source_id', s.id,
              'source_type', s.source_type,
              'external_id', s.external_id,
              'uri', s.uri,
              'title', s.title,
              'captured_at', s.captured_at,
              'source_role', rs.source_role,
              'raw_excerpt', case when p_include_raw_source then s.raw_excerpt else null end
            )
          )
          order by s.captured_at desc
        )
        from public.record_sources rs
        join public.sources s
          on s.owner_id = rs.owner_id
         and s.id = rs.source_id
        where rs.owner_id = r.owner_id
          and rs.record_id = r.id
      ),
      '[]'::jsonb
    ),
    'outgoing_relations', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'relation_id', rr.id,
            'relation_type', rr.relation_type,
            'certainty', rr.certainty,
            'validity', rr.validity,
            'lifecycle', rr.lifecycle,
            'target_record', jsonb_build_object(
              'id', t.id,
              'record_type', t.record_type,
              'title', t.title,
              'normalized_content', t.normalized_content,
              'occurred_at', t.occurred_at,
              'validity', t.validity,
              'lifecycle', t.lifecycle
            )
          )
          order by rr.created_at desc
        )
        from public.record_relations rr
        join public.records t
          on t.owner_id = rr.owner_id
         and t.id = rr.target_record_id
        where rr.owner_id = r.owner_id
          and rr.source_record_id = r.id
          and rr.lifecycle <> 'deleted'
      ),
      '[]'::jsonb
    ),
    'incoming_relations', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'relation_id', rr.id,
            'relation_type', rr.relation_type,
            'certainty', rr.certainty,
            'validity', rr.validity,
            'lifecycle', rr.lifecycle,
            'source_record', jsonb_build_object(
              'id', srec.id,
              'record_type', srec.record_type,
              'title', srec.title,
              'normalized_content', srec.normalized_content,
              'occurred_at', srec.occurred_at,
              'validity', srec.validity,
              'lifecycle', srec.lifecycle
            )
          )
          order by rr.created_at desc
        )
        from public.record_relations rr
        join public.records srec
          on srec.owner_id = rr.owner_id
         and srec.id = rr.source_record_id
        where rr.owner_id = r.owner_id
          and rr.target_record_id = r.id
          and rr.lifecycle <> 'deleted'
      ),
      '[]'::jsonb
    )
  )
  from public.records r
  where r.owner_id = p_owner_id
    and r.id = p_record_id
    and r.lifecycle <> 'deleted';
$$;

revoke all on function public.find_entities(uuid, text, text[], integer) from public, anon, authenticated;
revoke all on function public.search_memory(uuid, text, text[], uuid[], timestamptz, timestamptz, integer) from public, anon, authenticated;
revoke all on function public.get_record_context(uuid, uuid, boolean) from public, anon, authenticated;

grant execute on function public.find_entities(uuid, text, text[], integer) to service_role;
grant execute on function public.search_memory(uuid, text, text[], uuid[], timestamptz, timestamptz, integer) to service_role;
grant execute on function public.get_record_context(uuid, uuid, boolean) to service_role;
