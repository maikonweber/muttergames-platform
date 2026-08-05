# 23 — Plano de Implantação

**Versão:** 0.1.0

---

## 1. Estratégia

Rollout **progressivo**: devnet → staging → mainnet com feature flags, liquidez limitada e caps baixos no dia 1.

---

## 2. Ambientes & Contas

| Env | Cloud | Chain | Notas |
|-----|-------|-------|-------|
| dev | shared | Solana Devnet | Developers |
| staging | isolated | Devnet ou mainnet programs shadow | Soak tests |
| prod | isolated account | Solana Mainnet | Multisig authorities |

---

## 3. Pipeline CI/CD

```
PR → CI (lint, unit, security scan)
  → Preview deploy (off-chain)
  → Merge main
  → Deploy staging
  → Manual approval gate
  → Deploy prod services
  → (separado) Program deploy via multisig ceremony
```

**Programs nunca** fazem auto-deploy em mainnet a partir do CI sem aprovação humana multisig.

---

## 4. Cerimônia Mainnet MVP

1. Gerar program keypairs em offline machine  
2. Deploy programs  
3. Init configs (fees, pause=true inicialmente)  
4. Create mint `$MUTTER` + metadata  
5. Setup vesting streams  
6. Fund treasury / liquidity wallets  
7. Verify on explorers  
8. Run smoke tests com pause=true  
9. Unpause módulos gradualmente  
10. Abrir store whitelist → public  

Checklist de segurança assinada antes do passo 9.

---

## 5. Ordem de Enablement (feature flags)

| Ordem | Feature | Cap inicial |
|-------|---------|-------------|
| 1 | Transfers token | — |
| 2 | Vesting claims | — |
| 3 | Store primary sales | softlist studios |
| 4 | NFT fixed marketplace | volume cap diário |
| 5 | Staking | pool cap |
| 6 | Rewards claim | season 0 |
| 7 | Public marketing push | — |

Bridge e DAO só em fases próprias.

---

## 6. Rollback

| Componente | Rollback |
|------------|----------|
| Backend | Redeploy versão N-1 + feature flag off |
| Indexer | Replay from checkpoint |
| Program bug | Pause; hotfix upgrade via multisig; communicate |
| Bad metadata | Freeze listing; patch off-chain URI se mutável |

---

## 7. Observabilidade no Go-Live

- Dashboards: tx success, lag indexer, error rate API, bridge (quando houver)
- On-call rota 24/7 primeira semana
- Status page pública
- War room Slack/Teams

---

## 8. Comunicação

| Audiência | Canal | Conteúdo |
|-----------|-------|----------|
| Users | Blog/Discord | O que abre, riscos, tutoriais |
| Studios | Dev Portal | SDK versions, limits |
| Holders | Token disclosure | Vesting, supply explorer |
| Auditors/public | GitHub | Addresses, reports summary |

---

## 9. Pós-deploy (D+1 … D+30)

- Daily invariant checks (supply, vaults)
- Review fees/refunds
- Tune rate limits
- Collect SDK bug reports
- Preparar escopo V1 / bridge

---

## 10. Critérios de Sucesso do Launch

- [ ] Zero incidentes SEV0/SEV1 na 1ª semana  
- [ ] Uptime API ≥ 99.9%  
- [ ] Smoke e2e prod verdes  
- [ ] Relatórios públicos de addresses publicados  
- [ ] Suporte respondendo < 4h úteis  
