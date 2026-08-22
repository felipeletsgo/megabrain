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
Ligação entre duas entidades.

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
Registro que sustenta uma afirmação ou inferência.

### Origem
Fonte de onde a informação veio.

### Confiança
Nível de certeza associado ao registro.

## 3. Estados de confiança

Use somente:

- `confirmed`
- `probable`
- `uncertain`
- `contradictory`
- `outdated`

## 4. Origem

PREFIRA:

- `conversation`
- `calendar`
- `email`
- `contact`
- `document`
- `database`
- `integration`
- `inference`

## 5. Regra final

Se um novo conceito exigir novo termo, documente o termo neste arquivo antes de usar variantes em várias skills.