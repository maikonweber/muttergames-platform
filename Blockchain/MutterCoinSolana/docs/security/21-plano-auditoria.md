# 21 — Plano de Auditoria

**Versão:** 0.1.0

---

## 1. Objetivo

Reduzir risco de perda de fundos e falhas críticas antes de cada go-live relevante (MVP, Bridge, DAO).

---

## 2. Escopo por Fase

| Fase | Escopo auditável |
|------|------------------|
| **MVP** | Token authorities, vesting, treasury, marketplace fixed-price, staking, rewards merkle, backend custodial paths |
| **V1** | Offers/auctions, farming, bridge rotas P1, wallet session keys |
| **V2** | DAO/timelock, launchpad, loot VRF, guild treasury |
| **V3** | Novas rotas bridge, metaverso hooks |

---

## 3. Tipos de Auditoria

| Tipo | Quem | Quando |
|------|------|--------|
| Internal secure review | Security Lead + peers | Contínuo / cada PR crítico |
| External firm #1 | Firma Solana-experienced | Pré-mainnet MVP |
| External firm #2 (opcional mas recomendado) | Segunda opinião bridge | Pré-bridge mainnet |
| Economic review | Tokenomics + security | Pré-TGE |
| Pentest apps/APIs | Firma web3/appsec | Pré-launch wallet/store |
| Formal verification (seletivo) | Parceiro FV | Módulos math-heavy (opcional) |

---

## 4. Processo

```
Freeze feature scope
 → Spec + threat model entregues aos auditores
 → Código taggeado (commit hash)
 → Q&A period
 → Draft findings
 → Remediation
 → Retest
 → Public report (resumo) + full report privado
 → Deploy com monitoring reforçado
```

---

## 5. Severidade & SLA de Fix

| Sev | Definição | Gate |
|-----|-----------|------|
| Critical | Roubo fundos / mint infinito | Blocker absoluto |
| High | Bypass fee/pause, DoS grave fundos | Blocker |
| Medium | Impacto limitado | Fix antes ou waiver assinado |
| Low/Info | Higiene | Backlog |

---

## 6. Bug Bounty

Pós-mainnet:
- Plataforma: Immunefi ou equivalente
- Rewards alinhados a TVL
- Escopo: programs, bridge, critical APIs
- Safe harbor policy publicada

---

## 7. Entregáveis de Auditoria

- Relatório técnico
- Lista de findings com status
- Threat model atualizado
- Attestation de remediação
- Commit hashes auditados

---

## 8. Orçamento (placeholder)

Reservar linha na tesouraria: auditorias + bounty + war chest de incidentes (ver alocação Insurance/Treasury no tokenomics).
