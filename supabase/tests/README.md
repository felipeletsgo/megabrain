# TESTES DO SUPABASE

## 1. Objetivo

Validar invariantes do MegaBrain após mudanças no banco.

Os testes NÃO DEVEM deixar dados persistentes.

## 2. Arquivos

### `001_core_invariants.sql`

Valida o núcleo V1:

- identidade primária;
- entidade `self`;
- ingestão atômica;
- idempotência;
- resolução de entidade;
- recuperação;
- supersessão;
- exclusão lógica.

### `002_audit_hardening.sql`

Valida as melhorias da auditoria:

- autoridade operacional;
- idempotência em retry;
- busca tolerante a erro de digitação;
- busca de estado atual;
- exclusão lógica;
- esquecimento irreversível;
- limpeza de fonte ligada ao conteúdo esquecido;
- vocabulário controlado;
- relatório de integridade.

## 3. Execução

Execute os arquivos em ambiente autorizado.

Cada teste DEVE usar transação e `ROLLBACK` quando criar dados fictícios.

Uma execução bem-sucedida DEVE terminar com o marcador definido pelo arquivo.

## 4. Invariantes principais

Valide:

- identidade primária única;
- entidade `self` única;
- ingestão atômica;
- idempotência;
- rollback em pacote inválido;
- resolução de entidade;
- busca atual e histórica;
- contexto e fonte;
- supersessão;
- correção;
- exclusão lógica;
- esquecimento irreversível confirmado;
- autoridade externa;
- vocabulário controlado;
- auditoria com minimização de conteúdo;
- ausência de vazamento de registro excluído na recuperação normal;
- relatório de integridade.

## 5. Dados

Use somente dados fictícios.

NÃO use memória pessoal real em teste estrutural.

## 6. Regra final

Uma migration que quebrar um invariante NÃO DEVE ser promovida sem correção.
