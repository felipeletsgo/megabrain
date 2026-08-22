# RELAÇÕES

## 1. Objetivo

Representar ligações sem duplicar informação.

## 2. Relações entre entidades

Use `entity_relations`.

Exemplos:

- `friend_of`
- `family_of`
- `works_at`
- `manager_of`
- `member_of`
- `located_at`

Toda relação DEVE indicar origem e destino.

## 3. Relações entre registros

Use `record_relations`.

Exemplos:

- `supports`
- `contradicts`
- `supersedes`
- `derived_from`
- `caused_by_claim`
- `related_to`
- `contributes_to`
- `blocks`
- `result_of`

`caused_by_claim` DEVE representar uma alegação de causalidade. Ele NÃO DEVE confirmar causalidade científica.

## 4. Registros e entidades

Use `record_entities`.

O campo `role` DEVE explicar o papel da entidade no registro.

Exemplos:

- `participant`
- `subject`
- `location`
- `owner`
- `responsible`
- `affected`
- `advisor`

## 5. Temporalidade

Relações mutáveis PODEM ter:

- `valid_from`;
- `valid_to`;
- `status`.

## 6. Origem

Relações importantes DEVEM ter origem quando possível.

## 7. Regra final

RELACIONE objetos quando houver vínculo real.

NÃO use relação apenas para aumentar conectividade do grafo.