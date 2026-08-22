# MODELO DE MEMÓRIA

## 1. Objetivo

Definir como informação se transforma em memória persistente.

## 2. Camadas

Use estas camadas:

1. entrada de conversa ou ferramenta;
2. registro bruto ou factual;
3. relação com entidades;
4. memória útil;
5. memória consolidada;
6. reflexão e revisão.

## 3. Registro factual

Um fato ou evento DEVE preservar origem e tempo quando disponíveis.

## 4. Memória

Uma memória DEVE ter valor futuro.

Uma memória PODE resumir um ou mais registros.

## 5. Inferência

Uma inferência DEVE:

- ser identificada como inferência;
- possuir confiança;
- possuir evidências;
- poder ser invalidada.

## 6. Memória consolidada

Uma memória consolidada DEVE representar síntese sustentada por várias evidências.

NÃO apague as evidências após consolidar.

## 7. Contradição

Use `record_relations.relation_type = 'contradicts'` quando dois registros forem incompatíveis e a causa ainda não estiver resolvida.

Use `supersedes` quando um registro substituir outro por mudança temporal ou correção.

## 8. Validade

Use:

- `valid_from` para início de validade;
- `valid_to` para fim de validade;
- `occurred_at` para acontecimento;
- `created_at` para gravação.

NÃO use `created_at` como substituto de data do acontecimento.

## 9. Confiança

Use:

- `confirmed`
- `probable`
- `uncertain`
- `contradictory`
- `outdated`

## 10. Busca semântica

Busca semântica PODE ser adicionada com `pgvector`.

Embeddings DEVEM ser derivados do conteúdo persistente.

O texto original DEVE continuar sendo a fonte de verdade.

NÃO use similaridade vetorial como prova de relação factual.

## 11. Consolidação

Revisão diária PODE gerar memórias candidatas.

Revisão semanal PODE gerar candidatos a padrão.

Consolidação DEVE validar evidências antes de persistir síntese de nível superior.