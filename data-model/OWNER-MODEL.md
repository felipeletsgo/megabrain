# MODELO DE PROPRIETÁRIO

## 1. Objetivo

Separar a identidade lógica do Brain da autenticação de um aplicativo futuro.

## 2. `brain_owners`

Cada conjunto de dados DEVE pertencer a um `brain_owner`.

O campo `auth_user_id` PODE permanecer vazio no início.

Isso permite operações administrativas antes de existir um frontend com Supabase Auth.

## 3. Aplicativo futuro

Quando um frontend usar Supabase Auth:

1. crie ou identifique o usuário em `auth.users`;
2. RELACIONE `brain_owners.auth_user_id` ao usuário;
3. use RLS para restringir acesso.

## 4. Integração administrativa

Ferramentas administrativas PODEM operar com privilégios que ignoram RLS.

Essas ferramentas DEVEM informar `owner_id` correto em todas as gravações.

## 5. Segurança

NÃO use `service_role` em cliente público.

RLS DEVE continuar ativo mesmo quando uma integração administrativa puder ignorá-lo.

## 6. Regra final

`owner_id` identifica o dono dos dados.

`auth_user_id` identifica uma credencial de aplicativo.

NÃO trate os dois conceitos como equivalentes.