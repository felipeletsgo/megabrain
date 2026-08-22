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
12. REGISTRE origem.
13. RELACIONE fontes e evidências.
14. Use idempotência quando houver risco de retry.
15. Grave a informação na fonte apropriada.

## 6. Regras

REGISTRE informação quando ela ajudar a responder perguntas futuras, explicar contexto, acompanhar mudança, decisão, objetivo, relação ou padrão.

Quando a informação for classificada como persistente e não houver impedimento de segurança ou ferramenta, a skill DEVE gravá-la.

NÃO transforme estado isolado em característica permanente.

NÃO transforme inferência em fato.

PRESERVE histórico relevante.

## 7. Certeza

Use `certainty`:

- `confirmed`
- `probable`
- `uncertain`

NÃO use certeza para representar conflito ou informação antiga.

## 8. Validade

Use `validity`:

- `current`
- `outdated`
- `disputed`
- `retracted`

## 9. Ciclo de vida

Use `lifecycle` para estado técnico do registro.

PREFIRA:

- `active`
- `archived`
- `superseded`
- `deleted`

Use `domain_status` para estado específico do tipo.

## 10. Origem

Use `sources`.

PREFIRA:

- `conversation`
- `calendar`
- `email`
- `contact`
- `document`
- `database`
- `integration`
- `inference`
- `manual`

Um registro PODE ter várias fontes por `record_sources`.

Use `raw_excerpt` quando for necessário preservar conteúdo original.

Use `normalized_content` para representação normalizada.

## 11. Persistência

CRIE novo registro para nova unidade de informação com identidade temporal ou semântica própria.

ATUALIZE quando houver detalhe adicional sem necessidade de preservar versão separada.

Use relação `supersedes` quando uma nova versão substituir informação histórica relevante.

NÃO sobrescreva histórico relevante.

## 12. Inferências

Uma inferência DEVE ter evidências relacionadas.

Uma inferência DEVE poder ser revisada.

Uma inferência NÃO DEVE usar `certainty = confirmed` sem evidência suficiente.

## 13. Auditoria

Mudanças persistentes DEVEM gerar auditoria automática quando suportado.

O log NÃO DEVE duplicar conteúdo pessoal completo sem necessidade.

## 14. Segurança

NÃO registre senha, token, chave de API, código de autenticação ou credencial.

## 15. Saídas

- novo registro;
- atualização;
- relação;
- correção;
- contradição;
- memória consolidada;
- nenhuma ação.

## 16. Escrita

Use ASD-STE100 adaptado em conteúdo normalizado.

NÃO reescreva conteúdo original de fonte apenas para cumprir o padrão documental.

REGISTRE menos.

REGISTRE melhor.

PRESERVE contexto e histórico.