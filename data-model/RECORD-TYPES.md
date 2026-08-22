# TIPOS DE REGISTRO

## 1. Objetivo

Definir valores controlados para `records.record_type`.

## 2. Tipos iniciais

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

### `goal`
Resultado desejado.

### `project`
Iniciativa com várias ações.

### `decision`
Escolha realizada.

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

## 3. Campos específicos

Use `attributes JSONB` para campos específicos do tipo.

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

## 4. Regra

NÃO crie novo `record_type` apenas para armazenar um campo diferente.

Crie novo tipo somente quando o significado e o ciclo de vida forem distintos.