# ARQUITETURA

## 1. Objetivo

Definir onde cada parte do MegaBrain vive.

## 2. Componentes

```text
Usuário
  ↕
ChatGPT Project
  ├── Instruções curtas do Projeto
  ├── GitHub
  │   ├── Regras-Mestre
  │   ├── Roteador
  │   ├── Skills
  │   └── Modelo de dados
  ├── Supabase
  │   ├── Entidades
  │   ├── Registros
  │   ├── Relações
  │   ├── Fontes
  │   └── Auditoria
  └── Ferramentas externas
      ├── Calendar
      ├── Tasks
      ├── Gmail
      └── Contacts
```

## 3. GitHub

GitHub DEVE ser a fonte de verdade da lógica operacional.

GitHub contém:

- regras;
- terminologia;
- roteamento;
- skills;
- arquitetura;
- schema e migrações.

Dados pessoais NÃO DEVEM ser gravados no repositório.

## 4. Supabase

Supabase DEVE ser a fonte de verdade da memória estruturada.

Supabase contém:

- entidades;
- fatos;
- eventos;
- estados;
- decisões;
- objetivos;
- memórias;
- relações;
- origem;
- auditoria.

## 5. ChatGPT Project

O Projeto DEVE ser a camada de conversa e coordenação.

As Instruções do Projeto DEVEM ser curtas.

Elas DEVEM apontar para as regras e skills do GitHub.

## 6. Ferramentas externas

PREFIRA fonte especializada para informação operacional atual.

Exemplos:

- Google Calendar para agenda;
- gerenciador de tarefas para tarefas;
- Gmail para e-mails;
- Contacts para contatos.

Supabase PODE guardar referência e contexto.

## 7. Fluxo de leitura

Antes de responder a solicitação pessoal histórica:

1. aplique o roteador;
2. consulte a skill relevante;
3. recupere contexto necessário;
4. consulte fonte primária quando aplicável;
5. responda.

## 8. Fluxo de escrita

Antes de persistir:

1. classifique a informação;
2. aplique a skill relevante;
3. consulte registros existentes;
4. evite duplicatas;
5. preserve origem e tempo;
6. grave no Supabase ou ferramenta apropriada.

## 9. Segurança

NÃO grave credenciais no GitHub ou Supabase como memória.

RLS DEVE permanecer ativo no Supabase.

Use o menor privilégio necessário em cada integração.