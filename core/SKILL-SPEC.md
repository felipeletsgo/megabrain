# PADRÃO DE SKILL

## 1. Objetivo

Definir a estrutura mínima e as seções condicionais das skills.

Uma skill DEVE conter somente seções com função real.

NÃO crie seção vazia apenas para cumprir um modelo.

## 2. Seções obrigatórias

Toda skill DEVE conter:

1. `Objetivo`
2. `Ativação`
3. `Procedimento` ou regras operacionais equivalentes
4. `Regras`
5. `Escrita`

Uma skill curta PODE combinar `Procedimento` e `Regras` quando a função continuar inequívoca.

## 3. Seções condicionais

Inclua quando aplicável:

- `Entradas`
- `Classificação`
- `Exceções`
- `Persistência`
- `Relações`
- `Ferramentas`
- `Saídas`
- `Falhas`
- `Exemplos`

NÃO inclua uma seção condicional sem conteúdo operacional necessário.

## 4. Objetivo

Defina uma função principal.

NÃO misture várias funções independentes na mesma skill.

## 5. Ativação

Defina quando usar a skill.

Defina quando NÃO usar a skill se houver risco de confusão.

## 6. Procedimento

Use passos numerados quando houver sequência obrigatória.

Cada passo DEVE conter uma ação principal.

NÃO transforme regras independentes em sequência falsa.

## 7. Regras

Use termos normativos.

PREFIRA:

- DEVE;
- NÃO DEVE;
- PODE;
- PREFIRA;
- CONSULTE;
- REGISTRE;
- ATUALIZE;
- RELACIONE;
- PERGUNTE.

## 8. Persistência

Quando a skill gravar dados, defina:

- o que DEVE persistir;
- o que PODE persistir;
- o que NÃO DEVE persistir;
- quando criar;
- quando atualizar;
- qual operação segura usar.

## 9. Ferramentas

Quando houver ferramenta especializada, defina:

- fonte primária;
- operação de leitura;
- operação de escrita;
- condição de falha.

PREFIRA APIs operacionais documentadas a SQL livre.

## 10. Falhas

Defina comportamento para:

- falta de dados;
- ambiguidade;
- conflito;
- erro de ferramenta.

NÃO invente resultado para compensar falha.

## 11. Exemplos

Inclua exemplos somente quando reduzirem ambiguidade.

NÃO use exemplos para repetir regra já clara.

## 12. Escrita

Toda saída documental DEVE seguir os princípios do ASD-STE100 adaptados ao português.

Use frases diretas.

Use um termo por conceito.

Remova texto sem função.