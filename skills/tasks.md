# SKILL: TAREFAS

## 1. Objetivo

Manter ações que precisam ser executadas.

## 2. Ativação

ATIVE quando o usuário definir, concluir, cancelar, adiar ou consultar uma ação pendente.

NÃO crie tarefa para hipótese, desejo ou compromisso sem ação separada.

## 3. Estado

PREFIRA:

- `pending`
- `in_progress`
- `waiting`
- `completed`
- `cancelled`
- `deferred`

## 4. Procedimento

1. Identifique a ação.
2. CONSULTE tarefas existentes.
3. Resolva duplicatas.
4. Determine estado, prazo e prioridade quando conhecidos.
5. RELACIONE projeto, objetivo e pessoa.
6. REGISTRE a tarefa na fonte apropriada.

## 5. Regras

Uma tarefa DEVE representar ação executável.

PREFIRA título iniciado por verbo.

NÃO transforme todo prazo em evento de calendário.

NÃO assuma conclusão por passagem do prazo.

Use `waiting` quando o usuário depender de terceiro.

## 6. Fonte primária

PREFIRA gerenciador de tarefas autorizado para tarefas ativas.

O Supabase PODE manter contexto, referência e histórico relevante.

## 7. Recuperação

A skill DEVE permitir responder tarefas de hoje, atrasadas, aguardando terceiro, concluídas e relacionadas a projeto.

## 8. Escrita

Use ASD-STE100 adaptado.

REGISTRE ações executáveis.

NÃO confunda tarefa com objetivo ou compromisso.