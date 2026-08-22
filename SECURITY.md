# SEGURANÇA

## 1. Objetivo

Evitar exposição de dados pessoais e credenciais.

## 2. GitHub

Este repositório DEVE conter somente:

- regras;
- skills;
- documentação;
- schema;
- migrações sem dados pessoais.

NÃO grave memória pessoal no GitHub.

## 3. Segredos

NÃO grave:

- senha;
- token;
- chave de API;
- cookie;
- código de autenticação;
- chave privada;
- credencial de banco.

Use armazenamento de segredos da plataforma apropriada.

## 4. Supabase

RLS DEVE permanecer ativo.

PREFIRA acesso autenticado.

NÃO exponha `service_role` em cliente ou documentação.

## 5. Logs

Logs NÃO DEVEM incluir credenciais.

Minimize dados pessoais em logs técnicos.

## 6. Exportações

NÃO envie exportação do banco pessoal para este repositório.

Backups DEVEM permanecer em armazenamento privado apropriado.

## 7. Incidente

Se um segredo for publicado:

1. revogue o segredo;
2. gere novo segredo;
3. remova o segredo do estado atual;
4. trate o histórico Git como potencialmente comprometido;
5. revise acessos relacionados.