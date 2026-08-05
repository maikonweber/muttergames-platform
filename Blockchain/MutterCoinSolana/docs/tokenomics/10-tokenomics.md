# 10 — Tokenomics Completo — MutterCoin (`$MUTTER`)

**Versão:** 0.1.0  
**Status:** Draft para aprovação  
**Chain canônica:** Solana (SPL Token-2022)

---

## 1. Visão Econômica

`$MUTTER` é o **medium of exchange**, **fee token**, **staking asset** e **governance token** (progressivo) do ecossistema MutterCorp.

**Utility:**
- Pagar fees de marketplace, bridge e launchpad (desconto vs outras moedas)
- Stake para rewards, tiers e (V2) votação
- Rewards de games, seasons e liquidity mining
- Colateral de incentivos para studios e guildas

---

## 2. Supply

| Parâmetro | Valor proposto |
|-----------|----------------|
| **Ticker** | `MUTTER` |
| **Standard** | SPL Token-2022 |
| **Decimals** | 9 |
| **Max Supply** | **10.000.000.000** (10B) |
| **Initial Circulating (TGE)** | **8–12%** do max (ver emissão) |
| **Mint pós-TGE** | Apenas via **emission controller** (rewards) até caps; sem mint livre |

> Modelo **capped supply** com emissões programadas a partir de reservas de rewards (pré-mintadas em vesting/treasury PDAs), **não** mint infinito.

---

## 3. Alocação (Max Supply 10B)

| Bucket | % | Tokens | Lock / Vesting | Notas |
|--------|---|--------|----------------|-------|
| Comunidade & Rewards (play, seasons, airdrops) | 28% | 2.80B | Emissão 48–60 meses | Motor GameFi |
| Ecossistema & Grants (studios) | 12% | 1.20B | DAO/multisig + cliffs | Crescimento supply side |
| Staking / Farming incentives | 10% | 1.00B | Emissão 36–48 meses | Bootstrap TVL |
| Tesouraria / Fundação | 10% | 1.00B | Multisig; spending policy | Ops, audits, partnerships |
| Equipe MutterCorp | 15% | 1.50B | **Cliff 12m + linear 36m** | Total 48m |
| Investidores (seed/private) | 12% | 1.20B | **Cliff 6–12m + linear 18–24m** | Por round |
| Advisors | 2% | 0.20B | Cliff 6m + linear 18m | |
| Liquidez (DEX/CEX/MM) | 6% | 0.60B | TGE parcial + MM vault | SOL/MUTTER + EVM |
| Marketing & Parcerias | 3% | 0.30B | Vesting 24m | Campaigns |
| Bridge / Insurance Fund | 2% | 0.20B | Locked; uso emergencial | Caps documentados |
| **Total** | **100%** | **10B** | | |

---

## 4. Circulação no TGE (exemplo)

| Fonte TGE | % do supply |
|-----------|-------------|
| Liquidez | 3.0% |
| Marketing inicial | 0.5% |
| Comunidade (airdrop genesis) | 2.0% |
| Advisors (se unlocked — preferir 0) | 0% |
| Equipe | 0% (cliff) |
| Investidores | 0–2% (conforme SAFT) |
| **Circulating estimado** | **~8–12%** |

---

## 5. Inflação / Emissão

Não há inflação ilimitada. Há **unlock schedule** + **emission de rewards** a partir de buckets.

### Curva de emissão de rewards (Comunidade + Staking/Farming)

| Ano | % do bucket rewards liberável (guide) |
|-----|----------------------------------------|
| Ano 1 | 35% |
| Ano 2 | 25% |
| Ano 3 | 20% |
| Ano 4 | 12% |
| Ano 5+ | 8% restante |

Emissões semanais on-chain via `EmissionController` com **cap** e possibilidade de **halving-like** ajuste por DAO (bounds).

---

## 6. Deflação & Sinks

| Sink | Mecânica |
|------|----------|
| Fee burn | 20–40% das protocol fees periodicamente queimadas |
| Craft / upgrade | Burn de items + fee $MUTTER |
| Loot / tickets | Sink de $MUTTER |
| Naming / cosmetics on-chain | Fee burn parcial |
| Slash penalty | Early unstake penalty → burn % + treasury % |

**Meta:** pressão deflacionária crescente com volume de uso, sem depender só de buyback.

---

## 7. Taxas (Fees)

| Ação | Fee sugerida | Destino |
|------|--------------|---------|
| Marketplace secondary | 2.0% | 50% treasury / 30% rewards / 20% burn |
| Primary game sale | 10–15% | Platform ops + grants |
| Bridge | 0.05–0.3% | Insurance + treasury |
| Launchpad | 2–5% raised | Treasury |
| Pager staking early exit | 5–15% | Burn/treasury |

Pagamento em `$MUTTER` → **desconto 25%** sobre fee equivalente em SOL/stable (incentivo de utility).

---

## 8. Staking

| Param | Valor inicial |
|-------|---------------|
| Min stake | 100 MUTTER |
| Lock options | 0 / 30 / 90 / 180 / 365 dias |
| Boost multiplicador | até 2.5x (lock + NFT + guild) |
| Reward source | Bucket staking/farming |
| Penalty early exit | Proporcional ao tempo restante |
| veMUTTER (V2) | lock → voting power não-transferível |

---

## 9. Farming

- Pools iniciais: `MUTTER-SOL`, `MUTTER-USDC`
- Weights ajustáveis por gauge (DAO V2)
- Dual incentives temporários para bootstrapping EVM pools (wrapped)

---

## 10. Tesouraria & Fundação

**Política:**
- Multisig 3/5 (MVP) → DAO timelock (V2)
- Relatório trimestral público (transparência)
- Reservas para auditoria, bug bounty, infra, liquidity

---

## 11. Bridge Accounting

```
canonical_supply_solana
  = max_supply
    - burned
    - locked_in_bridge_vault   # lastreia wrapped em outras chains

wrapped_supply_chain_i <= vault_locked_backing
```

Invariant monitorado 24/7; alerta SEV1 se divergência.

---

## 12. Modelo Econômico por Stakeholder

| Stakeholder | Como captura valor |
|-------------|--------------------|
| Jogador | Rewards, ownership, desconto fees |
| Studio | Vendas, royalties, grants |
| Holder | Staking yield, governança, appreciation por sinks |
| MutterCorp | Fees + valorização tesouraria (alinhar com DAO) |
| LPs | Farming incentives + trading fees DEX |

---

## 13. Riscos Tokenômicos & Mitigações

| Risco | Mitigação |
|-------|-----------|
| Unlock cliffs causam dumps | Vesting longo; MM; communications |
| Rewards hiperinflacionam float | Caps semanais; sinks; adjust DAO |
| Fee discount mata receita | Calibrar desconto; volume elasticity |
| Sybil farming rewards | Anti-sybil; skill-based; KYC em campaigns grandes |
| Bridge despeg wrapped | Invariant alerts; pause; insurance |

---

## 14. KPIs Econômicos

- Velocity do token
- % fees pagos em MUTTER
- Net emissions vs burns (mensal)
- Stickiness de stakers (avg lock)
- GMV / market cap ratio
- % supply em exchanges vs stake

---

## 15. Aprovação

- [ ] Tokenomics Owner
- [ ] Legal (utility vs security analysis por jurisdição)
- [ ] Product
- [ ] Security (authorities & vesting contracts)
