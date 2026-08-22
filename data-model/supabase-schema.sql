-- MegaBrain core schema
-- Draft architecture. Apply only after review.

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table public.sources (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  source_type text not null,
  external_id text,
  uri text,
  title text,
  captured_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.entities (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  entity_type text not null,
  canonical_name text not null,
  description text,
  status text not null default 'active',
  attributes jsonb not null default '{}'::jsonb,
  valid_from timestamptz,
  valid_to timestamptz,
  source_id uuid references public.sources(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.entity_aliases (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  entity_id uuid not null references public.entities(id) on delete cascade,
  alias text not null,
  alias_type text,
  source_id uuid references public.sources(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (owner_id, entity_id, alias)
);

create table public.records (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  record_type text not null,
  title text,
  content text,
  status text not null default 'active',
  confidence text not null default 'confirmed'
    check (confidence in ('confirmed','probable','uncertain','contradictory','outdated')),
  record_date date,
  occurred_at timestamptz,
  occurred_end_at timestamptz,
  valid_from timestamptz,
  valid_to timestamptz,
  source_id uuid references public.sources(id) on delete set null,
  attributes jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (occurred_end_at is null or occurred_at is null or occurred_end_at >= occurred_at),
  check (valid_to is null or valid_from is null or valid_to >= valid_from)
);

create table public.record_entities (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  record_id uuid not null references public.records(id) on delete cascade,
  entity_id uuid not null references public.entities(id) on delete cascade,
  role text not null default 'related',
  attributes jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (record_id, entity_id, role)
);

create table public.entity_relations (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  source_entity_id uuid not null references public.entities(id) on delete cascade,
  target_entity_id uuid not null references public.entities(id) on delete cascade,
  relation_type text not null,
  status text not null default 'active',
  valid_from timestamptz,
  valid_to timestamptz,
  source_id uuid references public.sources(id) on delete set null,
  attributes jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (source_entity_id <> target_entity_id),
  check (valid_to is null or valid_from is null or valid_to >= valid_from)
);

create table public.record_relations (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  source_record_id uuid not null references public.records(id) on delete cascade,
  target_record_id uuid not null references public.records(id) on delete cascade,
  relation_type text not null,
  attributes jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (source_record_id, target_record_id, relation_type),
  check (source_record_id <> target_record_id)
);

create table public.audit_log (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  object_type text not null,
  object_id uuid,
  operation text not null,
  reason text,
  before_data jsonb,
  after_data jsonb,
  source_id uuid references public.sources(id) on delete set null,
  created_at timestamptz not null default now()
);

create index entities_owner_type_idx on public.entities(owner_id, entity_type);
create index entities_owner_name_idx on public.entities(owner_id, lower(canonical_name));
create index entity_aliases_owner_alias_idx on public.entity_aliases(owner_id, lower(alias));
create index records_owner_type_idx on public.records(owner_id, record_type);
create index records_owner_date_idx on public.records(owner_id, record_date desc);
create index records_owner_occurred_idx on public.records(owner_id, occurred_at desc);
create index records_attributes_gin_idx on public.records using gin(attributes);
create index record_entities_record_idx on public.record_entities(record_id);
create index record_entities_entity_idx on public.record_entities(entity_id);
create index entity_relations_source_idx on public.entity_relations(source_entity_id, relation_type);
create index entity_relations_target_idx on public.entity_relations(target_entity_id, relation_type);
create index record_relations_source_idx on public.record_relations(source_record_id, relation_type);
create index record_relations_target_idx on public.record_relations(target_record_id, relation_type);
create index sources_owner_type_idx on public.sources(owner_id, source_type);

create trigger sources_set_updated_at
before update on public.sources
for each row execute function public.set_updated_at();

create trigger entities_set_updated_at
before update on public.entities
for each row execute function public.set_updated_at();

create trigger records_set_updated_at
before update on public.records
for each row execute function public.set_updated_at();

create trigger entity_relations_set_updated_at
before update on public.entity_relations
for each row execute function public.set_updated_at();

alter table public.sources enable row level security;
alter table public.entities enable row level security;
alter table public.entity_aliases enable row level security;
alter table public.records enable row level security;
alter table public.record_entities enable row level security;
alter table public.entity_relations enable row level security;
alter table public.record_relations enable row level security;
alter table public.audit_log enable row level security;

create policy sources_owner_all on public.sources
for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy entities_owner_all on public.entities
for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy entity_aliases_owner_all on public.entity_aliases
for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy records_owner_all on public.records
for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy record_entities_owner_all on public.record_entities
for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy entity_relations_owner_all on public.entity_relations
for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy record_relations_owner_all on public.record_relations
for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create policy audit_log_owner_all on public.audit_log
for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

comment on table public.entities is 'Stable entities such as people, organizations and places.';
comment on table public.records is 'Persistent temporal and semantic records used by MegaBrain skills.';
comment on table public.record_relations is 'Links records for evidence, contradiction, supersession and other relations.';
comment on table public.sources is 'Origin metadata for persistent information.';
comment on table public.audit_log is 'History of important corrections and mutations.';