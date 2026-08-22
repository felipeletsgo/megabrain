# MODELO DE MEMÓRIA

## 1. Objetivo

Definir como informação se transforma em memória persistente.

## 2. Camadas

Use estas camadas:

1. entrada de conversa ou ferramenta;
2. fonte;
3. registro factual ou temporal;
4. relação com entidades;
5. memória útil;
6. memória consolidada;
7. reflexão e revisão.

## 3. Fonte

A fonte DEVE representar a origem da informação.

Use `sources.raw_excerpt` quando for necessário preservar conteúdo original.

NÃO altere conteúdo original apenas para cumprir o padrão documental.

## 4. Registro

Um registro DEVE preservar origem e tempo quando disponíveis.

Use `records.normalized_content` para representação normalizada.

Um registro PODE ter várias fontes por `record_sources`.

## 5. Estado epistemológico

Use `certainty` para certeza:

- `confirmed`
- `probable`
- `uncertain`

Use `validity` para validade:

- `current`
- `outdated`
- `disputed`
- `retracted`

Use `lifecycle` para ciclo de vida técnico.

NÃO misture certeza, conflito e validade temporal.

## 6. Memória

Uma memória DEVE ter valor futuro.

Uma memória PODE resumir um ou mais registros.

## 7. Inferência

Uma inferência DEVE:

- ser identificada como inferência;
- possuir `certainty`;
- possuir evidências;
- poder ser invalidada.

## 8. Memória consolidada

Uma memória consolidada DEVE representar síntese sustentada por várias evidências.

NÃO apague as evidências após consolidar.

## 9. Contradição

Use `record_relations.relation_type = 'contradicts'` quando dois registros forem incompatíveis e a causa ainda não estiver resolvida.

Use `validity = 'disputed'` quando a validade atual estiver em conflito.

Use `supersedes` quando um registro substituir outro por mudança temporal ou correção.

## 10. Validade temporal

Use:

- `valid_from` para início de validade;
- `valid_to` para fim de validade;
- `occurred_at` para acontecimento;
- `created_at` para gravação.

NÃO use `created_at` como substituto de data do acontecimento.

## 11. Idempotência

Use `ingestion_batches.idempotency_key` para operações compostas.

Use `records.idempotency_key` para registros individuais quando necessário.

Retries NÃO DEVEM criar memórias duplicadas.

## 12. Auditoria

Mudanças persistentes DEVEM ser auditáveis.

O log técnico NÃO DEVE duplicar conteúdo pessoal completo sem necessidade.

PREFIRA hash para conteúdo que não precisa ser reproduzido no histórico.

## 13. Busca textual

A V1 usa Full Text Search do PostgreSQL em português.

Use `records.search_document` para recuperação textual.

## 14. Busca semântica

Busca semântica PODE ser adicionada com `pgvector`.

Embeddings DEVEM ser derivados do conteúdo persistente.

O texto original DEVE continuar sendo fonte de evidência.

NÃO use similaridade vetorial como prova de relação factual.

## 15. Consolidação

Revisão diária PODE gerar memórias candidatas.

Revisão semanal PODE gerar candidatos a padrão.

Consolidação DEVE validar evidências antes de persistir síntese de nível superior.