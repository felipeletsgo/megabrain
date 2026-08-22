create table public.record_entity_role_catalog (
  code text primary key,
  description text not null,
  active boolean not null default true
);

create table public.record_relation_type_catalog (
  code text primary key,
  description text not null,
  active boolean not null default true
);

create table public.entity_relation_type_catalog (
  code text primary key,
  description text not null,
  is_symmetric boolean not null default false,
  active boolean not null default true
);

insert into public.record_entity_role_catalog(code, description) values
  ('related','Relação genérica quando não houver papel mais específico.'),
  ('subject','Entidade que é o assunto principal do registro.'),
  ('participant','Entidade que participou do evento.'),
  ('location','Lugar associado ao registro.'),
  ('owner','Entidade proprietária ou titular no contexto do registro.'),
  ('responsible','Entidade responsável por uma ação ou resultado.'),
  ('affected','Entidade afetada pelo registro.'),
  ('advisor','Entidade que aconselhou ou influenciou uma decisão.'),
  ('beneficiary','Entidade beneficiada pelo registro.'),
  ('target','Entidade alvo de uma ação.'),
  ('object','Entidade objeto do registro.'),
  ('source','Entidade citada como fonte contextual.')
on conflict (code) do nothing;

insert into public.record_relation_type_catalog(code, description) values
  ('related_to','Os registros possuem vínculo contextual.'),
  ('supports','O registro de origem sustenta o registro de destino.'),
  ('evidence_for','O registro de origem é evidência para o registro de destino.'),
  ('contradicts','O registro de origem contradiz o registro de destino.'),
  ('supersedes','O registro de origem substitui o registro de destino.'),
  ('derived_from','O registro de origem foi derivado do registro de destino.'),
  ('caused_by_claim','Existe alegação de causalidade. Não confirma causalidade científica.'),
  ('contributes_to','O registro de origem contribui para o registro de destino.'),
  ('blocks','O registro de origem bloqueia o registro de destino.'),
  ('depends_on','O registro de origem depende do registro de destino.'),
  ('result_of','O registro de origem é resultado do registro de destino.')
on conflict (code) do nothing;

insert into public.entity_relation_type_catalog(code, description, is_symmetric) values
  ('related_to','Relação genérica entre entidades.',true),
  ('friend_of','Relação de amizade.',true),
  ('family_of','Relação familiar genérica.',true),
  ('spouse_of','Relação conjugal.',true),
  ('partner_of','Relação de parceria pessoal.',true),
  ('parent_of','Entidade de origem é responsável parental pela entidade de destino.',false),
  ('child_of','Entidade de origem é filha da entidade de destino.',false),
  ('sibling_of','Relação entre irmãos.',true),
  ('colleague_of','Relação profissional entre colegas.',true),
  ('works_at','Pessoa trabalha na organização de destino.',false),
  ('manager_of','Entidade de origem gerencia a entidade de destino.',false),
  ('member_of','Entidade de origem é membro da entidade de destino.',false),
  ('located_at','Entidade de origem está localizada no lugar de destino.',false),
  ('owns','Entidade de origem possui a entidade de destino.',false),
  ('service_provider_for','Entidade de origem presta serviço para a entidade de destino.',false),
  ('knows','Entidade de origem conhece a entidade de destino.',false)
on conflict (code) do nothing;

alter table public.record_entities
  add constraint record_entities_role_catalog_fkey
  foreign key (role) references public.record_entity_role_catalog(code);

alter table public.record_relations
  add constraint record_relations_type_catalog_fkey
  foreign key (relation_type) references public.record_relation_type_catalog(code);

alter table public.entity_relations
  add constraint entity_relations_type_catalog_fkey
  foreign key (relation_type) references public.entity_relation_type_catalog(code);

grant select on table public.record_entity_role_catalog to anon, authenticated;
grant select on table public.record_relation_type_catalog to anon, authenticated;
grant select on table public.entity_relation_type_catalog to anon, authenticated;

revoke insert, update, delete, truncate on table public.record_entity_role_catalog from anon, authenticated;
revoke insert, update, delete, truncate on table public.record_relation_type_catalog from anon, authenticated;
revoke insert, update, delete, truncate on table public.entity_relation_type_catalog from anon, authenticated;
