# INSTRUÇÕES PARA AGENTES

## 1. Escopo

Este repositório contém a lógica do MegaBrain.

Ele NÃO contém a memória pessoal do usuário.

## 2. Ordem obrigatória

Antes de alterar comportamento:

1. LEIA `core/RULES.md`.
2. LEIA `core/RUNTIME.md`.
3. LEIA `core/TERMINOLOGY.md`.
4. LEIA `core/SKILL-ROUTER.md`.
5. LEIA a skill afetada.
6. LEIA `core/SKILL-SPEC.md` antes de criar nova skill.
7. LEIA `docs/SUPABASE-API.md` antes de alterar operações persistentes.

## 3. Escrita

Toda documentação DEVE seguir os princípios do ASD-STE100 adaptados ao português.

Use frases curtas.

Use voz ativa.

Use um termo por conceito.

## 4. Arquitetura

GitHub DEVE conter lógica, documentação e migrations.

Supabase DEVE conter dados pessoais persistentes.

NÃO grave dados pessoais do usuário neste repositório.

## 5. Mudanças

PRESERVE compatibilidade com `core/RULES.md` e `core/RUNTIME.md`.

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

Clientes `anon` NÃO DEVEM acessar a memória pessoal.

Clientes `authenticated` NÃO DEVEM alterar diretamente o grafo de memória.

NÃO exponha `service_role`.

## 7. Banco

PRESERVE RLS.

NÃO desative políticas de segurança para facilitar desenvolvimento.

PREFIRA funções operacionais a SQL livre.

Use:

- `get_primary_brain_identity(...)` para identidade lógica;
- `ingest_memory_bundle(...)` para ingestão composta;
- `find_entities(...)` para resolução de entidade;
- `search_current_memory(...)` para estado atual;
- `search_memory(...)` para histórico;
- `get_record_context(...)` para contexto e evidências;
- `supersede_record(...)` para mudança ou correção histórica;
- `soft_delete_record(...)` para exclusão lógica;
- `forget_record(...)` para esquecimento irreversível confirmado;
- `brain_integrity_report(...)` para diagnóstico.

NÃO chame funções internas de ingestão.

NÃO faça vários `INSERT` independentes quando uma única ingestão atômica puder representar a operação.

NÃO use `DELETE FROM records` como exclusão normal.

Use somente relações e papéis presentes nos catálogos do banco.

## 8. Fonte operacional

Quando Calendar, gerenciador de tarefas, e-mail, contatos ou outra integração for fonte atual:

PRESERVE autoridade e referência externa quando úteis.

NÃO trate cópia `stale` como estado atual confiável.

## 9. Migrations

`supabase/migrations/` DEVE representar o histórico aplicado ao banco.

NÃO altere migration já aplicada para mudar o passado.

Crie nova migration para nova alteração.

Após migration:

1. execute testes de invariantes;
2. execute Security Advisor;
3. execute `brain_integrity_report(...)` quando aplicável;
4. sincronize o arquivo da migration no GitHub.
