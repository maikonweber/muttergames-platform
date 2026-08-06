# PRJ-09 — MutterCoin (Solana)

**Pasta:** `Blockchain/MutterCoinSolana/`  
**Stack:** Anchor/Rust, Token-2022, scripts TypeScript  
**Status:** Especificação + sandbox (pré-mainnet)  
**Owner:** Blockchain / Jurídico (gates)

## 1. Objetivo

Token de utilidade `$MUTTER` e programas associados no ecossistema MutterGames. Gameplay permanece jogável sem chain; on-chain cobre propriedade, liquidação e economia verificável.

## 2. Decisões (Ecosystem)

- Solana canônica no MVP; bridge EVM fora do caminho crítico.
- Soft currency por jogo off-chain, não transferível.
- NFTs só cosméticos/colecionáveis — sem poder competitivo comprável.
- Nenhuma emissão aceita direto do cliente do jogo.

## 3. Docs

| Camada | Path |
|---|---|
| Docs históricas do token | [`Blockchain/MutterCoinSolana/docs/README.md`](../../Blockchain/MutterCoinSolana/docs/README.md) |
| Spec integrada | [`../product-specs/`](../product-specs/01-product-spec.md), [`../economy/`](../economy/01-economy-tokenomics.md), [`../smart-contracts/`](../smart-contracts/01-program-spec.md) |
| Segurança | [`../architecture/03-security-governance.md`](../architecture/03-security-governance.md) |
| Whitepaper consolidado | `outputs/MutterGames-Blockchain-Whitepaper.md` |

Em divergência, preferir `Ecosystem/` + ADR; docs do token são histórico detalhado.

## 4. Código sandbox

- Programa Anchor `mutter_token` (`programs/mutter_token`; IDs em `Anchor.toml`).
- Scripts TS + token SPL Token-2022 `$MUTTER`.
- Validator local típico via Docker na porta `:8899`.
- Rodar: `scripts/run-solana-local.sh` (CLI opcional).

Docs do pacote ainda rotulam fase de especificação/pré-mainnet — código sandbox **não** implica readiness de produção.

## 5. Gates obrigatórios (antes de mainnet)

1. Revisão jurídica.  
2. Threat model + auditoria externa.  
3. Teste econômico fechado com kill switch.  
4. Telemetria e reconciliação.
