# RELAÇÕES

## 1. Objetivo

Representar ligações sem duplicar informação.

Use vocabulário controlado.

NÃO grave termo livre quando um catálogo técnico existir.

## 2. Catálogos

Use:

- `entity_relation_type_catalog` para relações entre entidades;
- `record_relation_type_catalog` para relações entre registros;
- `record_entity_role_catalog` para papéis de entidades em registros.

O banco rejeita valor fora do catálogo.

Adicione novo termo por migration quando um conceito realmente novo for necessário.

## 3. Relações entre entidades

Use `entity_relations`.

Tipos iniciais incluem:

- `related_to`;
- `friend_of`;
- `family_of`;
- `spouse_of`;
- `partner_of`;
- `parent_of`;
- `child_of`;
- `sibling_of`;
- `colleague_of`;
- `works_at`;
- `manager_of`;
- `member_of`;
- `located_at`;
- `owns`;
- `service_provider_for`;
- `knows`.

Toda relação DEVE indicar origem e destino.

Consulte `is_symmetric` no catálogo antes de assumir que a direção é equivalente.

## 4. Relações entre registros

Use `record_relations`.

Tipos iniciais incluem:

- `related_to`;
- `supports`;
- `evidence_for`;
- `contradicts`;
- `supersedes`;
- `derived_from`;
- `caused_by_claim`;
- `contributes_to`;
- `blocks`;
- `depends_on`;
- `result_of`.

`caused_by_claim` DEVE representar alegação de causalidade.

Ele NÃO DEVE confirmar causalidade científica.

## 5. Registros e entidades

Use `record_entities`.

Papéis iniciais incluem:

- `related`;
- `subject`;
- `participant`;
- `location`;
- `owner`;
- `responsible`;
- `affected`;
- `advisor`;
- `beneficiary`;
- `target`;
- `object`;
- `source`.

Use o papel mais específico que estiver sustentado pelo contexto.

## 6. Temporalidade

Relações mutáveis PODEM ter:

- `valid_from`;
- `valid_to`;
- `domain_status`;
- `validity`;
- `lifecycle`.

PRESERVE o histórico quando a relação mudar.

## 7. Origem e certeza

Relações importantes DEVEM ter origem quando possível.

Use `certainty` para indicar certeza da relação.

NÃO transforme relação inferida em relação confirmada sem evidência.

## 8. Regra final

RELACIONE somente quando houver vínculo real.

USE o catálogo.

NÃO crie sinônimo técnico.

NÃO aumente a conectividade do grafo sem utilidade.
