# 19 — Checklist de Segurança

**Versão:** 0.1.0  
Uso: gate de release mainnet (todos os itens P0 devem estar ✅)

---

## 1. Smart Contracts / Programs

| # | Item | Sev |
|---|------|-----|
| SC-01 | Reentrancy / CPI reentry analisado | P0 |
| SC-02 | Overflow/underflow (checked math) | P0 |
| SC-03 | Authority confusion (signer checks) | P0 |
| SC-04 | Account ownership / PDA bump seeds | P0 |
| SC-05 | Arbitrary CPI targets blocked | P0 |
| SC-06 | Token account freeze/mint assumptions | P0 |
| SC-07 | Pause funciona em todas ixs críticas | P0 |
| SC-08 | Fee math rounding favorites protocol safely | P0 |
| SC-09 | Royalty bypass paths revisados | P0 |
| SC-10 | Listing/offer expiry edge cases | P1 |
| SC-11 | Auction sniping / last-second rules | P1 |
| SC-12 | Staking reward index correctness | P0 |
| SC-13 | Vesting claim after end / cliff | P0 |
| SC-14 | Upgrade authority documentada | P0 |
| SC-15 | Idempotência de claims (merkle) | P0 |

---

## 2. Bridge

| # | Item | Sev |
|---|------|-----|
| BR-01 | Replay attack (nonce) | P0 |
| BR-02 | Signature/attestation forgery | P0 |
| BR-03 | Supply invariant monitoring | P0 |
| BR-04 | Quorum compromise thresholds | P0 |
| BR-05 | Chain reorg handling | P0 |
| BR-06 | Amount/decimals mismatch | P0 |
| BR-07 | Destination address spoofing | P0 |
| BR-08 | Rate limits enforced | P0 |
| BR-09 | Emergency pause per route | P0 |
| BR-10 | Relayer key compromise runbook | P0 |

---

## 3. DeFi / Econômico

| # | Item | Sev |
|---|------|-----|
| DF-01 | Flash loan vectors (se aplicável EVM) | P0 |
| DF-02 | Oracle manipulation (limites/preço) | P0 |
| DF-03 | MEV / front-running auctions mitigations | P1 |
| DF-04 | Governance attack (flash vote) | P0 |
| DF-05 | Timelock suficiente | P0 |
| DF-06 | Emission rug paths blocked | P0 |

---

## 4. Aplicação / API

| # | Item | Sev |
|---|------|-----|
| AP-01 | AuthN/AuthZ em todos endpoints | P0 |
| AP-02 | Rate limit / DOS protections | P0 |
| AP-03 | Injection (SQL/NoSQL/command) | P0 |
| AP-04 | SSRF webhooks | P0 |
| AP-05 | Path traversal downloads | P0 |
| AP-06 | Secure headers / CORS | P1 |
| AP-07 | Secret scanning CI | P0 |
| AP-08 | Admin audit logging | P0 |

---

## 5. Wallet / Assinaturas

| # | Item | Sev |
|---|------|-----|
| WA-01 | Signature replay (domain separation) | P0 |
| WA-02 | Session key scope/expiry | P0 |
| WA-03 | Blind signing avoided | P0 |
| WA-04 | Seed display gated + warned | P0 |
| WA-05 | Device binding custodial | P1 |

---

## 6. Operacional

| # | Item | Sev |
|---|------|-----|
| OP-01 | Multisig 3/5+ prod | P0 |
| OP-02 | Key ceremony recorded | P0 |
| OP-03 | Backup & restore testados | P0 |
| OP-04 | Monitoring/alerting on-chain | P0 |
| OP-05 | Bug bounty ready | P1 |
| OP-06 | Incident comms templates | P0 |

---

## 7. Compliance

| # | Item | Sev |
|---|------|-----|
| CM-01 | Privacy policy / ToS live | P0 |
| CM-02 | LGPD DSR process | P0 |
| CM-03 | No PII on-chain verified | P0 |
| CM-04 | Loot odds disclosure (se live) | P1 |

---

## Sign-off

| Papel | Nome | Data | Assinatura |
|-------|------|------|------------|
| Security Lead | | | |
| Tech Lead | | | |
| Product | | | |
