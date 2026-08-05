# MutterCoin (`$MUTTER`) — Sandbox Mint

Mint SPL **Token-2022** com metadata on-chain e logo `docs/logo (4).png`, alinhado ao tokenomics (10B max, 9 decimals).

## Contrato suficiente (sandbox)

| Camada | O quê |
|--------|--------|
| **Token-2022** | Programa nativo Solana — mint, transfer, burn, freeze |
| **Metadata Pointer + Token Metadata** | Nome, símbolo, URI (logo) on-chain |
| **`mutter_token` (Anchor)** | Emission controller com cap (`programs/mutter_token`) — deploy opcional |

No sandbox, o mint é criado via scripts TS (Token-2022). O program Anchor reforça o cap de supply quando for deployado.

## Comandos

```bash
npm install
npm run sandbox:validator    # sobe solana-test-validator (Docker :8899)
npm run sandbox:all          # setup → create mint → mint → info
```

Ou passo a passo:

```bash
npm run sandbox:setup        # wallet + airdrop localnet/devnet
npm run sandbox:create-mint  # Token-2022 + metadata (logo comprimida)
npm run sandbox:mint         # mint 100_000_000 MUTTER (1% sandbox)
npm run sandbox:info
```

Estado salvo em `token/offchain/deployed.json`.

Cluster padrão: **localnet** (`.env`). Para Devnet, ajuste `SOLANA_CLUSTER=devnet` e financie a wallet (faucet público costuma falhar).
