# SKILL: PESSOAS E RELACIONAMENTOS

## 1. Objetivo

Manter informação confiável sobre pessoas e relações.

## 2. Ativação

ATIVE quando houver pessoa relevante, alias, relação ou mudança de relação.

NÃO crie entidade persistente para pessoa sem valor futuro.

## 3. Procedimento

1. Identifique a pessoa.
2. CONSULTE pessoas existentes.
3. Resolva aliases.
4. Resolva ambiguidade.
5. Identifique fatos relevantes.
6. Identifique relações.
7. Determine contexto temporal.
8. RELACIONE eventos e entidades.
9. REGISTRE somente informação útil.
10. PRESERVE origem e histórico.

## 4. Identidade

Uma pessoa DEVE ter identificador único.

Use um nome principal.

Aliases PODEM incluir apelido, abreviação e nome antigo.

NÃO crie nova pessoa para um alias.

## 5. Relações

Uma pessoa PODE ter várias relações.

Diferencie relação de avaliação.

Exemplo:

- `colega` é relação.
- `confiável` é avaliação.

Registre início, fim e estado quando relevantes.

## 6. Estado

PREFIRA:

- `active`
- `inactive`
- `ended`
- `unknown`

## 7. Fatos e opiniões

REGISTRE fato como fato.

REGISTRE opinião como opinião.

NÃO transforme evento isolado em característica permanente.

## 8. Organizações e projetos

RELACIONE pessoa a organização e projeto quando houver vínculo real.

NÃO atribua responsabilidade sem evidência.

## 9. Duplicatas

Considere nome, alias, contato, organização e contexto.

NÃO una pessoas automaticamente quando houver risco de erro.

## 10. Privacidade

Minimize dados de terceiros.

NÃO registre segredo, documento sensível ou dado íntimo sem necessidade.

## 11. Saídas

- nova pessoa;
- atualização;
- alias;
- relação;
- ligação com evento ou projeto;
- correção;
- nenhuma ação.

## 12. Escrita

Use ASD-STE100 adaptado.

IDENTIFIQUE antes de criar.

RELACIONE antes de duplicar.

PRESERVE mudanças.