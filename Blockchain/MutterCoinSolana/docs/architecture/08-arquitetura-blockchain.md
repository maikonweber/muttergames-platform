# 08 — Arquitetura Blockchain

**Versão:** 0.1.0  
**Hub:** Solana Mainnet  
**Token:** `$MUTTER` (SPL Token-2022)

---

## 1. Visão Hub-and-Spoke

```
                    ┌────────────────────┐
                    │   Ethereum L1      │  Liquidez / bluechip DeFi
                    └─────────▲──────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
    ┌────┴────┐         ┌─────┴─────┐        ┌─────┴─────┐
    │  Base   │         │ Arbitrum  │        │  Polygon  │
    └────▲────┘         └─────▲─────┘        └─────▲─────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │ Bridge Layer
                              │ (Lock/Mint · Burn/Unlock · Messages)
                              │
                    ┌─────────▼──────────┐
                    │  SOLANA (HUB)      │
                    │  Mutter Programs   │
                    │  $MUTTER canônico  │
                    │  NFTs · Markets    │
                    │  Staking · DAO     │
                    └─────────┬──────────┘
                              │
                    ┌─────────▼──────────┐
                    │ Games / Wallet /   │
                    │ Marketplaces       │
                    └────────────────────┘
```

**Princípio:** o **supply canônico** de `$MUTTER` vive em Solana. Em outras chains existem apenas representações wrapped lastreadas pelo bridge.

---

## 2. Programas On-Chain (Solana)

| Program | Função |
|---------|--------|
| `mutter_token` | Config Token-2022, authorities, fee hooks (se houver) |
| `mutter_nft_policy` | Policies de coleção, royalties enforcement helpers |
| `mutter_marketplace` | List, buy, offer, auction, escrow, fees |
| `mutter_staking` | Stake pools, locks, rewards accounting |
| `mutter_farming` | LP farms / gauge weights |
| `mutter_rewards` | Merkle distributor / season claims |
| `mutter_vesting` | Cliff+linear vesting |
| `mutter_treasury` | Spending with roles |
| `mutter_dao` | Proposals, votes, timelock exec |
| `mutter_bridge` | Lock/burn portals + message accounts |
| `mutter_loot` | Loot open com randomness account |
| `mutter_launchpad` | Sales + claim |
| `mutter_guild` | Guild PDA registry (leve) |

> NFTs base: preferir **Metaplex Token Metadata / Core / cNFT** + policies Mutter, em vez de reinventar padrão NFT completo.

---

## 3. Contas e PDAs (modelo)

```
Config PDA (global params, fees, pause flag)
Collection Policy PDA
Listing PDA ← escrow NFT token account
Offer PDA
Auction PDA
StakePool PDA
UserStake PDA
VestingStream PDA
BridgeRoute PDA
BridgeMessage PDA (nonce, status)
Treasury PDA
DaoProposal PDA
```

Todas as PDAs derivadas com seeds estáveis e bump documentados na spec de contratos.

---

## 4. Commitments & Finalidade

| Uso | Commitment |
|-----|------------|
| UX imediata (listagem UI) | `confirmed` |
| Settlement financeiro / bridge emit | `finalized` |
| Indexer tip | `confirmed` + reorg handling |

---

## 5. Fluxo de Transação (cliente)

```
1. Client solicita quote/instruções à API (opcional helper)
2. API devolve serialized tx parcial ou ix data
3. Wallet assina (user ou custodial HSM)
4. Submit via RPC dual-provider
5. Confirm + websocket notification
6. Indexer projeta estado
```

---

## 6. Integração Metaplex / Assets

| Tipo de asset | Tecnologia sugerida |
|---------------|---------------------|
| Skins/items high volume | **cNFT** (compressed) |
| Characters / lands 1/1 | Metaplex Core ou Token Metadata |
| Semi-fungível (stackable) | Token-2022 / SFT patterns |
| Licenças de jogo | Entitlement off-chain + optional NFT receipt |

---

## 7. Oráculos & Randomness

| Necessidade | Solução |
|-------------|---------|
| Preço $MUTTER/USD (display, risk) | Pyth / Switchboard |
| Loot randomness | Switchboard randomness / ORAO / commit-reveal |
| Bridge proofs | Light client / messaging protocol partner |

---

## 8. Upgradeabilidade

- Programs Solana: upgrade authority em **multisig Squads**
- Após maturidade DAO: transferir upgrade authority para timelock DAO
- Params mutáveis em PDAs (fees, caps) com bounds hard-coded
- Marker `paused` global e por módulo

---

## 9. Multichain Contracts (EVM spokes)

Por chain EVM suportada:
- `MutterTokenERC20` (wrapped, mintable by bridge only)
- `MutterBridgeGateway`
- `MutterTimelock` / Ownable2Step multisig
- Opcional: staking mirror (fase tardia; preferir stake no hub)

---

## 10. Segurança On-Chain (resumo)

- Checked math; overflow tests
- Authority separation (mint ≠ pause ≠ upgrade)
- Nonces em bridge messages
- Volume caps + delay para valores altos
- Eventos ricos para indexação e forense

Detalhes: [../security/18-arquitetura-seguranca.md](../security/18-arquitetura-seguranca.md)

---

## 11. Diagrama dos Contratos (relações)

```
[Token-2022 $MUTTER]
        │
        ├──────────────► [Staking] ──► rewards mint authority (limited)
        │
        ├──────────────► [Marketplace] ◄── [NFT Collections]
        │                      │
        │                      └── fees ──► [Treasury]
        │
        ├──────────────► [Farming]
        ├──────────────► [Vesting]
        ├──────────────► [Launchpad]
        ├──────────────► [Rewards/Merkle]
        ├──────────────► [DAO] ──timelock──► param updates / treasury
        └──────────────► [Bridge] ──messages──► EVM Gateways
```
