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

create table public.brain_owners (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid unique references auth.users(id) on delete set null,
  display_name text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id)
);

create table public.sources (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.brain_owners(id) on delete restrict,
  source_type text not null check (source_type in ('conversation','calendar','email','contact','document','database','integration','inference','manual')),
  external_id text,
  uri text,
  title text,
  raw_excerpt text,
  content_hash text,
  captured_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (owner_id, id)
);

create unique index sources_external_identity_uidx
on public.sources(owner_id, source_type, external_id)
where external_id is not null;

create table public.ingestion_batches (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.brain_owners(id) on delete restrict,
  idempotency_key text not null,
  source_id uuid,
  batch_status text not null default 'pending' check (batch_status in ('pending','completed','failed')),
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  unique (owner_id, id),
  unique (owner_id, idempotency_key),
  foreign key (owner_id, source_id) references public.sources(owner_id, id) on delete set null
);

create table public.entities (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.brain_owners(id) on delete restrict,
  entity_type text not null check (entity_type in ('person','organization','place','asset','topic')),
  canonical_name text not null,
  description text,
  is_self boolean not null default false,
  lifecycle text not null default 'active' check (lifecycle in ('active','archived','merged','deleted')),
  attributes jsonb not null default '{}'::jsonb,
  valid_from timestamptz,
  valid_to timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (owner_id, id),
  check (valid_to is null or valid_from is null or valid_to >= valid_from),
  check (not is_self or entity_type = 'person')
);

create unique index entities_one_self_per_owner_uidx
on public.entities(owner_id)
where is_self = true and lifecycle <> 'deleted';

create table public.entity_aliases (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.brain_owners(id) on delete restrict,
  entity_id uuid not null,
  alias text not null,
  alias_type text,
  source_id uuid,
  created_at timestamptz not null default now(),
  unique (owner_id, id),
  foreign key (owner_id, entity_id) references public.entities(owner_id, id) on delete cascade,
  foreign key (owner_id, source_id) references public.sources(owner_id, id) on delete set null
);

create unique index entity_aliases_owner_entity_alias_uidx
on public.entity_aliases(owner_id, entity_id, lower(alias));

create table public.records (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.brain_owners(id) on delete restrict,
  ingestion_batch_id uuid,
  record_type text not null check (record_type in (
    'fact','event','daily_log','state','preference','opinion','hypothesis','goal','project','decision','plan','task','commitment','habit','routine','financial_transaction','subscription','health_record','learning_record','media_item','purchase','idea','problem','memory','consolidated_memory','inference'
  )),
  title text,
  normalized_content text,
  domain_status text,
  certainty text not null default 'confirmed' check (certainty in ('confirmed','probable','uncertain')),
  validity text not null default 'current' check (validity in ('current','outdated','disputed','retracted')),
  lifecycle text not null default 'active' check (lifecycle in ('active','archived','superseded','deleted')),
  record_date date,
  occurred_at timestamptz,
  occurred_end_at timestamptz,
  valid_from timestamptz,
  valid_to timestamptz,
  idempotency_key text,
  attributes jsonb not null default '{}'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (owner_id, id),
  foreign key (owner_id, ingestion_batch_id) references public.ingestion_batches(owner_id, id) on delete set null,
  check (occurred_end_at is null or occurred_at is null or occurred_end_at >= occurred_at),
  check (valid_to is null or valid_from is null or valid_to >= valid_from)
);

create unique index records_owner_idempotency_uidx
on public.records(owner_id, idempotency_key)
where idempotency_key is not null;

create table public.record_sources (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.brain_owners(id) on delete restrict,
  record_id uuid not null,
  source_id uuid not null,
  source_role text not null default 'evidence' check (source_role in ('primary','evidence','context')),
  created_at timestamptz not null default now(),
  unique (owner_id, id),
  unique (record_id, source_id, source_role),
  foreign key (owner_id, record_id) references public.records(owner_id, id) on delete cascade,
  foreign key (owner_id, source_id) references public.sources(owner_id, id) on delete restrict
);

create table public.record_entities (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.brain_owners(id) on delete restrict,
  record_id uuid not null,
  entity_id uuid not null,
  role text not null default 'related',
  attributes jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique (owner_id, id),
  unique (record_id, entity_id, role),
  foreign key (owner_id, record_id) references public.records(owner_id, id) on delete cascade,
  foreign key (owner_id, entity_id) references public.entities(owner_id, id) on delete restrict
);

create table public.entity_relations (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.brain_owners(id) on delete restrict,
  source_entity_id uuid not null,
  target_entity_id uuid not null,
  relation_type text not null,
  domain_status text,
  certainty text not null default 'confirmed' check (certainty in ('confirmed','probable','uncertain')),
  validity text not null default 'current' check (validity in ('current','outdated','disputed','retracted')),
  lifecycle text not null default 'active' check (lifecycle in ('active','archived','superseded','deleted')),
  valid_from timestamptz,
  valid_to timestamptz,
  source_id uuid,
  attributes jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (owner_id, id),
  unique (source_entity_id, target_entity_id, relation_type, valid_from),
  foreign key (owner_id, source_entity_id) references public.entities(owner_id, id) on delete restrict,
  foreign key (owner_id, target_entity_id) references public.entities(owner_id, id) on delete restrict,
  foreign key (owner_id, source_id) references public.sources(owner_id, id) on delete set null,
  check (source_entity_id <> target_entity_id),
  check (valid_to is null or valid_from is null or valid_to >= valid_from)
);

create table public.record_relations (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.brain_owners(id) on delete restrict,
  source_record_id uuid not null,
  target_record_id uuid not null,
  relation_type text not null,
  certainty text not null default 'confirmed' check (certainty in ('confirmed','probable','uncertain')),
  validity text not null default 'current' check (validity in ('current','outdated','disputed','retracted')),
  lifecycle text not null default 'active' check (lifecycle in ('active','archived','superseded','deleted')),
  source_id uuid,
  attributes jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (owner_id, id),
  unique (source_record_id, target_record_id, relation_type),
  foreign key (owner_id, source_record_id) references public.records(owner_id, id) on delete cascade,
  foreign key (owner_id, target_record_id) references public.records(owner_id, id) on delete cascade,
  foreign key (owner_id, source_id) references public.sources(owner_id, id) on delete set null,
  check (source_record_id <> target_record_id)
);

create table public.audit_log (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.brain_owners(id) on delete restrict,
  object_type text not null,
  object_id uuid,
  operation text not null check (operation in ('insert','update','delete')),
  reason text,
  before_data jsonb,
  after_data jsonb,
  source_id uuid,
  created_at timestamptz not null default now(),
  foreign key (owner_id, source_id) references public.sources(owner_id, id) on delete set null
);

create trigger brain_owners_set_updated_at
before update on public.brain_owners
for each row execute function public.set_updated_at();
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
create trigger record_relations_set_updated_at
before update on public.record_relations
for each row execute function public.set_updated_at();