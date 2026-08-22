# SKILL: INTEGRIDADE

## 1. Objetivo

Detectar inconsistências na memória persistente.

## 2. Ativação

ATIVE quando houver:

- suspeita de duplicata;
- contradição;
- estado inválido;
- inferência sem evidência;
- batch com falha;
- fonte externa desatualizada;
- revisão periódica de integridade.

## 3. Procedimento

1. Resolva a identidade do Brain.
2. Use `brain_integrity_report(...)` para obter indicadores gerais quando aplicável.
3. Identifique a inconsistência específica.
4. Recupere registros envolvidos.
5. Compare IDs, datas, origem, certeza, validade e ciclo de vida.
6. Classifique o problema.
7. Corrija automaticamente somente quando a solução for inequívoca e segura.
8. PERGUNTE quando houver risco de perda de significado.
9. REGISTRE auditoria da correção quando relevante.
10. Execute novamente o relatório quando a correção tiver impacto estrutural.

## 4. Verificações nativas

`brain_integrity_report(...)` verifica:

- quantidade de entidades `self`;
- batches com falha;
- grupos de entidades com mesmo nome canônico e tipo;
- inferências sem evidência relacionada;
- registro `active` e `retracted` ao mesmo tempo;
- registro `superseded` ainda marcado como `current`;
- registros externos com `sync_state = stale` ou `error`;
- registros sem fonte.

Um alerta de duplicata NÃO prova que as entidades são iguais.

Um registro sem fonte PODE ser válido quando sua origem for manual ou não estiver disponível.

## 5. Classes

- duplicata candidata;
- contradição;
- relação inválida;
- estado epistemológico inválido;
- referência quebrada;
- temporalidade inconsistente;
- inferência sem evidência;
- sincronização externa desatualizada;
- batch com falha.

## 6. Regras

NÃO apague dado útil para resolver inconsistência.

PRESERVE histórico.

NÃO una entidades ambíguas automaticamente.

NÃO corrija registro externo `stale` sem consultar a fonte primária quando ela estiver disponível.

NÃO trate aviso do relatório como prova suficiente para alteração destrutiva.

## 7. Ferramentas

Use:

- `brain_integrity_report(...)` para diagnóstico geral;
- `find_entities(...)` para investigar duplicatas;
- `search_memory(...)` para histórico;
- `search_current_memory(...)` para estado atual;
- `get_record_context(...)` para evidências e relações;
- `supersede_record(...)` para correção ou mudança histórica.

## 8. Escrita

Use ASD-STE100 adaptado.
