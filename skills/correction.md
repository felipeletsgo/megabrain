# SKILL: CORREÇÃO

## 1. Objetivo

Corrigir informação persistente sem destruir histórico relevante.

## 2. Ativação

ATIVE quando o usuário corrigir um dado ou quando fonte confiável provar erro.

## 3. Procedimento

1. Identifique o registro incorreto.
2. Recupere contexto e fonte do registro.
3. Confirme a correção quando houver ambiguidade material.
4. Crie o registro corrigido com `ingest_memory_bundle(...)`.
5. Use `supersede_record(..., p_is_correction = true)` para substituir o registro incorreto.
6. Revise inferências derivadas.
7. Revise relações afetadas.
8. REGISTRE origem da correção.

## 4. Regras

A correção explícita do usuário DEVE prevalecer sobre inferência anterior.

O registro incorreto DEVE deixar de ser estado atual.

Para correção factual, PREFIRA:

- registro antigo com `validity = retracted`;
- registro antigo com `lifecycle = superseded`;
- relação `supersedes` do registro corrigido para o registro antigo.

NÃO edite silenciosamente o conteúdo antigo quando a versão anterior tiver valor histórico ou probatório.

ATUALIZE o mesmo registro somente quando a mudança for detalhe complementar e não alterar o significado anterior.

NÃO apague histórico que explique decisões ou eventos anteriores.

## 5. Ferramentas

Use:

- `search_memory(...)` para localizar o registro;
- `get_record_context(...)` para verificar fonte e relações;
- `ingest_memory_bundle(...)` para criar a versão correta;
- `supersede_record(...)` para aplicar a substituição.

NÃO use `UPDATE` livre para substituir informação histórica quando `supersede_record(...)` for aplicável.

## 6. Falhas

Se o registro antigo não puder ser identificado com segurança:

1. NÃO altere registros.
2. PERGUNTE quando a distinção for material.

Se a criação da nova versão falhar:

NÃO superseda o registro antigo.

## 7. Escrita

Use ASD-STE100 adaptado.