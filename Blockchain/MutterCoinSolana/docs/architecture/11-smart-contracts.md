# 11 — Arquitetura dos Smart Contracts / Programs

**Versão:** 0.1.0  
**Stack alvo:** Anchor (Rust) em Solana · Solidity em spokes EVM

---

## 1. Inventário de Programs (Solana)

| Program ID (nome lógico) | Responsabilidade | Upgrade |
|--------------------------|------------------|---------|
| `mutter_marketplace` | Escrow, list, buy, offer, auction, fees, royalties split | Multisig |
| `mutter_staking` | Pools, locks, accrual, claim, penalty | Multisig |
| `mutter_farming` | LP stake, emission weights | Multisig |
| `mutter_rewards` | Merkle claims / dispensers | Multisig |
| `mutter_vesting` | Team/investors streams | Multisig |
| `mutter_treasury` | Guarded spends | Multisig→DAO |
| `mutter_dao` | Propose, vote, queue, execute | Multisig→immute params |
| `mutter_bridge` | Lock/burn, message emit, unlock mint authority | Multisig |
| `mutter_loot` | Open box + randomness consume | Multisig |
| `mutter_launchpad` | Sales, contribution, claim | Multisig |
| `mutter_guild` | Registry + roles leves | Multisig |
| `mutter_policy` | Global pause, fee bounds, allowlists | Multisig |

**Token:** criado via Token-2022 + metadata; authorities apontam para PDAs/`mutter_policy`.

**NFT:** Metaplex Core/Token Metadata/cNFT — Mutter não reimplementa o padrão base.

---

## 2. MutterCoin (SPL)

### Authorities
| Authority | Holder | Notas |
|-----------|--------|-------|
| Mint | `Emission PDA` / revogada para free mint | Só emissions |
| Freeze | `Policy PDA` (opcional, compliance) | Uso restrito |
| Update metadata | Multisig | |
| Transfer fee config | DAO/timelock (se habilitado) | Off por default MVP |

### Instruções chave
- Nenhuma custom necessária se Token-2022 puro + policy externa
- Hooks futuros: transfer hook para royalties enforcement (avaliar custo/complexidade)

---

## 3. Marketplace Program

### Contas
- `MarketplaceConfig` { fee_bps, pause, treasury, allowed_mints }
- `Listing` { seller, asset, price, currency, expiry }
- `Offer` { buyer, asset, price, expiry, escrow_payment }
- `Auction` { seller, reserve, start, end, highest_bid, bidder }

### Instruções
| Ix | Descrição |
|----|-----------|
| `init_marketplace` | Config inicial |
| `create_listing` / `cancel_listing` | Fixed price |
| `buy_listing` | Settlement atômico |
| `create_offer` / `cancel_offer` / `accept_offer` | Negociação |
| `create_auction` / `place_bid` / `settle_auction` | Leilão |
| `set_fees` | Dentro de bounds |
| `pause` / `unpause` | Emergência |

### Regras
- Royalties: ler creators do metadata; pagar shares; restante ao seller
- Fee protocol: `price * fee_bps / 10_000`
- Suporte currencies: MUTTER, SOL, (USDC P1)
- cNFT: usar APIs de transfer compressão compatíveis

---

## 4. Staking Program

### Contas
- `StakePool` { reward_mint, reward_rate, total_staked, lock_options }
- `UserStake` { owner, amount, lock_until, accrued, boost }

### Instruções
`create_pool`, `stake`, `unstake`, `claim`, `set_rate`, `apply_boost`, `pause`

### Matemática
- Accrual index (reward_per_token) para O(1) claim
- Boost = min(max_boost, f(lock, nft, guild))
- Penalty = remaining_lock_fraction * penalty_bps

---

## 5. Farming Program

- Aceita LP mint allowlisted
- Mesmo padrão de index de rewards
- `set_pool_weight` governado

---

## 6. Vesting Program

- `Stream` { beneficiary, total, cliff, start, end, claimed }
- `claimable = vested(now) - claimed`
- Revogável só se flag `revocable` (advisors); equipe tipicamente irrevogável pós-start

---

## 7. Treasury Program

- Roles: `proposer`, `approver`, `executor`
- Limits diários
- Destinos allowlisted (ops wallets, rewards funders)
- Integração DAO: execute após timelock

---

## 8. DAO Program

### Ciclo
```
Draft → Active Voting → Succeeded/Defeated → Queued (timelock) → Executed/Expired
```

### Params
- `voting_delay`, `voting_period`, `quorum_bps`, `threshold_bps`, `timelock_seconds`
- Poder: saldo staked / veMUTTER

### Instruções
`propose`, `vote`, `delegate`, `queue`, `execute`, `cancel`

---

## 9. Bridge Program (Solana side)

### Instruções
| Ix | Fluxo |
|----|-------|
| `stake_lock` / `lock_tokens` | Usuário → vault |
| `emit_message` | Nonce + payload hash |
| `mint_wrapped` / `unlock` | Após quorum proofs |
| `register_route` | Admin |
| `set_limits` | Rate limits |
| `pause_route` | Emergência |

### Segurança
- Replay protection por `nonce` + `src_chain` + `dst_chain`
- Quorum M-of-N validators/relayers
- Delay opcional para amounts > threshold

---

## 10. Loot Program

```
commit randomness request → fulfill → map roll to table → mint/transfer reward → mark box opened
```

Tabelas de probabilidade hash-ancoradas on-chain (`table_hash`).

---

## 11. Launchpad Program

- `Sale` { pricing, cap, start/end, vesting_id }
- `contribute`, `finalize`, `claim`
- Tier checks via staking CPI ou snapshot merkle

---

## 12. Rewards / Merkle Distributor

- `root` por season
- `claim(index, amount, proof)`
- Bitmap/claimed PDA anti-double-claim

---

## 13. EVM Spoke Contracts

```solidity
// Pseudocontrato lógico
interface IMutterBridgeGateway {
  function lock(uint256 amount, bytes32 destChain, bytes32 destAddr) external payable;
  function unlock(bytes calldata message, bytes calldata proof) external;
}

interface IMutterERC20 is IERC20 {
  function mint(address to, uint256 amount) external; // only gateway
  function burn(uint256 amount) external;
}
```

Padrões: OpenZeppelin, Ownable2Step, Pausable, ReentrancyGuard, EIP-712 se signatures.

---

## 14. Diagrama de Interação (CPI)

```
Wallet tx
  └─ marketplace.buy_listing
        ├─ token_transfer (payment)
        ├─ nft_transfer (asset)
        ├─ token_transfer (royalty creators[])
        └─ token_transfer (fee → treasury)

Wallet tx
  └─ staking.stake
        └─ token_transfer → vault PDA

Bridge
  └─ bridge.lock → vault
  └─ (off-chain quorum)
  └─ gateway.mint on EVM
```

---

## 15. Eventos / Logs

Todos os ixs emitem eventos Anchor ricos:
`ListingCreated`, `TradeExecuted`, `Staked`, `BridgeMessage`, `ProposalQueued`, etc.

Indexador depende exclusivamente de eventos + account diffs.

---

## 16. Ordem de implementação (pós-aprovação docs)

1. Token + vesting + treasury  
2. Marketplace fixed-price  
3. Staking  
4. Rewards merkle  
5. Offers/auctions  
6. Bridge  
7. Farming  
8. DAO  
9. Launchpad / loot / guilds  
