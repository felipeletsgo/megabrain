# SKILL: INTEGRIDADE

## 1. Objetivo

Detectar inconsistências na memória persistente.

## 2. Ativação

ATIVE quando houver suspeita de duplicata, contradição, referência quebrada ou estado inválido.

## 3. Procedimento

1. Identifique a inconsistência.
2. Recupere registros envolvidos.
3. Compare IDs, datas, origem e confiança.
4. Classifique o problema.
5. Corrija automaticamente somente quando a solução for inequívoca e segura.
6. PERGUNTE quando houver risco de perda de significado.
7. REGISTRE auditoria da correção quando relevante.

## 4. Classes

- duplicata;
- contradição;
- relação órfã;
- estado inválido;
- referência quebrada;
- temporalidade inconsistente.

## 5. Regras

NÃO apague dado útil para resolver inconsistência.

PRESERVE histórico.

NÃO una entidades ambíguas automaticamente.

## 6. Escrita

Use ASD-STE100 adaptado.