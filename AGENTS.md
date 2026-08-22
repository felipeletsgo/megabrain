# INSTRUÇÕES PARA AGENTES

## 1. Escopo

Este repositório contém a lógica do MegaBrain.

Ele NÃO contém a memória pessoal do usuário.

## 2. Ordem obrigatória

Antes de alterar comportamento:

1. LEIA `core/RULES.md`.
2. LEIA `core/TERMINOLOGY.md`.
3. LEIA `core/SKILL-ROUTER.md`.
4. LEIA a skill afetada.
5. LEIA `core/SKILL-SPEC.md` antes de criar nova skill.
6. LEIA `docs/SUPABASE-API.md` antes de alterar operações persistentes.

## 3. Escrita

Toda documentação DEVE seguir os princípios do ASD-STE100 adaptados ao português.

Use frases curtas.

Use voz ativa.

Use um termo por conceito.

## 4. Arquitetura

GitHub DEVE conter lógica, documentação e schema.

Supabase DEVE conter dados pessoais persistentes.

NÃO grave dados pessoais do usuário neste repositório.

## 5. Mudanças

PRESERVE compatibilidade com `core/RULES.md`.

ATUALIZE `core/SKILL-CATALOG.md` quando adicionar ou remover skill.

ATUALIZE `core/TERMINOLOGY.md` quando criar novo conceito técnico.

ATUALIZE o modelo de dados quando uma mudança exigir nova estrutura persistente.

Toda mudança de banco DEVE usar migration.

NÃO altere manualmente o schema sem registrar migration equivalente.

## 6. Segurança

NÃO adicione:

- senha;
- token;
- chave de API;
- segredo;
- exportação do banco pessoal;
- conversa privada;
- arquivo pessoal.

## 7. Banco

PRESERVE RLS.

NÃO desative políticas de segurança para facilitar desenvolvimento.

PREFIRA funções operacionais a SQL livre quando a função existir.

Use:

- `ingest_memory_bundle(...)` para ingestão composta;
- `find_entities(...)` para resolução de entidade;
- `search_memory(...)` para recuperação;
- `get_record_context(...)` para contexto e evidências;
- `supersede_record(...)` para mudança ou correção histórica;
- `soft_delete_record(...)` para exclusão lógica.

NÃO faça vários `INSERT` independentes quando uma única ingestão atômica puder representar a operação.

NÃO use `DELETE FROM records` como exclusão normal.

## 8. Migrations

`supabase/migrations/` DEVE representar o histórico aplicado ao banco.

NÃO altere uma migration já aplicada para mudar o passado.

Crie nova migration para nova alteração.