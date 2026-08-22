# BOOTSTRAP DO PROJETO

## 1. Objetivo

Configurar o Projeto ChatGPT para usar o MegaBrain.

## 2. Pré-requisitos

Conecte:

- GitHub;
- Supabase;
- Google Calendar quando necessário;
- gerenciador de tarefas quando escolhido;
- Gmail e Contacts quando úteis.

## 3. Instruções do Projeto

Copie o conteúdo operacional de `docs/PROJECT-INSTRUCTIONS.md` para as Instruções do Projeto.

## 4. GitHub

Use este repositório como fonte de verdade para:

- Regras-Mestre;
- terminologia;
- roteador;
- skills;
- arquitetura;
- schema.

## 5. Supabase

NÃO aplique o schema automaticamente.

Revise `data-model/supabase-schema.sql`.

Após aprovação, aplique o schema no projeto Supabase correto.

## 6. Testes iniciais

Teste estes cenários após configurar o banco:

1. registrar um fato;
2. registrar um evento;
3. mencionar a mesma pessoa duas vezes;
4. corrigir um fato;
5. criar uma decisão;
6. consultar `última vez`;
7. registrar um estado temporário;
8. confirmar que o estado não virou característica permanente;
9. pedir origem de uma memória;
10. pedir exclusão de um registro de teste.

## 7. Dados de teste

Use dados fictícios durante validação.

NÃO use informação pessoal sensível antes de validar RLS e auditoria.

## 8. Próxima fase

Após validar o schema principal:

1. adicionar busca semântica;
2. escolher modelo de embedding;
3. criar revisão diária;
4. criar revisão semanal;
5. testar consolidação de memória.