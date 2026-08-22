create extension if not exists pg_trgm with schema extensions;

create index if not exists entities_name_trgm_idx
on public.entities using gin (lower(canonical_name) extensions.gin_trgm_ops);

create index if not exists entity_aliases_alias_trgm_idx
on public.entity_aliases using gin (lower(alias) extensions.gin_trgm_ops);

create index if not exists records_title_trgm_idx
on public.records using gin (lower(title) extensions.gin_trgm_ops)
where title is not null;

create index if not exists records_content_trgm_idx
on public.records using gin (lower(normalized_content) extensions.gin_trgm_ops)
where normalized_content is not null;

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
set search_path = public, extensions, pg_catalog
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
        when lower(e.canonical_name) like q.value || '%' and q.value <> '' then 0.90
        when lower(e.canonical_name) like '%' || q.value || '%' and q.value <> '' then 0.78
        when q.value = '' then 0.10
        else 0.0
      end,
      case
        when q.value = '' then 0.0
        else extensions.similarity(lower(e.canonical_name), q.value) * 0.82
      end,
      coalesce(
        (
          select max(
            greatest(
              case
                when lower(ea.alias) = q.value and q.value <> '' then 0.98
                when lower(ea.alias) like q.value || '%' and q.value <> '' then 0.88
                when lower(ea.alias) like '%' || q.value || '%' and q.value <> '' then 0.76
                else 0.0
              end,
              case
                when q.value = '' then 0.0
                else extensions.similarity(lower(ea.alias), q.value) * 0.80
              end
            )
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
      or extensions.similarity(lower(e.canonical_name), q.value) >= 0.22
      or exists (
        select 1
        from public.entity_aliases ea
        where ea.owner_id = e.owner_id
          and ea.entity_id = e.id
          and (
            lower(ea.alias) like '%' || q.value || '%'
            or extensions.similarity(lower(ea.alias), q.value) >= 0.22
          )
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
set search_path = public, extensions, pg_catalog
as $$
  with params as (
    select
      nullif(btrim(coalesce(p_query,'')), '') as query_text,
      lower(nullif(btrim(coalesce(p_query,'')), '')) as query_lower,
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
    (
      case
        when params.query_ts is null then 0.0
        else ts_rank_cd(r.search_document, params.query_ts)
      end
      + case
          when params.query_lower is null or r.title is null then 0.0
          else extensions.similarity(lower(r.title), params.query_lower) * 0.28
        end
      + case
          when params.query_lower is null or r.normalized_content is null then 0.0
          else extensions.similarity(lower(r.normalized_content), params.query_lower) * 0.12
        end
      + case when r.lifecycle = 'active' and r.validity = 'current' then 0.03 else 0.0 end
    )::real as rank,
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
      or (r.title is not null and lower(r.title) like '%' || params.query_lower || '%')
      or (r.normalized_content is not null and lower(r.normalized_content) like '%' || params.query_lower || '%')
      or (r.title is not null and extensions.similarity(lower(r.title), params.query_lower) >= 0.20)
      or (r.normalized_content is not null and extensions.similarity(lower(r.normalized_content), params.query_lower) >= 0.16)
    )
  order by rank desc,
    coalesce(r.occurred_at, r.valid_from, r.created_at) desc
  limit greatest(1, least(coalesce(p_limit,20),100));
$$;

create or replace function public.search_current_memory(
  p_owner_id uuid,
  p_query text default null,
  p_record_types text[] default null,
  p_entity_ids uuid[] default null,
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
set search_path = public, extensions, pg_catalog
as $$
  select *
  from public.search_memory(
    p_owner_id,
    p_query,
    p_record_types,
    p_entity_ids,
    null,
    null,
    least(greatest(coalesce(p_limit,20) * 5, 20), 100)
  ) s
  where s.lifecycle = 'active'
    and s.validity = 'current'
  order by s.rank desc, s.occurred_at desc nulls last, s.record_date desc nulls last
  limit greatest(1, least(coalesce(p_limit,20),100));
$$;

revoke all on function public.find_entities(uuid, text, text[], integer) from public, anon, authenticated;
revoke all on function public.search_memory(uuid, text, text[], uuid[], timestamptz, timestamptz, integer) from public, anon, authenticated;
revoke all on function public.search_current_memory(uuid, text, text[], uuid[], integer) from public, anon, authenticated;

grant execute on function public.find_entities(uuid, text, text[], integer) to service_role;
grant execute on function public.search_memory(uuid, text, text[], uuid[], timestamptz, timestamptz, integer) to service_role;
grant execute on function public.search_current_memory(uuid, text, text[], uuid[], integer) to service_role;
