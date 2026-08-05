# 22 — Estratégia de Testes

**Versão:** 0.1.0

---

## 1. Pirâmide

```
        /\
       /E2E\         Poucos, fluxos P0 (store buy, stake, list/buy NFT)
      /------\
     /Integr. \      API+DB+validator local; bridge sim
    /----------\
   /  Unit/Prop \    Maioria: math, parsers, services
  /--------------\
```

---

## 2. Programs (Solana)

| Tipo | Ferramenta | Foco |
|------|------------|------|
| Unit | Anchor tests / Rust tests | Instruções isoladas |
| Integration | solana-test-validator | Escrow settlement, CPI |
| Fuzz | honggfuzz / cargo-fuzz | Parsers, math |
| Invariant | Custom scripts | Supply, vault balances |
| Upgrade | Test deploy+migrate | Compat accounts |

Coverage alvo programas críticos: **≥ 90%**.

---

## 3. EVM Spokes

- Foundry/Hardhat: unit + fuzz invariant
- Fork tests mainnet para integrações
- Storage layout checks em upgrades (se proxy)

---

## 4. Backend

| Tipo | Escopo |
|------|--------|
| Unit | Domain logic |
| Contract tests | OpenAPI consumer-driven (P1) |
| Integration | Testcontainers Postgres/Redis |
| Load | k6/Locust em catalog/auth |
| Chaos | Mate RPC / fila e observe degradação |

---

## 5. SDK / Clients

- Golden path Unity CI (headless onde possível)
- Snapshot tests TS SDK
- Device matrix wallet mobile (P1)

---

## 6. Segurança em CI

- `cargo audit` / `npm audit`
- SAST
- Secret scan
- License check

---

## 7. Test Data & Environments

- Fixtures deterministicas
- Faucet devnet
- Synthetic users para load (nunca prod)

---

## 8. Gates de Release

| Gate | Critério |
|------|----------|
| Merge | Unit + lint verdes |
| Staging deploy | Integration + smoke e2e |
| Mainnet | Auditoria + checklist segurança + soak staging ≥ 7 dias |

---

## 9. Casos e2e P0 (obrigatórios)

1. Signup → buy game → download entitlement  
2. Mint/test NFT → list → buy → royalty paid  
3. Stake → wait accrual → claim → unstake  
4. Admin pause marketplace → buys fail safely  
5. Merkle reward claim success + double-claim fail  
