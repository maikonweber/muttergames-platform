# Identidade, wallet e experiência do jogador

## Mutter ID

`player_id` é o identificador estável e não é um endereço blockchain. Um jogador pode ter wallet embutida, múltiplas wallets externas e contas distintas por jogo sem fragmentar inventário.

## Onboarding progressivo

1. Login por e-mail/social e aceite de termos.
2. Criação de wallet embutida pelo provedor, com chaves protegidas por MPC/passkey quando disponível.
3. Gameplay normal; fees patrocinadas dentro de orçamento e policy.
4. Ao negociar/retirar, exibir riscos, taxas, irreversibilidade e requisitos regionais.
5. Wallet externa é vinculada por challenge com domínio, nonce, issued_at e expiration.

## Sessões e autorização

- OIDC/OAuth 2.1, PKCE para clientes públicos, access token curto e refresh rotation.
- Device binding e step-up auth para retirada, venda e mudança de segurança.
- Service accounts usam mTLS/workload identity, nunca segredo embutido no jogo.
- Autorização combina RBAC operacional e ABAC (`region`, `risk_score`, `asset_policy`, `amount`).

## Wallet integration

- Adapter separa embedded wallet, WalletConnect/deep-link e Solana Wallet Standard.
- Transaction Orchestrator entrega transação serializada e explicação humana do efeito.
- Antes da assinatura: simular, validar program IDs, mint, slippage, fee, recipient e expiration.
- Sessões de jogo podem usar session keys limitadas por ação, valor, jogo e expiração; nunca podem transferir livremente.

## Recuperação e suporte

- Recuperação de Mutter ID não implica automaticamente recuperação de self-custody.
- Fluxos devem dizer claramente quem controla chaves.
- Alterar recovery factors inicia cooldown e notificação fora de banda.
- Suporte não solicita seed phrase/private key e não pode ignorar timelock.

## Privacidade

Endereço público, tx hash e metadados públicos são tratados como potencialmente identificáveis. PII não entra em NFT metadata, memo ou PDA. O vínculo player↔wallet fica cifrado e com acesso auditado.
