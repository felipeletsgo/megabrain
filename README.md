# MegaBrain

Sistema pessoal de conhecimento, memória e organização.

## Estado

A arquitetura documental está criada.

O núcleo V1 do Supabase está ativo.

A base contém proprietário lógico, entidade `self`, fontes, registros, relações, auditoria, idempotência, RLS e busca textual.

Busca semântica com embeddings ainda NÃO está ativa.

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
3. `core/TERMINOLOGY.md`
4. `core/SKILL-CATALOG.md`
5. `core/SKILL-ROUTER.md`
6. `core/SKILL-SPEC.md`
7. skill aplicável em `skills/`
8. documentação do modelo em `data-model/`
9. migrations em `supabase/migrations/`

## Diretórios

### `core/`

Contém regras obrigatórias, terminologia, catálogo, roteador e padrão de skill.

### `skills/`

Contém os procedimentos especializados do sistema.

### `data-model/`

Contém o modelo lógico, tipos de registro, relações, memória e busca semântica planejada.

### `supabase/`

Contém as migrations aplicadas ao banco.

### `docs/`

Contém arquitetura, bootstrap e instruções do Projeto ChatGPT.

## Supabase V1

Tabelas principais:

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

O modelo separa:

- `certainty` — certeza;
- `validity` — validade;
- `lifecycle` — ciclo de vida;
- `domain_status` — estado específico do tipo de registro.

RLS está ativo em todas as tabelas pessoais.

O `audit_log` é append-only para clientes autenticados.

Conteúdo pessoal completo NÃO DEVE ser duplicado no log de auditoria.

## Projeto ChatGPT

Use `docs/PROJECT-INSTRUCTIONS.md` como base para as Instruções do Projeto.

Use `docs/BOOTSTRAP.md` para configurar as integrações.

## Escrita

Toda documentação e todo registro normalizado DEVEM seguir os princípios do ASD-STE100 adaptados ao português.

Conteúdo original de fonte NÃO DEVE ser reescrito apenas para cumprir o padrão documental.

Use frases curtas.

Use voz ativa.

Use um termo por conceito.

## Segurança

LEIA `SECURITY.md`.

NÃO grave credenciais ou dados pessoais neste repositório.