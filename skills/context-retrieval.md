# SKILL: RECUPERAÇÃO DE CONTEXTO

## 1. Objetivo

Recuperar informação relevante antes de responder ou agir.

## 2. Ativação

ATIVE quando houver referência ao passado, entidade conhecida, comparação temporal ou referência indireta.

Exemplos:

- ele;
- ela;
- isso;
- de novo;
- aquele projeto;
- última vez;
- primeira vez.

## 3. Tipos de recuperação

Use, quando aplicável:

- entidade;
- tempo;
- texto;
- relação;
- episódio;
- fato;
- decisão;
- padrão.

## 4. Procedimento

1. Identifique a intenção.
2. Resolva entidades com `find_entities(...)` quando necessário.
3. Identifique o período.
4. Determine o tipo de recuperação.
5. Use `search_memory(...)` para recuperar candidatos.
6. Avalie relevância.
7. Avalie `certainty`.
8. Avalie `validity`.
9. Avalie `lifecycle`.
10. Use `get_record_context(...)` quando precisar de fonte, evidência ou relações.
11. Resolva conflitos.
12. Selecione somente o contexto necessário.
13. Use o contexto na resposta ou ação.

## 5. Fontes

PREFIRA a fonte primária.

Exemplos:

- calendário para compromisso;
- tarefas para ação ativa;
- contatos para dado de contato;
- e-mail para conteúdo de e-mail;
- Supabase para memória estruturada.

## 6. API de recuperação

Use `find_entities(...)` para:

- nome;
- alias;
- tipo de entidade.

Use `search_memory(...)` para:

- texto;
- tipo de registro;
- entidade;
- período;
- registros recentes.

Use `get_record_context(...)` para:

- fontes;
- papéis das entidades;
- relações com outros registros;
- evidências;
- auditoria contextual.

NÃO solicite `raw_excerpt` por padrão.

Use fonte bruta somente quando ela for necessária para verificar interpretação, origem ou auditoria.

## 7. Busca

PREFIRA filtro estruturado quando data, tipo ou entidade forem conhecidos.

Use busca textual para linguagem aproximada.

A busca textual DEVE gerar candidatos.

Ela NÃO DEVE provar que dois registros representam o mesmo fato.

Busca semântica vetorial PODE ser adicionada posteriormente.

## 8. Relevância

Recupere somente informação necessária.

NÃO carregue toda a memória sem necessidade.

## 9. Tempo

Para `última vez`, ordene pela data do acontecimento quando ela estiver disponível.

Para `primeira vez`, informe `primeiro registro encontrado` se a cobertura puder estar incompleta.

NÃO use `created_at` como data do acontecimento quando `occurred_at` existir.

## 10. Estado atual

Para perguntas sobre estado atual:

1. PREFIRA `validity = current`.
2. PREFIRA registro não `superseded` quando houver substituição válida.
3. Considere relações `supersedes`.
4. NÃO apresente registro `retracted` como estado atual.

## 11. Ausência

Ausência de resultado NÃO prova ausência de evento.

PREFIRA: `Não encontrei registro suficiente.`

## 12. Inferência

NÃO apresente inferência recuperada como fato.

PRESERVE a certeza registrada.

## 13. Falha

Se uma consulta falhar:

1. NÃO invente resultado.
2. Tente outra fonte segura.
3. Informe a limitação quando ela afetar a resposta.

## 14. Escrita

Use ASD-STE100 adaptado.

RECUPERE antes de assumir.

CONSULTE antes de perguntar.