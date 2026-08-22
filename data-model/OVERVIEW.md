# MODELO DE DADOS

## 1. Objetivo

Definir a memória persistente do MegaBrain.

O modelo DEVE suportar novas skills sem exigir uma tabela para cada skill.

## 2. Princípio

Use quatro objetos principais:

- `entities` — coisas relativamente estáveis;
- `records` — fatos, eventos e objetos temporais;
- `relations` — ligações entre objetos;
- `sources` — origem da informação.

## 3. Entidades

Use entidade para objetos com identidade própria.

Exemplos:

- pessoa;
- organização;
- lugar;
- projeto externo ou persistente quando necessário;
- objeto relevante recorrente.

## 4. Registros

Use registro para informação com conteúdo, estado ou temporalidade.

Tipos iniciais:

- `fact`
- `event`
- `daily_log`
- `state`
- `preference`
- `goal`
- `project`
- `decision`
- `task`
- `commitment`
- `habit`
- `routine`
- `financial_transaction`
- `subscription`
- `health_record`
- `learning_record`
- `media_item`
- `purchase`
- `idea`
- `problem`
- `memory`
- `consolidated_memory`
- `inference`

## 5. Relações

Use relações para evitar duplicação de texto.

Exemplos:

- pessoa participou de evento;
- projeto contribui para objetivo;
- decisão afetou projeto;
- memória foi derivada de eventos;
- fato contradiz outro fato;
- registro substitui registro anterior.

## 6. Flexibilidade

Campos comuns DEVEM permanecer estruturados.

Campos específicos de uma skill PODEM usar `attributes JSONB`.

NÃO coloque dados essenciais somente em texto livre quando eles puderem ser consultados de forma estruturada.

## 7. Temporalidade

Diferencie:

- quando algo ocorreu;
- quando algo passou a valer;
- quando deixou de valer;
- quando foi registrado.

## 8. Histórico

NÃO sobrescreva mudança relevante.

Use relações como `supersedes` quando um registro substituir outro.

## 9. Busca

O modelo DEVE suportar:

- busca estruturada;
- busca temporal;
- busca relacional;
- busca textual;
- busca semântica futura.

## 10. Segurança

Toda tabela pessoal DEVE ter `owner_id`.

RLS DEVE permanecer ativo.

O usuário DEVE acessar somente seus registros em clientes não privilegiados.