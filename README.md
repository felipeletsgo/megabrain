# MegaBrain

Sistema pessoal de conhecimento, memória e organização.

## Função

O MegaBrain DEVE:

- manter memória persistente;
- recuperar contexto antes de responder;
- organizar pessoas, eventos, projetos, objetivos e decisões;
- usar ferramentas externas para agenda, tarefas e outras funções especializadas;
- preservar histórico e origem;
- separar fatos de inferências;
- usar o Supabase como fonte de verdade dos dados estruturados.

## Arquitetura

```text
ChatGPT Project
├── Instruções do Projeto
├── GitHub: regras, skills e arquitetura
├── Supabase: memória persistente
└── Ferramentas externas
    ├── Calendar
    ├── Tasks
    ├── Gmail
    └── Contacts
```

## Diretórios

- `core/` — regras obrigatórias e roteamento.
- `skills/` — procedimentos especializados.
- `data-model/` — modelo lógico e schema do Supabase.
- `docs/` — arquitetura e instruções operacionais.

## Ordem de leitura

1. `core/RULES.md`
2. `core/TERMINOLOGY.md`
3. `core/SKILL-CATALOG.md`
4. `core/SKILL-ROUTER.md`
5. `core/SKILL-SPEC.md`
6. skill aplicável em `skills/`

## Escrita

Toda documentação e todo registro textual DEVEM seguir os princípios do ASD-STE100 adaptados ao português.

Use frases curtas.

Use voz ativa.

Use um termo por conceito.

Use `DEVE`, `NÃO DEVE`, `PODE` e `PREFIRA` para indicar obrigação.