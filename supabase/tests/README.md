# TESTES DO SUPABASE

## 1. Objetivo

Validar invariantes do MegaBrain após mudanças no banco.

Os testes NÃO DEVEM deixar dados persistentes.

## 2. Execução

Execute os arquivos em ambiente autorizado.

Cada teste DEVE usar transação e `ROLLBACK` quando criar dados fictícios.

## 3. Invariantes principais

Valide:

- identidade primária única;
- entidade `self` única;
- ingestão atômica;
- idempotência;
- rollback em pacote inválido;
- resolução de entidade;
- busca de memória;
- contexto e fonte;
- supersessão;
- correção;
- exclusão lógica;
- auditoria sem duplicação de conteúdo bruto;
- ausência de vazamento de registro excluído na recuperação normal.

## 4. Dados

Use somente dados fictícios.

NÃO use memória pessoal real em teste estrutural.

## 5. Regra final

Uma migration que quebrar um invariante NÃO DEVE ser promovida sem correção.