# BOOTSTRAP DO PROJETO

## 1. Objetivo

Configurar o Projeto ChatGPT para usar o MegaBrain.

## 2. Estado atual

O núcleo V1 do Supabase está aplicado.

RLS está ativo.

A auditoria automática está ativa.

A busca textual está ativa.

Busca semântica ainda NÃO está ativa.

## 3. Pré-requisitos

Conecte:

- GitHub;
- Supabase;
- Google Calendar quando necessário;
- gerenciador de tarefas quando escolhido;
- Gmail e Contacts quando úteis.

## 4. Instruções do Projeto

Copie o conteúdo operacional de `docs/PROJECT-INSTRUCTIONS.md` para as Instruções do Projeto.

## 5. GitHub

Use este repositório como fonte de verdade para:

- Regras-Mestre;
- terminologia;
- roteador;
- skills;
- arquitetura;
- migrations.

## 6. Supabase

Use `supabase/migrations/` como histórico canônico do DDL.

NÃO aplique novamente migrations já registradas.

Nova alteração estrutural DEVE criar nova migration.

## 7. Brain owner

O Brain principal já possui um `brain_owner` lógico.

Ele possui uma entidade `self` do tipo `person`.

O vínculo com Supabase Auth PODE ser criado no futuro.

## 8. Testes executados

O teste transacional V1 validou:

- criação de fonte;
- criação de entidade;
- criação de registro;
- relação entre registro e entidade;
- busca textual;
- auditoria automática;
- redação de conteúdo no log;
- idempotência.

O teste usou `ROLLBACK`.

Dados fictícios NÃO permaneceram no banco.

## 9. Próximos testes

Antes de uso amplo com memória real:

1. testar correção de registro;
2. testar supersessão;
3. testar contradição;
4. testar exclusão lógica;
5. testar recuperação por pessoa;
6. testar `última vez`;
7. testar múltiplas fontes;
8. testar ingestão composta em uma transação.

## 10. Próxima fase

Após validar o fluxo de memória real:

1. criar operação transacional de ingestão;
2. adicionar busca semântica;
3. escolher modelo de embedding;
4. criar revisão diária;
5. criar revisão semanal;
6. testar consolidação de memória.