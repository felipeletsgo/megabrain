# BUSCA SEMÂNTICA

## 1. Objetivo

Adicionar recuperação por significado sem substituir os dados estruturados.

## 2. Estado

Esta função DEVE ser implementada após o schema principal estar validado.

## 3. Princípio

Busca vetorial DEVE gerar candidatos.

Ela NÃO DEVE determinar sozinha que dois registros representam o mesmo fato.

## 4. Implementação prevista

Use `pgvector` no Supabase.

Mantenha embedding separado do registro principal.

PREFIRA uma tabela `record_embeddings` com:

- `record_id`;
- `owner_id`;
- `model`;
- `embedding`;
- `content_hash`;
- `created_at`.

## 5. Dimensão

NÃO fixe a dimensão do vetor antes de escolher o modelo de embedding.

## 6. Atualização

Gere novo embedding quando o conteúdo indexado mudar.

Use `content_hash` para evitar processamento sem necessidade.

## 7. Busca híbrida

PREFIRA combinar:

- similaridade semântica;
- tipo de registro;
- entidade;
- período;
- estado;
- confiança.

## 8. Segurança

A tabela de embeddings DEVE usar o mesmo `owner_id` e RLS dos registros.