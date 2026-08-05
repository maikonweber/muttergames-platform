# Especificação dos programas Solana

## Escopo implementável do MVP

| Programa | Contas/PDAs | Instruções principais | Invariantes |
|---|---|---|---|
| `mutter_emission` | config, budget, grant_receipt | initialize, create_budget, claim, pause | minted ≤ cap; claim único; budget não negativo |
| `mutter_assets` | collection_policy, mint_record | create_collection, mint_asset, update_policy | definição aprovada; authority válida |
| `mutter_market` | market_config, order, escrow | list, cancel, buy | asset/valor trocados atomicamente |
| `mutter_policy` | global_policy, role | set_pause, set_bounds, grant_role | mudanças dentro de bounds/timelock |

Padrões base (Token-2022/Metaplex) não devem ser reimplementados.

## Evolução do código existente

O programa atual `mutter_token` já limita `total_minted`, pausa emissão e usa PDA como mint authority. Antes de uso real:

1. substituir `authority` única por role/multisig controlada;
2. impedir mint arbitrário introduzindo `RewardBudget` e voucher assinado;
3. verificar owner/programa de token, destination mint e decimals;
4. adicionar rotação de autoridade com pending authority + accept;
5. emitir eventos estruturados e testes de propriedades;
6. definir estratégia de upgrade authority e eventual imutabilidade;
7. reconciliar `total_minted` com supply pré-existente no initialize.

## Voucher de claim

Campos canônicos: `domain`, `cluster`, `program_id`, `player_wallet`, `budget_id`, `amount`, `nonce`, `issued_at`, `expires_at`, `game_id`, `event_hash`. Assinatura é verificada por instrução Ed25519 e ligada à transação. O receipt PDA deriva de `budget_id + nonce`.

## Marketplace

- `list`: valida coleção/policy, transfere asset ao escrow e congela termos.
- `buy`: valida currency mint, expiry e buyer; distribui seller/royalty/fee e entrega asset atomicamente.
- `cancel`: somente seller ou policy de emergência; devolve asset.
- Não aceitar token accounts arbitrárias sem validar mint/owner/authority.

## Segurança operacional

- Upgrade authority em multisig; mudança programada com timelock.
- Pause granular por programa/operação; `buy` e `cancel` devem ter política de saída segura.
- Caps por transação/dia e allowlist de mints/collections.
- Auditoria independente, bug bounty e deploy reproduzível antes da mainnet.

## Testes mínimos

- unit/integration em local validator; happy paths e toda classe de erro;
- fuzz/property: cap, conservação de valor, replay, overflow, ordem de contas;
- adversarial: signer falso, mint trocado, conta fechada, duplicate claim, stale quote;
- invariant monitor em produção: supply, escrow, budgets, settlement e autoridades.
