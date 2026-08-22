# API OPERACIONAL DO SUPABASE

## 1. Objetivo

Definir operações seguras para ler e gravar memória.

PREFIRA estas funções a SQL livre.

Clientes autenticados DEVEM tratar as tabelas de memória como somente leitura.

Mutações DEVEM ocorrer pelo backend autorizado.

## 2. Identidade do Brain

Antes da primeira operação persistente da execução, use:

`get_primary_brain_identity()`

A função retorna:

- `owner_id`;
- `self_entity_id`;
- nome lógico do Brain.

NÃO fixe `owner_id` nas Instruções do Projeto.

Resolva a identidade em tempo de execução.

## 3. Escrita principal

Use:

`ingest_memory_bundle(owner_id, idempotency_key, bundle)`

A função grava uma unidade lógica de memória.

A função usa bloqueio transacional por chave de idempotência.

Duas tentativas simultâneas da mesma operação NÃO DEVEM gerar duplicatas.

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

Use a mesma chave no retry da mesma operação.

NÃO reutilize a chave para operação diferente.

## 5. Fonte

Use `external_id` quando a fonte tiver identificador estável.

PREFIRA `raw_excerpt` somente quando a evidência original tiver valor futuro.

NÃO grave a conversa completa por padrão.

Conteúdo original de fonte NÃO DEVE ser reescrito para ASD-STE100.

## 6. Entidades

Cada entidade nova no pacote DEVE ter `client_key`.

Use `entity_id` quando a entidade já existir.

Use `self` como referência à entidade canônica do usuário.

CONSULTE `find_entities(...)` antes de criar pessoa, organização ou lugar relevante.

NÃO una entidades ambíguas automaticamente.

## 7. Registros

Cada registro novo DEVE ter:

- `client_key`;
- `record_type`.

PREFIRA também:

- `normalized_content`;
- data aplicável;
- `certainty`;
- `validity`;
- `domain_status` quando aplicável.

### Autoridade operacional

Use estes campos quando outra ferramenta for a fonte operacional atual:

- `authority_type`;
- `external_ref`;
- `sync_state`;
- `last_synced_at`.

`authority_type` PODE ser:

- `supabase`;
- `calendar`;
- `task_manager`;
- `email`;
- `contacts`;
- `file`;
- `integration`;
- `external`.

`sync_state` PODE ser:

- `native`;
- `linked`;
- `stale`;
- `error`.

Para compromisso atual, PREFIRA calendário.

Para tarefa ativa, PREFIRA gerenciador de tarefas.

## 8. Vocabulário de relações

NÃO invente `relation_type` ou `role`.

Consulte:

- `record_entity_role_catalog`;
- `record_relation_type_catalog`;
- `entity_relation_type_catalog`.

O banco rejeita valor fora do catálogo.

Isso reduz sinônimos técnicos e deriva de nomenclatura.

## 9. Resolução de entidade

Use:

`find_entities(owner_id, query, entity_types, limit)`

A busca considera:

- nome canônico;
- alias;
- correspondência parcial;
- similaridade de texto.

A pontuação gera candidatos.

Ela NÃO confirma identidade.

## 10. Busca histórica

Use:

`search_memory(owner_id, query, record_types, entity_ids, from, to, limit)`

A função combina:

- full-text em português;
- correspondência parcial;
- similaridade trigram;
- filtro por tipo;
- filtro por entidade;
- filtro temporal.

Ela NÃO retorna registro `deleted` ou `retracted`.

Ela PODE retornar histórico `outdated` ou `superseded`.

## 11. Busca de estado atual

Use:

`search_current_memory(owner_id, query, record_types, entity_ids, limit)`

PREFIRA esta função quando a pergunta for sobre:

- estado atual;
- preferência atual;
- projeto atual;
- objetivo ativo;
- situação vigente.

Ela retorna somente:

- `lifecycle = active`;
- `validity = current`.

## 12. Contexto de registro

Use:

`get_record_context(owner_id, record_id, include_raw_source)`

A função retorna:

- registro;
- entidades;
- fontes;
- relações de entrada;
- relações de saída.

Use `include_raw_source = false` por padrão.

## 13. Correção e mudança

Use:

`supersede_record(owner_id, old_record_id, new_record_id, is_correction, source_id)`

Use `is_correction = true` para informação anterior incorreta.

O registro antigo recebe `validity = retracted`.

Use `is_correction = false` para mudança temporal válida.

O registro antigo recebe `validity = outdated`.

## 14. Exclusão lógica

Use:

`soft_delete_record(owner_id, record_id, reason)`

A função remove o registro da recuperação normal.

Ela NÃO apaga o conteúdo físico do registro.

O motivo livre NÃO é preservado no banco.

Quando informado, somente o hash do motivo é mantido.

## 15. Esquecimento irreversível

Use:

`forget_record(owner_id, record_id, confirm)`

Use somente quando o usuário pedir remoção real do conteúdo.

A função exige `confirm = true`.

A função:

- remove fisicamente o registro;
- remove ligações dependentes por integridade referencial;
- limpa conteúdo e referências externas das fontes ligadas ao registro.

A limpeza da fonte PODE reduzir evidência disponível para outros registros que compartilhavam a mesma fonte.

NÃO use esta função para exclusão normal.

## 16. Auditoria

Mudanças importantes geram auditoria automática.

O log guarda estrutura e hashes.

O log NÃO DEVE duplicar:

- texto normalizado;
- trecho original;
- nome canônico;
- alias;
- título;
- URI;
- identificador externo;
- JSON de atributos ou metadados.

## 17. Integridade

Use:

`brain_integrity_report(owner_id)`

A função verifica:

- entidade `self`;
- batches com falha;
- entidades duplicadas candidatas;
- inferências sem evidência;
- estados epistemológicos incompatíveis;
- registros externos desatualizados;
- registros sem fonte.

PREFIRA executar esta verificação em revisão periódica e após mudanças estruturais.

## 18. Segurança

RLS DEVE permanecer ativo.

Clientes `anon` NÃO DEVEM acessar a memória pessoal.

Clientes `authenticated` DEVEM usar acesso de leitura sujeito a RLS.

NÃO exponha `service_role` ao cliente.

NÃO chame funções internas de ingestão.

Use somente `ingest_memory_bundle(...)` como entrada pública de backend para ingestão composta.

## 19. Regra final

RESOLVA a identidade do Brain.

RECUPERE antes de criar.

GRAVE de forma atômica.

USE vocabulário controlado.

USE idempotência.

PRESERVE origem.

PRESERVE histórico.

USE a fonte operacional atual.

NÃO improvise mutações quando existir operação segura.
