# 06 — Fluxos de Negócio

**Versão:** 0.1.0

---

## 1. Fluxo de Receita (Revenue Streams)

```
┌─────────────────────────────────────────────────────────────┐
│                     RECEITAS MUTTERCORP / DAO               │
├─────────────────┬─────────────────┬─────────────────────────┤
│ Marketplace Fee │ Bridge Fee      │ Launchpad Fee           │
│ (games+NFTs)    │                 │                         │
├─────────────────┼─────────────────┼─────────────────────────┤
│ Primary sales   │ Secondary roy.  │ Partner integrations    │
│ cut (store)     │ protocol cut    │ (B2B SaaS API)          │
└─────────────────┴─────────────────┴─────────────────────────┘
            │
            ▼
   Tesouraria (Treasury)
            │
     ┌──────┼──────┐
     ▼      ▼      ▼
  Burn   Rewards  Grants/Ops
```

**Política sugerida (ajustável por DAO):**
- Fee marketplace secundário: **2.0%**
- Royalty creator: **0–10%** (definido na coleção; enforced best-effort + on-chain)
- Fee store primary (jogos): **10–15%** (negotiable enterprise)
- Bridge: **0.05–0.3%** + gas destino
- % das fees mensais queimadas: **20–40%** (governado)

---

## 2. Compra de Jogo (Primary Sale)

```
Jogador → Store UI → Quote (preço+fee)
       → Payment ($MUTTER/SOL)
       → Payment Service
       → Escrow/Settlement Program
       → Split:
            ├─ Studio (revenue share)
            ├─ Platform fee → Treasury
            └─ (opcional) Affiliate
       → Entitlement Service (licença)
       → Download token (assinado, TTL)
       → CDN entrega build
```

**Estados da ordem:** `created → paid → fulfilled → downloadable → refunded? → closed`

---

## 3. Trade Secundário de NFT

```
Seller lista → NFT em escrow
Buyer paga → Settlement
Split: Seller proceeds | Creator royalty | Protocol fee
NFT → Buyer
Indexer registra trade → Charts/histórico
```

**Atomicidade:** settlement em uma transação Solana (ou ix composta).

---

## 4. Economia In-Game → On-Chain

```
Game Server valida ação
    → Anti-cheat / rules
    → Mutter API (mint/reward authorization)
    → Assinatura ed25519 do minter authority (ou session)
    → Program executa mint/transfer
    → Jogador recebe asset
    → Webhook → Game Server confirma
```

**Regra de ouro:** o jogo **nunca** confia só no client; autoridade de mint fica no backend/studio + policies Mutter.

---

## 5. Staking → Boost → Governança

```
Stake $MUTTER
   ├─ Rewards emission (staking APR)
   ├─ Tier Launchpad
   ├─ Guild boost eligibility
   └─ (V2) veMUTTER → voting power
```

---

## 6. Bridge (negócio)

```
User paga amount + bridge fee
Lock origem
Relayer quorum
Mint destino
Treasury recebe fee
Risk engine atualiza limites
```

**Liq. de segurança:** Insurance Fund alimentado por % fees de bridge.

---

## 7. Launchpad

```
Studio aplica → Due diligence MutterCorp
Sale configurada (cap, price, vesting)
Users qualificam por stake tier
Contribution window
TGE → vesting contract
Claims periódicos
Fee launchpad → Treasury
```

---

## 8. Moderação & Compliance

```
Report → Fila mod
Evidência
Ação: warning | delist | ban | freeze (se policy)
Audit log
Appeal (humano)
```

---

## 9. Ciclo de Vida do Asset

```
Design (Studio)
 → Mint policy
 → Primary distribution (drop/shop/reward)
 → Secondary market
 → In-game utility
 → Burn / upgrade / craft (sink)
 → Archive metadata (Arweave)
```

---

## 10. Fluxo de Fundos da Tesouraria

| Entrada | Saída |
|---------|-------|
| Fees marketplace | Rewards seasons |
| Bridge fees | Grants studios |
| Launchpad | Ops / audit / infra |
| Parcerias | Buyback & burn (governado) |
| | Liquidity programs |

Toda saída acima de threshold exige **multisig** e, pós-DAO, **timelock + proposta**.
