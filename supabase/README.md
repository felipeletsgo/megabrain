# SUPABASE

## 1. Objetivo

Manter a memória persistente estruturada do MegaBrain.

## 2. Estado

O núcleo V1 está aplicado.

As migrations canônicas estão em `supabase/migrations/`.

NÃO altere produção com DDL manual sem criar uma migration correspondente.

## 3. Tabelas principais

- `brain_owners`
- `sources`
- `ingestion_batches`
- `entities`
- `entity_aliases`
- `records`
- `record_sources`
- `record_entities`
- `entity_relations`
- `record_relations`
- `audit_log`

## 4. Proprietário

Cada dado DEVE possuir `owner_id`.

O `brain_owner` é independente de Supabase Auth.

Um `auth_user_id` PODE ser vinculado depois.

## 5. Entidade self

Cada Brain DEVE possuir uma entidade `person` com `is_self = true`.

Use essa entidade como sujeito para fatos e eventos do próprio usuário quando necessário.

## 6. Estado epistemológico

Use:

- `certainty` para certeza;
- `validity` para validade;
- `lifecycle` para ciclo de vida;
- `domain_status` para estado específico do tipo.

NÃO misture esses conceitos.

## 7. Fontes

Use `sources.raw_excerpt` para preservar trecho original quando necessário.

Use `records.normalized_content` para a representação normalizada.

Um registro PODE ter várias fontes por `record_sources`.

## 8. Idempotência

Use `ingestion_batches.idempotency_key` para operações compostas.

Use `records.idempotency_key` quando um registro individual precisar de proteção contra repetição.

## 9. Auditoria

O `audit_log` é append-only para clientes autenticados.

A auditoria automática NÃO DEVE duplicar conteúdo pessoal completo.

Campos de conteúdo e JSON sensível são substituídos por hash no log.

## 10. RLS

RLS DEVE permanecer ativo.

Clientes autenticados DEVEM acessar somente o `brain_owner` vinculado ao próprio `auth.uid()`.

Integrações administrativas PODEM ignorar RLS.

Elas DEVEM informar o `owner_id` correto.

## 11. Exclusão

Clientes autenticados NÃO possuem permissão direta de `DELETE` nas tabelas principais.

PREFIRA mudança de `lifecycle` para operações normais.

Exclusão física DEVE usar procedimento administrativo explícito.

## 12. Busca

A V1 possui PostgreSQL Full Text Search em português por `records.search_document`.

Busca semântica com `pgvector` ainda NÃO está ativa.

## 13. Segurança

NÃO grave credenciais.

NÃO exponha `service_role` em cliente.

CONSULTE os advisors de segurança após migrations relevantes.

## 14. Regra final

Nova alteração estrutural DEVE gerar nova migration.

GitHub e histórico de migrations do Supabase DEVEM permanecer coerentes.