# TERMINOLOGIA CONTROLADA

## 1. Objetivo

Definir um termo oficial para cada conceito.

O sistema DEVE usar estes termos em documentação e registros.

O sistema NÃO DEVE alternar sinônimos técnicos sem necessidade.

## 2. Termos principais

### Fato
Informação apresentada como verdadeira.

### Evento
Algo que ocorreu em um momento ou período.

### Estado
Condição temporária.

### Preferência
Gosto ou escolha relativamente estável.

### Opinião
Avaliação subjetiva atribuída a uma fonte.

### Hipótese
Possibilidade ainda não confirmada.

### Inferência
Conclusão produzida pelo sistema a partir de evidências.

### Memória consolidada
Síntese persistente derivada de vários registros.

### Pessoa
Entidade humana identificável.

### Relação
Ligação entre objetos persistentes.

### Organização
Empresa, instituição, grupo ou entidade coletiva.

### Lugar
Local físico ou lógico relevante.

### Objetivo
Resultado desejado.

### Projeto
Iniciativa com resultado definido e múltiplas ações.

### Decisão
Escolha realizada entre alternativas ou cursos de ação.

### Plano
Intenção futura ainda não executada.

### Tarefa
Ação executável.

### Compromisso
Atividade associada a data ou horário.

### Hábito
Comportamento recorrente individual.

### Rotina
Sequência recorrente de ações.

### Problema
Condição que exige resolução ou acompanhamento.

### Ideia
Possibilidade que pode gerar ação futura.

### Evidência
Registro ou fonte que sustenta uma afirmação ou inferência.

### Origem
Fonte de onde a informação veio.

### Certeza
Nível de certeza epistemológica associado ao registro.

### Validade
Estado atual da validade da informação.

### Ciclo de vida
Estado técnico do objeto persistente.

### Estado de domínio
Estado específico do tipo de registro.

## 3. Certeza

Use somente:

- `confirmed`
- `probable`
- `uncertain`

## 4. Validade

Use somente:

- `current`
- `outdated`
- `disputed`
- `retracted`

## 5. Ciclo de vida de registro e relação

Use somente:

- `active`
- `archived`
- `superseded`
- `deleted`

## 6. Ciclo de vida de entidade

Use somente:

- `active`
- `archived`
- `merged`
- `deleted`

## 7. Origem

Use, quando aplicável:

- `conversation`
- `calendar`
- `email`
- `contact`
- `document`
- `database`
- `integration`
- `inference`
- `manual`

## 8. Conteúdo de fonte

`raw_excerpt` representa conteúdo original preservado da fonte.

`normalized_content` representa conteúdo normalizado para uso do sistema.

ASD-STE100 adaptado DEVE ser aplicado a `normalized_content`.

NÃO reescreva `raw_excerpt` apenas para adequar o texto ao padrão documental.

## 9. Regra final

Se um novo conceito exigir novo termo, documente o termo neste arquivo antes de usar variantes em várias skills.