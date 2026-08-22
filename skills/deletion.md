# SKILL: EXCLUSÃO

## 1. Objetivo

Remover ou desativar informação conforme solicitação válida do usuário.

## 2. Ativação

ATIVE quando o usuário pedir para apagar, esquecer ou remover informação persistente.

## 3. Procedimento

1. Identifique os registros alvo.
2. Recupere dependências e relações.
3. Determine o alcance da solicitação.
4. Determine se exclusão lógica é suficiente.
5. Informe efeitos relevantes quando necessário.
6. Use `soft_delete_record(...)` para excluir um registro da memória ativa.
7. Verifique se outros registros ainda contêm a informação que o usuário pediu para esquecer.
8. Confirme o resultado quando útil.

## 4. Regras

NÃO mantenha informação excluída como memória ativa.

PREFIRA `soft_delete_record(...)` para exclusão normal de registro.

NÃO use `DELETE FROM records` como operação comum.

A exclusão lógica DEVE definir:

- `lifecycle = deleted`;
- `validity = retracted`.

Relações ativas ligadas ao registro excluído DEVEM deixar de participar da recuperação normal.

NÃO trate exclusão de um único registro como exclusão completa de uma pessoa, assunto ou período.

Uma solicitação ampla como `esqueça tudo sobre esta pessoa` DEVE recuperar dependências antes de alterar dados.

Exclusão física DEVE ser um fluxo separado.

O fluxo de exclusão física ainda NÃO DEVE ser executado automaticamente.

NÃO preserve conteúdo que o usuário pediu para esquecer quando isso contrariar a solicitação válida e puder ser removido pela ferramenta.

## 5. Ferramentas

Use:

- `search_memory(...)` para localizar registros;
- `get_record_context(...)` para verificar dependências;
- `soft_delete_record(...)` para exclusão lógica.

## 6. Falhas

Se o alvo for ambíguo:

PERGUNTE antes de remover informação importante.

Se a ferramenta não puder remover todo o conteúdo solicitado:

INFORME a limitação.

NÃO declare exclusão completa sem evidência.

## 7. Escrita

Use ASD-STE100 adaptado.