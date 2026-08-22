# SEGURANÇA

## 1. Objetivo

Evitar exposição de dados pessoais e credenciais.

Aplicar privilégio mínimo.

## 2. GitHub

Este repositório DEVE conter somente:

- regras;
- skills;
- documentação;
- schema;
- migrations sem dados pessoais;
- testes com dados fictícios.

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

O papel `anon` NÃO DEVE acessar tabelas pessoais.

O papel `authenticated` DEVE tratar as tabelas de memória como somente leitura.

Mutações da memória DEVEM ocorrer por funções de backend autorizadas.

NÃO exponha `service_role` em cliente, código público ou documentação com valor de credencial.

NÃO conceda execução de função interna de ingestão ao cliente.

## 5. Auditoria

O `audit_log` DEVE ser append-only para clientes normais.

O log DEVE minimizar conteúdo pessoal.

PREFIRA hash para:

- texto normalizado;
- trecho original;
- nome;
- alias;
- título;
- URI;
- identificador externo;
- atributos;
- metadados.

O `search_document` NÃO DEVE permanecer em claro no log de auditoria.

## 6. Exclusão e esquecimento

Exclusão lógica e esquecimento são operações diferentes.

Use `soft_delete_record(...)` para retirada da memória ativa.

Use `forget_record(...)` somente para remoção irreversível explicitamente autorizada.

Antes de esquecer, verifique dependências e fontes compartilhadas.

NÃO declare esquecimento completo sem validar o alcance.

## 7. Fontes externas

Quando uma referência externa puder reexpor conteúdo esquecido, a operação de esquecimento DEVE remover a referência aplicável quando suportado.

NÃO considere a exclusão no Supabase como exclusão automática em Calendar, e-mail, arquivos ou outro serviço externo.

## 8. Exportações

NÃO envie exportação do banco pessoal para este repositório.

Backups DEVEM permanecer em armazenamento privado apropriado.

## 9. Incidente

Se um segredo for publicado:

1. revogue o segredo;
2. gere novo segredo;
3. remova o segredo do estado atual;
4. trate o histórico Git como potencialmente comprometido;
5. revise acessos relacionados.

## 10. Verificação

Após mudança de banco:

1. execute o Security Advisor;
2. execute testes de invariantes;
3. execute `brain_integrity_report(...)` quando aplicável;
4. confirme que migrations e GitHub estão sincronizados.
