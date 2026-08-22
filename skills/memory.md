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

Use:

- fato;
- evento;
- estado;
- preferência;
- objetivo;
- decisão;
- hipótese;
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
9. REGISTRE origem.
10. REGISTRE confiança quando necessário.
11. RELACIONE evidências.
12. Grave a informação.

## 6. Regras

REGISTRE informação quando ela ajudar a responder perguntas futuras, explicar contexto, acompanhar mudança, decisão, objetivo, relação ou padrão.

NÃO transforme estado isolado em característica permanente.

NÃO transforme inferência em fato.

PRESERVE histórico relevante.

## 7. Confiança

Use:

- `confirmed`
- `probable`
- `uncertain`
- `contradictory`
- `outdated`

## 8. Origem

PREFIRA:

- `conversation`
- `calendar`
- `email`
- `contact`
- `document`
- `database`
- `integration`
- `inference`

## 9. Persistência

CRIE novo registro para novo evento, nova entidade, nova decisão, novo objetivo ou novo estado temporal.

ATUALIZE quando houver novo detalhe, correção, mudança de estado ou nova evidência.

NÃO sobrescreva histórico relevante.

## 10. Inferências

Uma inferência DEVE ter evidências relacionadas.

Uma inferência DEVE poder ser revisada.

## 11. Segurança

NÃO registre senha, token, chave de API, código de autenticação ou credencial.

## 12. Saídas

- novo registro;
- atualização;
- relação;
- correção;
- contradição;
- memória consolidada;
- nenhuma ação.

## 13. Escrita

Use ASD-STE100 adaptado.

REGISTRE menos.

REGISTRE melhor.

PRESERVE contexto e histórico.