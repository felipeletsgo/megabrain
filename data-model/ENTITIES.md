# ENTIDADES

## 1. Objetivo

Representar objetos com identidade persistente.

## 2. Campos principais

Cada entidade DEVE possuir:

- `id`;
- `owner_id`;
- `entity_type`;
- `canonical_name`;
- `status`;
- `created_at`;
- `updated_at`.

Campos opcionais:

- `description`;
- `attributes`;
- `valid_from`;
- `valid_to`.

## 3. Tipos iniciais

PREFIRA:

- `person`
- `organization`
- `place`
- `asset`
- `topic`

Novos tipos PODEM ser adicionados quando houver necessidade recorrente.

## 4. Aliases

Use `entity_aliases` para:

- apelido;
- abreviação;
- nome antigo;
- nome alternativo.

NÃO crie nova entidade somente por variação de nome.

## 5. Pessoa

Dados específicos PODEM ficar em `attributes`.

Exemplos:

- data de nascimento;
- função;
- contexto de contato.

PREFIRA fonte externa para dados de contato quando ela existir.

## 6. Organização

RELACIONE pessoas e registros à organização.

NÃO duplique organização por nome comercial alternativo.

## 7. Lugar

NÃO invente endereço.

PREFIRA referências externas quando disponíveis.

## 8. Estado

PREFIRA:

- `active`
- `inactive`
- `merged`
- `archived`

## 9. Mesclagem

Quando duas entidades forem a mesma:

1. escolha a entidade principal;
2. mova aliases;
3. mova relações;
4. preserve referências;
5. marque a duplicata como `merged`.

NÃO apague histórico necessário para auditoria.