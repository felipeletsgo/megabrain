# API OPERACIONAL DO SUPABASE

## 1. Objetivo

Definir as operações seguras que agentes DEVEM usar para ler e gravar memória.

PREFIRA estas funções a SQL livre quando a função aplicável existir.

## 2. Identidade do Brain

Antes da primeira operação persistente em uma execução, use:

`get_primary_brain_identity()`

A função retorna:

- `owner_id`;
- `self_entity_id`;
- nome lógico do Brain.

NÃO grave `owner_id` em instruções do Projeto.

NÃO memorize o UUID como dado pessoal.

Resolva a identidade em tempo de execução.

## 3. Escrita principal

Use:

`ingest_memory_bundle(owner_id, idempotency_key, bundle)`

A função grava uma unidade lógica de memória.

A função DEVE preservar atomicidade da ingestão.

O pacote PODE conter:

- `source`;
- `entities`;
- `records`;
- `record_entities`;
- `record_relations`;
- `entity_relations`;
- `historical_record_relations`.

## 4. Idempotência

`idempotency_key` DEVE identificar uma operação lógica.

Use a mesma chave em retry da mesma operação.

NÃO reutilize a chave para operação diferente.

Uma ingestão concluída retorna o resultado existente em novo retry.

## 5. Fonte

Exemplo:

```json
{
  "source_type": "conversation",
  "external_id": "conversation-message-id",
  "title": "Relato do usuário",
  "raw_excerpt": "Texto original quando necessário"
}
```

`raw_excerpt` PODE preservar o texto original.

NÃO aplique ASD-STE100 ao texto original da fonte.

## 6. Entidades

Cada entidade nova no pacote DEVE ter `client_key`.

Exemplo:

```json
{
  "client_key": "person_ana",
  "entity_type": "person",
  "canonical_name": "Ana",
  "aliases": [
    {
      "alias": "Aninha",
      "alias_type": "nickname"
    }
  ]
}
```

Use `entity_id` quando a entidade já existir.

Use `self` como referência à entidade canônica do usuário.

NÃO crie nova entidade antes de verificar duplicata.

## 7. Registros

Cada registro novo DEVE ter:

- `client_key`;
- `record_type`.

PREFIRA também:

- `normalized_content`;
- `record_date` ou `occurred_at` quando aplicável;
- `certainty`;
- `validity`;
- `domain_status` quando aplicável.

Exemplo:

```json
{
  "client_key": "event_1",
  "record_type": "event",
  "title": "Conversa com Ana",
  "normalized_content": "Conversou com Ana sobre o Projeto Atlas.",
  "record_date": "2026-08-22",
  "certainty": "confirmed",
  "validity": "current"
}
```

## 8. Ligações entre registro e entidade

Use `record_entities`.

Exemplo:

```json
{
  "record": "event_1",
  "entity": "person_ana",
  "role": "participant"
}
```

## 9. Relações internas do pacote

Use `record_relations` quando os dois registros forem criados no mesmo pacote.

Exemplo:

```json
{
  "source_record": "state_1",
  "target_record": "event_1",
  "relation_type": "related_to"
}
```

## 10. Relações com histórico

Use `historical_record_relations` quando um lado da relação já existir no banco.

Uma referência PODE ser:

- `client_key` de registro novo;
- UUID de registro existente.

Exemplo:

```json
{
  "source_record": "new_preference",
  "target_record": "UUID-DO-REGISTRO-ANTIGO",
  "relation_type": "supersedes"
}
```

## 11. Resolução de entidade

Use:

`find_entities(owner_id, query, entity_types, limit)`

A função pesquisa:

- nome canônico;
- alias;
- tipo de entidade.

A pontuação é um indicador de correspondência.

Ela NÃO prova identidade.

PERGUNTE quando duas entidades continuarem plausíveis e a distinção for material.

## 12. Busca de memória

Use:

`search_memory(owner_id, query, record_types, entity_ids, from, to, limit)`

A função suporta:

- busca textual em português;
- filtro por tipo;
- filtro por entidade;
- filtro temporal;
- ordenação por relevância e tempo.

A função NÃO retorna registros com:

- `lifecycle = deleted`;
- `validity = retracted`.

## 13. Contexto de registro

Use:

`get_record_context(owner_id, record_id, include_raw_source)`

A função retorna:

- registro;
- entidades;
- fontes;
- relações de entrada;
- relações de saída.

Use `include_raw_source = false` por padrão.

Use `true` somente quando a evidência original for necessária.

## 14. Correção e mudança

Use:

`supersede_record(owner_id, old_record_id, new_record_id, is_correction, source_id)`

Use `is_correction = true` quando o registro antigo estava incorreto.

Nesse caso, o registro antigo recebe:

- `lifecycle = superseded`;
- `validity = retracted`.

Use `is_correction = false` para mudança temporal válida.

Nesse caso, o registro antigo recebe:

- `lifecycle = superseded`;
- `validity = outdated`.

## 15. Exclusão lógica

Use:

`soft_delete_record(owner_id, record_id, reason)`

A função remove o registro da memória ativa.

Ela define:

- `lifecycle = deleted`;
- `validity = retracted`.

Ela também encerra relações ativas do registro.

NÃO use `DELETE FROM records` como operação normal.

## 16. Auditoria

Mudanças importantes em tabelas principais geram auditoria automática.

Conteúdo textual e JSON sensível DEVEM aparecer no log como hash quando aplicável.

O log de auditoria NÃO DEVE ser alterado por clientes normais.

## 17. Segurança

As funções operacionais são destinadas ao backend privilegiado.

NÃO exponha `service_role` ao cliente.

RLS DEVE permanecer ativo.

## 18. Regra final

RESOLVA a identidade do Brain.

RECUPERE antes de criar.

GRAVE de forma atômica.

USE idempotência.

PRESERVE origem.

PRESERVE histórico.

NÃO improvise mutações quando existir operação segura.