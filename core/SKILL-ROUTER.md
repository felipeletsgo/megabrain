# ROTEADOR DE SKILLS

## 1. Objetivo

Identificar quais skills devem atuar em cada interação.

O usuário NÃO DEVE selecionar skills manualmente.

## 2. Procedimento

Para cada entrada:

1. Identifique a intenção.
2. Identifique entidades.
3. Identifique referências ao passado.
4. Identifique informação com valor futuro.
5. Identifique possíveis ações externas.
6. Selecione as skills necessárias.
7. Execute as skills na ordem adequada.
8. Responda de forma natural.

## 3. Ordem preferida

PREFIRA:

1. `context-retrieval`
2. identificação de entidades
3. classificação
4. skills de domínio
5. `memory`
6. ferramentas externas
7. resposta

A ordem PODE mudar quando a tarefa exigir.

## 4. Regras de ativação

- Pessoa relevante → `people-relationships`
- Acontecimento → `events-journal`
- Estado temporário → `states`
- Preferência → `preferences`
- Lugar → `places`
- Organização → `organizations`
- Objetivo → `goals`
- Iniciativa com várias ações → `projects`
- Escolha relevante → `decisions`
- Ação pendente → `tasks`
- Data ou horário de compromisso → `calendar`
- Recorrência → `habits-routines`
- Dinheiro → `finance`
- Saúde → `health-wellbeing`
- Estudo → `learning`
- Mídia consumida → `media-consumption`
- Compra → `purchases`
- Ideia → `ideas`
- Dificuldade persistente → `problems`
- Planejamento futuro → `planning`
- Revisão de decisão → `decision-review`

## 5. Recuperação

ATIVE `context-retrieval` quando a entrada depender do passado.

Exemplos:

- ele;
- ela;
- isso;
- de novo;
- como antes;
- aquele projeto;
- última vez;
- primeira vez.

PREFIRA recuperar contexto antes de perguntar.

## 6. Persistência

ATIVE `memory` quando a informação tiver valor futuro.

`memory` DEVE receber a saída das outras skills quando houver necessidade de persistência.

## 7. Revisões

ATIVE `daily-review` para consolidação diária.

ATIVE `weekly-review` para consolidação semanal.

ATIVE `memory-consolidation` quando vários registros sustentarem uma síntese útil.

ATIVE `reflection` quando a pergunta exigir análise de padrões ou tendências.

## 8. Integridade

ATIVE `integrity` quando houver suspeita de duplicata, contradição ou referência quebrada.

ATIVE `correction` quando o usuário corrigir dados.

ATIVE `deletion` quando o usuário pedir remoção.

ATIVE `audit` quando o usuário pedir origem, histórico ou justificativa.

## 9. Ambiguidade

PERGUNTE quando:

- duas entidades puderem corresponder ao mesmo termo;
- uma ação externa depender da interpretação;
- uma data não puder ser resolvida;
- uma informação crítica estiver contraditória.

NÃO pergunte quando o contexto resolver a dúvida com segurança.

## 10. Falha

Se uma ferramenta falhar:

1. NÃO invente resultado.
2. Preserve a intenção quando útil.
3. Informe a falha quando ela afetar o resultado.
4. Use alternativa segura quando disponível.

## 11. Conversa

O roteamento NÃO DEVE prejudicar a conversa.

O sistema NÃO DEVE transformar cada mensagem em relatório técnico.