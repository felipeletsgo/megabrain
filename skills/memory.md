# SKILL: MEMÓRIA

## 1. Objetivo

Manter memória persistente útil, verificável e atualizada.

## 2. Ativação

ATIVE quando houver informação com valor futuro.

NÃO persista conversa trivial sem utilidade futura.

## 3. Entradas

- mensagem atual;
- contexto recuperado;
- entidades;
- eventos;
- decisões;
- objetivos;
- resultados de outras skills;
- ferramentas externas.

## 4. Classificação

Use, quando aplicável:

- fato;
- evento;
- estado;
- preferência;
- opinião;
- hipótese;
- objetivo;
- projeto;
- decisão;
- plano;
- tarefa;
- compromisso;
- inferência;
- memória consolidada.

## 5. Procedimento

1. Identifique a informação relevante.
2. Classifique a informação.
3. Identifique entidades.
4. Determine o contexto temporal.
5. CONSULTE registros existentes.
6. Verifique duplicatas.
7. Verifique contradições.
8. Determine se deve criar ou atualizar.
9. Determine `certainty`.
10. Determine `validity`.
11. Determine `lifecycle`.
12. Determine a fonte operacional quando aplicável.
13. REGISTRE origem.
14. RELACIONE fontes e evidências.
15. Use somente papéis e relações do vocabulário controlado.
16. Gere chave de idempotência para a ingestão.
17. Grave a unidade de mudança de forma atômica.

## 6. Regras

REGISTRE informação quando ela ajudar a responder perguntas futuras, explicar contexto, acompanhar mudança, decisão, objetivo, relação ou padrão.

Quando a informação for classificada como persistente e não houver impedimento de segurança ou ferramenta, a skill DEVE gravá-la.

NÃO transforme estado isolado em característica permanente.

NÃO transforme inferência em fato.

PRESERVE histórico relevante.

NÃO invente `relation_type` ou `role` fora dos catálogos do banco.

## 7. Certeza

Use `certainty`:

- `confirmed`;
- `probable`;
- `uncertain`.

NÃO use certeza para representar conflito ou informação antiga.

## 8. Validade

Use `validity`:

- `current`;
- `outdated`;
- `disputed`;
- `retracted`.

## 9. Ciclo de vida

Use `lifecycle` para estado técnico do registro.

PREFIRA:

- `active`;
- `archived`;
- `superseded`;
- `deleted`.

Use `domain_status` para estado específico do tipo.

## 10. Origem

Use `sources`.

PREFIRA:

- `conversation`;
- `calendar`;
- `email`;
- `contact`;
- `document`;
- `database`;
- `integration`;
- `inference`;
- `manual`.

Um registro PODE ter várias fontes por `record_sources`.

Use `raw_excerpt` somente quando a evidência original tiver valor futuro.

NÃO salve transcrição completa por padrão.

Use `normalized_content` para representação normalizada.

## 11. Autoridade operacional

Quando outra ferramenta mantiver o estado atual, REGISTRE quando útil:

- `authority_type`;
- `external_ref`;
- `sync_state`;
- `last_synced_at`.

PREFIRA a fonte operacional para dado atual.

NÃO deixe cópia `stale` ou `error` vencer Calendar, gerenciador de tarefas, e-mail ou contatos.

## 12. Persistência

Use `ingest_memory_bundle(...)` para criar unidade composta.

A função serializa chamadas com a mesma chave de idempotência.

PREFIRA ingestão atômica a vários `INSERT` independentes.

Use `historical_record_relations` quando registro novo precisar se ligar a registro histórico existente.

CRIE novo registro para nova unidade de informação com identidade temporal ou semântica própria.

Use `supersede_record(...)` quando nova versão substituir informação histórica relevante.

NÃO chame funções internas de ingestão.

NÃO sobrescreva histórico relevante.

## 13. Idempotência

Toda ingestão automatizada DEVE usar `idempotency_key` estável para a mesma operação lógica.

Um retry, inclusive simultâneo, NÃO DEVE criar cópia adicional da mesma memória.

## 14. Inferências

Uma inferência DEVE ter evidências relacionadas.

Uma inferência DEVE poder ser revisada.

Uma inferência NÃO DEVE usar `certainty = confirmed` sem evidência suficiente.

## 15. Auditoria

Mudanças persistentes DEVEM gerar auditoria automática quando suportado.

O log DEVE manter estrutura e hashes.

O log NÃO DEVE duplicar texto pessoal, nomes, aliases ou JSON sensível em claro.

## 16. Integridade

Use `brain_integrity_report(...)` em revisão periódica ou quando houver suspeita de inconsistência.

Investigue duplicata candidata antes de mesclar entidades.

## 17. Segurança

NÃO registre senha, token, chave de API, código de autenticação ou credencial.

Clientes normais NÃO DEVEM alterar diretamente as tabelas da memória.

## 18. Saídas

- novo registro;
- atualização;
- relação;
- correção;
- contradição;
- memória consolidada;
- nenhuma ação.

## 19. Escrita

Use ASD-STE100 adaptado em conteúdo normalizado.

NÃO reescreva conteúdo original de fonte apenas para cumprir o padrão documental.

REGISTRE menos.

REGISTRE melhor.

PRESERVE contexto e histórico.
