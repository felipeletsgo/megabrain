# MegaBrain

Sistema pessoal de conhecimento, memória e organização.

## Estado

O núcleo V1 do Supabase está ativo, auditado e validado.

A base contém:

- proprietário lógico;
- entidade `self`;
- fontes;
- registros;
- relações;
- auditoria com minimização de conteúdo;
- idempotência serializada;
- RLS;
- busca full-text e trigram;
- ingestão atômica;
- recuperação atual e histórica;
- autoridade de fonte externa;
- vocabulário controlado de relações;
- operações seguras de ciclo de vida;
- exclusão lógica;
- esquecimento irreversível confirmado;
- diagnóstico de integridade.

Busca vetorial com embeddings ainda NÃO está ativa.

## Arquitetura

```text
ChatGPT Project
├── GitHub: lógica do sistema
├── Supabase: memória persistente
└── Ferramentas externas: agenda, tarefas, e-mail e contatos
```

## Fonte de verdade

- GitHub DEVE conter regras, skills, arquitetura e migrations.
- Supabase DEVE conter dados pessoais persistentes.
- Ferramentas especializadas DEVEM manter seus dados operacionais atuais.

Dados pessoais NÃO DEVEM ser gravados neste repositório.

## Ordem de leitura

1. `AGENTS.md`
2. `core/RULES.md`
3. `core/RUNTIME.md`
4. `core/TERMINOLOGY.md`
5. `core/SKILL-CATALOG.md`
6. `core/SKILL-ROUTER.md`
7. `core/SKILL-SPEC.md`
8. skill aplicável em `skills/`
9. `docs/SUPABASE-API.md`
10. documentação do modelo em `data-model/`
11. migrations em `supabase/migrations/`

## Diretórios

### `core/`

Contém regras obrigatórias, kernel de runtime, terminologia, catálogo, roteador e padrão de skill.

### `skills/`

Contém os procedimentos especializados do sistema.

### `data-model/`

Contém o modelo lógico, tipos de registro, relações, memória e busca semântica planejada.

### `supabase/`

Contém migrations e testes do banco.

### `docs/`

Contém arquitetura, bootstrap, API operacional, auditorias e instruções do Projeto ChatGPT.

## Supabase V1

Tabelas pessoais principais:

- `brain_owners`;
- `sources`;
- `ingestion_batches`;
- `entities`;
- `entity_aliases`;
- `records`;
- `record_sources`;
- `record_entities`;
- `entity_relations`;
- `record_relations`;
- `audit_log`.

Catálogos técnicos:

- `record_entity_role_catalog`;
- `record_relation_type_catalog`;
- `entity_relation_type_catalog`.

O modelo separa:

- `certainty` — certeza;
- `validity` — validade;
- `lifecycle` — ciclo de vida;
- `domain_status` — estado específico do tipo;
- `authority_type` — fonte operacional;
- `sync_state` — estado de sincronização externa.

RLS está ativo em todas as tabelas pessoais.

Clientes autenticados NÃO DEVEM alterar diretamente o grafo de memória.

O `audit_log` é append-only para clientes normais.

Conteúdo pessoal em claro NÃO DEVE ser duplicado no log de auditoria quando puder ser representado por hash.

## API operacional

PREFIRA:

- `get_primary_brain_identity()` — identidade lógica;
- `ingest_memory_bundle(...)` — ingestão atômica e idempotente;
- `find_entities(...)` — resolução tolerante de entidade;
- `search_current_memory(...)` — estado atual;
- `search_memory(...)` — histórico;
- `get_record_context(...)` — fontes e relações;
- `supersede_record(...)` — correção ou mudança histórica;
- `soft_delete_record(...)` — exclusão lógica;
- `forget_record(...)` — esquecimento irreversível confirmado;
- `brain_integrity_report(...)` — diagnóstico estrutural.

LEIA `docs/SUPABASE-API.md` antes de criar nova operação persistente.

## Projeto ChatGPT

Use `docs/PROJECT-INSTRUCTIONS.md` como base para as Instruções do Projeto.

Use `docs/BOOTSTRAP.md` para configurar integrações.

## Escrita

Toda documentação e todo registro normalizado DEVEM seguir os princípios do ASD-STE100 adaptados ao português.

Conteúdo original de fonte NÃO DEVE ser reescrito apenas para cumprir o padrão documental.

Use frases curtas.

Use voz ativa.

Use um termo por conceito.

## Segurança

LEIA `SECURITY.md`.

NÃO grave credenciais ou dados pessoais neste repositório.
