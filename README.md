# MegaBrain

Sistema pessoal de conhecimento, memória e organização.

## Estado

A arquitetura documental está criada.

O schema do Supabase está em revisão e NÃO DEVE ser aplicado sem aprovação explícita.

## Arquitetura

```text
ChatGPT Project
├── GitHub: lógica do sistema
├── Supabase: memória persistente
└── Ferramentas externas: agenda, tarefas, e-mail e contatos
```

## Fonte de verdade

- GitHub DEVE conter regras, skills, arquitetura e schema.
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

## Diretórios

### `core/`

Contém regras obrigatórias, terminologia, catálogo, roteador e padrão de skill.

### `skills/`

Contém os procedimentos especializados do sistema.

### `data-model/`

Contém o modelo lógico, tipos de registro, relações, memória, busca semântica e schema SQL.

### `docs/`

Contém arquitetura, bootstrap e instruções do Projeto ChatGPT.

## Projeto ChatGPT

Use `docs/PROJECT-INSTRUCTIONS.md` como base para as Instruções do Projeto.

Use `docs/BOOTSTRAP.md` para configurar as integrações.

## Supabase

O arquivo `data-model/supabase-schema.sql` contém o schema inicial.

Ele usa:

- `sources`;
- `entities`;
- `entity_aliases`;
- `records`;
- `record_entities`;
- `entity_relations`;
- `record_relations`;
- `audit_log`;
- RLS por `owner_id`.

## Escrita

Toda documentação e todo registro textual DEVEM seguir os princípios do ASD-STE100 adaptados ao português.

Use frases curtas.

Use voz ativa.

Use um termo por conceito.

Use `DEVE`, `NÃO DEVE`, `PODE` e `PREFIRA` para indicar obrigação.

## Segurança

LEIA `SECURITY.md`.

NÃO grave credenciais ou dados pessoais neste repositório.