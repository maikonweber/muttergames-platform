# 03 — Requisitos Não Funcionais (RNF)

**Versão:** 0.1.0  
**Status:** Draft

---

## 1. Escalabilidade

| ID | Requisito | Meta |
|----|-----------|------|
| RNF-ESC-001 | Suportar picos de marketplace | ≥ 5.000 TPS efetivos na camada app (filas + Solana) |
| RNF-ESC-002 | Indexer acompanhar tip da chain | Lag < 3s sob carga normal; < 15s sob pico |
| RNF-ESC-003 | Horizontal scale de microserviços | Autoscaling por CPU/RPS/fila |
| RNF-ESC-004 | Particionamento de dados hot (trades, events) | Sharding lógico por game_id / time |
| RNF-ESC-005 | CDN para assets estáticos e builds | Hit ratio ≥ 90% |

---

## 2. Performance

| ID | Requisito | Meta |
|----|-----------|------|
| RNF-PERF-001 | Latência API p95 (leitura) | ≤ 200 ms |
| RNF-PERF-002 | Latência API p95 (escrita off-chain) | ≤ 500 ms |
| RNF-PERF-003 | Confirmação Solana UX | Feedback < 2s; finality conforme commitment confirmed/finalized |
| RNF-PERF-004 | Tempo de abertura do catálogo marketplace | ≤ 1.5s first contentful |
| RNF-PERF-005 | SDK inventory sync | ≤ 3s para 1.000 items |

---

## 3. Custo & Gas

| ID | Requisito | Meta |
|----|-----------|------|
| RNF-COST-001 | Custo médio mint NFT (Solana) | Minimizar via compressão / batch quando aplicável |
| RNF-COST-002 | Fee de marketplace transparente | Exibida antes da confirmação |
| RNF-COST-003 | Preferir operações batched | Batch mint, batch claim |
| RNF-COST-004 | Bridge fee = custo operacional + margem DAO | Documentado por rota |
| RNF-COST-005 | Evitar storage on-chain desnecessário | Metadata off-chain com hash on-chain |

---

## 4. Disponibilidade & Resiliência

| ID | Requisito | Meta |
|----|-----------|------|
| RNF-AVL-001 | Uptime API / Portal | ≥ 99.9% mensal |
| RNF-AVL-002 | Uptime Indexer (leitura degradada ok) | ≥ 99.5% |
| RNF-AVL-003 | Multi-AZ / multi-region para serviços críticos | Ativo-ativo ou ativo-passivo |
| RNF-AVL-004 | Graceful degradation se RPC falhar | Failover multi-RPC |
| RNF-AVL-005 | RTO (serviços core) | ≤ 1 hora |
| RNF-AVL-006 | RPO (dados off-chain) | ≤ 5 minutos |

---

## 5. Segurança

| ID | Requisito | Meta |
|----|-----------|------|
| RNF-SEC-001 | Auditoria externa pré-mainnet | Obrigatória (mín. 1 firma; ideal 2) |
| RNF-SEC-002 | Bug bounty pós-launch | Escopo público programs + bridge |
| RNF-SEC-003 | Secrets em KMS/HSM/Vault | Zero secrets em git |
| RNF-SEC-004 | Multisig + timelock em authorities | Threshold ≥ 3/5 (produção) |
| RNF-SEC-005 | Threat modeling por módulo | STRIDE / PASTA |
| RNF-SEC-006 | WAF + DDoS protection na edge | Sempre ligado |
| RNF-SEC-007 | Assinatura de webhooks e builds | HMAC / ed25519 |
| RNF-SEC-008 | Penetration test anual | Apps + APIs |

Detalhes: [../security/18-arquitetura-seguranca.md](../security/18-arquitetura-seguranca.md)

---

## 6. Observabilidade

| ID | Requisito | Meta |
|----|-----------|------|
| RNF-OBS-001 | Logs estruturados (JSON) | Todos os serviços |
| RNF-OBS-002 | Tracing distribuído (OpenTelemetry) | Trace-id ponta a ponta |
| RNF-OBS-003 | Métricas RED/USE | Prometheus / Datadog / equivalente |
| RNF-OBS-004 | Alertas SLO-based | Pager para SEV1/SEV2 |
| RNF-OBS-005 | Audit trail imutável de ações admin | Retenção ≥ 2 anos |
| RNF-OBS-006 | Dashboard on-chain health | Slot lag, failed txs, bridge backlog |

---

## 7. Indexação & Dados

| ID | Requisito | Meta |
|----|-----------|------|
| RNF-IDX-001 | Reindexação completa possível | Job idempotente |
| RNF-IDX-002 | Exactly-once / at-least-once com dedup | Por signature |
| RNF-IDX-003 | Busca full-text (Elastic/OpenSearch) | Jogos, NFTs, users públicos |
| RNF-IDX-004 | Cache Redis para hot keys | TTL definido por recurso |

---

## 8. Backup & Recuperação

| ID | Requisito | Meta |
|----|-----------|------|
| RNF-BKP-001 | Backup PostgreSQL contínuo (PITR) | Retenção ≥ 30 dias |
| RNF-BKP-002 | Snapshots Redis (AOF) | Conforme criticidade |
| RNF-BKP-003 | Pin permanente metadata crítica | Arweave + IPFS |
| RNF-BKP-004 | Teste de restore trimestral | Evidência registrada |
| RNF-BKP-005 | Disaster Recovery runbook | Publicado internamente |

---

## 9. Versionamento & CI/CD

| ID | Requisito | Meta |
|----|-----------|------|
| RNF-CICD-001 | SemVer para APIs, SDKs e programs | Obrigatório |
| RNF-CICD-002 | Pipeline: lint → unit → integration → security scan | Blocking |
| RNF-CICD-003 | Deploy preview por PR (off-chain) | Obrigatório |
| RNF-CICD-004 | Program upgrades via governance/timelock | Sem hotpatch silencioso mainnet |
| RNF-CICD-005 | Feature flags para rollout gradual | % traffic |
| RNF-CICD-006 | SBOM e dependency scanning | Cada release |

---

## 10. Compliance & Legal

| ID | Requisito | Meta |
|----|-----------|------|
| RNF-CMP-001 | LGPD: base legal, DSR (acesso/exclusão) | Fluxo ≤ 15 dias |
| RNF-CMP-002 | Minimização de dados pessoais on-chain | PII nunca on-chain |
| RNF-CMP-003 | ToS / Privacy / Risk disclosure | Pré-launch |
| RNF-CMP-004 | Geo-blocking se necessário legalmente | Configurável |
| RNF-CMP-005 | Logs de consentimento | Auditáveis |
| RNF-CMP-006 | Política de loot box / odds disclosure | Onde aplicável |
| RNF-CMP-007 | Sanções / AML screening em fluxos fiat/KYC | Quando KYC ativo |

---

## 11. Usabilidade & Acessibilidade

| ID | Requisito | Meta |
|----|-----------|------|
| RNF-UX-001 | Onboarding wallet < 3 minutos | Casual player |
| RNF-UX-002 | Mensagens de erro acionáveis | Sem hex cru sem explicação |
| RNF-UX-003 | i18n PT/EN | MVP+ |
| RNF-UX-004 | A11y WCAG 2.1 AA (portais web) | P1 |
| RNF-UX-005 | Mobile-responsive store + wallet | Obrigatório |

---

## 12. Governança Operacional

| ID | Requisito | Meta |
|----|-----------|------|
| RNF-GOV-001 | Change management para params on-chain | ADR + timelock |
| RNF-GOV-002 | Incident response plan | SEV0–SEV3 |
| RNF-GOV-003 | Key ceremony documentada | Multisig |
| RNF-GOV-004 | Separação de duties admin | RBAC |

---

## 13. Compatibilidade

| ID | Requisito | Meta |
|----|-----------|------|
| RNF-COMPAT-001 | Browsers: Chrome, Firefox, Safari, Edge (2 últimas majors) | Suportados |
| RNF-COMPAT-002 | Engines: Unity 2022 LTS+, Unreal 5.x, Godot 4.x | SDKs |
| RNF-COMPAT-003 | Wallets: Phantom, Solflare, Backpack, Ledger | P0/P1 |
| RNF-COMPAT-004 | APIs retrocompatíveis em minor versions | Breaking só em major |

---

## 14. Qualidade

| ID | Requisito | Meta |
|----|-----------|------|
| RNF-QA-001 | Coverage unitária programas críticos | ≥ 90% |
| RNF-QA-002 | Coverage serviços core | ≥ 80% |
| RNF-QA-003 | Testes e2e fluxos P0 | 100% automatizados |
| RNF-QA-004 | Fuzz/property tests em parsers e math | Staking/fees/bridge |

Ver: [../roadmap/22-estrategia-testes.md](../roadmap/22-estrategia-testes.md)
