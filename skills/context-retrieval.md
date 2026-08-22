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
- estado atual;
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
3. Identifique se a pergunta é atual ou histórica.
4. Identifique o período quando aplicável.
5. Use a função de recuperação adequada.
6. Avalie relevância.
7. Avalie `certainty`.
8. Avalie `validity`.
9. Avalie `lifecycle`.
10. Verifique `authority_type` quando a informação tiver fonte operacional externa.
11. Use `get_record_context(...)` quando precisar de fonte, evidência ou relações.
12. Resolva conflitos.
13. Selecione somente o contexto necessário.
14. Use o contexto na resposta ou ação.

## 5. Fontes

PREFIRA a fonte operacional atual.

Exemplos:

- calendário para compromisso;
- tarefas para ação ativa;
- contatos para dado de contato;
- e-mail para conteúdo de e-mail;
- Supabase para memória estruturada.

Se um registro externo estiver `stale` ou `error`, CONSULTE a fonte primária antes de afirmar o estado atual quando possível.

## 6. API de recuperação

Use `find_entities(...)` para:

- nome;
- alias;
- tipo de entidade;
- pequenas variações de escrita.

Use `search_current_memory(...)` para:

- estado atual;
- preferência atual;
- situação vigente;
- projeto atual;
- objetivo ativo.

Use `search_memory(...)` para:

- histórico;
- comparação temporal;
- primeira ocorrência;
- última ocorrência;
- registros antigos ou substituídos.

Use `get_record_context(...)` para:

- fontes;
- papéis das entidades;
- relações com outros registros;
- evidências;
- contexto de supersessão.

NÃO solicite `raw_excerpt` por padrão.

## 7. Busca

A busca combina:

- full-text em português;
- correspondência parcial;
- similaridade de texto;
- filtros estruturados.

A busca gera candidatos.

Ela NÃO prova que dois registros representam o mesmo fato ou a mesma entidade.

Busca vetorial PODE ser adicionada posteriormente.

## 8. Relevância

Recupere somente informação necessária.

NÃO carregue toda a memória sem necessidade.

## 9. Tempo

Para `última vez`, ordene pela data do acontecimento quando ela estiver disponível.

Para `primeira vez`, informe `primeiro registro encontrado` se a cobertura puder estar incompleta.

NÃO use `created_at` como data do acontecimento quando `occurred_at` existir.

## 10. Estado atual

Para perguntas sobre estado atual:

1. PREFIRA `search_current_memory(...)`.
2. PREFIRA fonte operacional atual quando existir.
3. NÃO apresente registro `superseded`, `outdated` ou `retracted` como estado atual.
4. Investigue `sync_state = stale` ou `error` antes de afirmar dado externo como atual.

## 11. Ausência

Ausência de resultado NÃO prova ausência de evento.

PREFIRA: `Não encontrei registro suficiente.`

## 12. Inferência

NÃO apresente inferência recuperada como fato.

PRESERVE a certeza registrada.

Recupere evidências quando a conclusão depender de inferência.

## 13. Falha

Se uma consulta falhar:

1. NÃO invente resultado.
2. Tente outra fonte segura.
3. Informe a limitação quando ela afetar a resposta.

## 14. Escrita

Use ASD-STE100 adaptado.

RECUPERE antes de assumir.

CONSULTE antes de perguntar.
