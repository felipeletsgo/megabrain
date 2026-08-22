# TIPOS DE REGISTRO

## 1. Objetivo

Definir valores controlados para `records.record_type`.

## 2. Tipos V1

### `fact`
Informação apresentada como verdadeira.

### `event`
Acontecimento ocorrido.

### `daily_log`
Síntese de um dia.

### `state`
Condição temporária.

### `preference`
Preferência persistente ou contextual.

### `opinion`
Avaliação subjetiva atribuída a uma fonte.

### `hypothesis`
Possibilidade ainda não confirmada.

### `goal`
Resultado desejado.

### `project`
Iniciativa com várias ações.

### `decision`
Escolha realizada.

### `plan`
Intenção futura ainda não executada.

### `task`
Ação executável.

### `commitment`
Compromisso temporal.

### `habit`
Comportamento recorrente.

### `routine`
Sequência recorrente.

### `financial_transaction`
Movimentação financeira.

### `subscription`
Compromisso financeiro recorrente.

### `health_record`
Registro de saúde ou bem-estar.

### `learning_record`
Registro de aprendizado.

### `media_item`
Conteúdo consumido ou acompanhado.

### `purchase`
Ciclo de compra.

### `idea`
Ideia com valor futuro.

### `problem`
Problema acompanhado.

### `memory`
Memória persistente derivada de informação útil.

### `consolidated_memory`
Síntese sustentada por várias evidências.

### `inference`
Conclusão produzida pelo sistema.

## 3. Estado epistemológico

Use `certainty` para certeza:

- `confirmed`
- `probable`
- `uncertain`

Use `validity` para validade:

- `current`
- `outdated`
- `disputed`
- `retracted`

Use `lifecycle` para ciclo de vida técnico:

- `active`
- `archived`
- `superseded`
- `deleted`

Use `domain_status` para o estado específico do tipo.

Exemplo:

Um objetivo PODE usar `domain_status = 'paused'` sem alterar `lifecycle = 'active'`.

## 4. Campos específicos

Use `attributes JSONB` para campos específicos do tipo.

NÃO use `attributes` para substituir campos comuns que precisam de consulta consistente.

Exemplo para `financial_transaction`:

```json
{
  "amount": 82.40,
  "currency": "BRL",
  "category": "alimentação",
  "transaction_type": "expense"
}
```

Exemplo para `state`:

```json
{
  "state_type": "energy",
  "value": 6,
  "scale_max": 10
}
```

## 5. Conteúdo

Use `normalized_content` para a representação normalizada.

A origem literal PODE permanecer em `sources.raw_excerpt`.

NÃO transforme uma hipótese em fato ao normalizar conteúdo.

## 6. Regra final

NÃO crie novo `record_type` apenas para armazenar um campo diferente.

Crie novo tipo somente quando o significado e o ciclo de vida forem distintos.