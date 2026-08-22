# SKILL: EXCLUSÃO

## 1. Objetivo

Remover ou desativar informação conforme solicitação válida do usuário.

Diferencie exclusão lógica de esquecimento irreversível.

## 2. Ativação

ATIVE quando o usuário pedir para:

- apagar;
- remover;
- esquecer;
- deixar de usar uma memória persistente.

## 3. Procedimento

1. Identifique os registros alvo.
2. Recupere dependências e relações.
3. Determine o alcance da solicitação.
4. Determine se o usuário quer retirada da memória ativa ou remoção real do conteúdo.
5. Verifique fontes compartilhadas.
6. Informe efeito relevante quando necessário.
7. Execute a operação apropriada.
8. Verifique se outros registros ainda contêm a informação solicitada.
9. Confirme o resultado quando útil.

## 4. Exclusão lógica

Use:

`soft_delete_record(...)`

Use quando o registro deve deixar de participar da memória ativa, mas o histórico técnico pode permanecer.

A função define:

- `lifecycle = deleted`;
- `validity = retracted`.

O conteúdo físico do registro PODE permanecer.

O motivo livre NÃO DEVE ser persistido.

Quando informado, somente o hash do motivo PODE ser mantido.

## 5. Esquecimento irreversível

Use:

`forget_record(owner_id, record_id, confirm)`

Use somente quando a solicitação exigir remoção real do conteúdo.

A função exige confirmação explícita por `confirm = true`.

Antes da execução:

1. confirme o alvo;
2. recupere dependências;
3. identifique fontes compartilhadas;
4. siga as regras aplicáveis a ação irreversível.

A função remove fisicamente o registro.

A função limpa conteúdo e referências externas das fontes ligadas ao registro.

Essa limpeza PODE reduzir a evidência disponível para outros registros que compartilhavam a mesma fonte.

## 6. Regras

NÃO mantenha informação esquecida como memória ativa.

NÃO use `DELETE FROM records` manualmente.

NÃO use `forget_record(...)` para limpeza rotineira.

NÃO trate exclusão de um registro como exclusão completa de uma pessoa, assunto ou período.

Uma solicitação como `esqueça tudo sobre esta pessoa` DEVE recuperar todos os registros e relações relevantes antes da alteração.

NÃO declare esquecimento completo sem evidência de que o alcance solicitado foi tratado.

## 7. Ferramentas

Use:

- `find_entities(...)` para resolver a entidade;
- `search_memory(...)` para localizar registros históricos;
- `get_record_context(...)` para verificar dependências;
- `soft_delete_record(...)` para exclusão lógica;
- `forget_record(...)` para esquecimento irreversível.

## 8. Falhas

Se o alvo for ambíguo:

PERGUNTE antes de remover informação importante.

Se a ferramenta não puder remover todo o conteúdo solicitado:

INFORME a limitação.

NÃO declare exclusão completa sem evidência.

## 9. Escrita

Use ASD-STE100 adaptado.
