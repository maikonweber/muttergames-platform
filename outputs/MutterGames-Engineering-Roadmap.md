# MutterGames Ecosystem — Roadmap de Engenharia

**Horizonte:** 24 meses para plataforma operacional; evolução alinhada ao roadmap de cinco anos do whitepaper  
**Método:** entregas por capability, gates mensuráveis e rollout progressivo  
**Premissa de planejamento:** 2 jogos internos no piloto, Solana devnet antes de mainnet e nenhuma bridge no MVP

## 1. Equipes mínimas

| Squad | Composição indicativa | Responsabilidade |
|---|---|---|
| Platform | 1 lead, 3 backend, 1 SRE | gateway, identity, registry, events |
| Economy | 1 lead, 2 backend, 1 data/economist | ledger, rewards, reconciliation |
| Blockchain | 1 lead Rust/Solana, 2 engineers, 1 security shared | programs, relayer, indexer |
| Web/Commerce | 1 lead, 3 full-stack, 1 product designer | site, portal, store, marketplace |
| Game Integration | 1 lead, 2 SDK/game engineers por engine | Unity/Unreal/C#, jogos |
| Trust | security, compliance, risk, support tooling | controls, policy, incidents |
| Data | 2 data engineers/analysts shared | schemas, warehouse, dashboards |

Equipe pode começar menor, mas papéis de Security, Economy e Compliance não podem ficar sem owner. Estimativas devem ser recalibradas após discovery técnico.

## 2. Dependências críticas

```text
Identity ───────┐
Game Registry ─┼─> Game SDK ─> Integração dos jogos
Catalog ────────┘          └─> Inventory/Entitlements

Event Contract ─> Economy/Ledger ─> Rewards ─> Chain Intent
                                           └─> Relayer ─> Programs Solana

Catalog + Inventory + Identity ─> Store/Marketplace/Player Portal
Programs + Relayer + Reconciler ─> Mainnet Gate
Security + Compliance + Economy Simulation ─> Token/Mainnet Gate
```

## 3. Fase 0 — Mobilização e decisões (semanas 1–4)

### Entregas

- Nomear owners e criar decision log/ADRs.
- Confirmar escopo MVP e jornadas de Fallen Tactics/Beat Up.
- Threat model de identidade, reward, marketplace e relayer.
- Escolher cloud, regiões, linguagem backend, banco e event bus.
- Spike de wallet, RPC/indexer, Token-2022 e Metaplex.
- Taxonomia de ativos e matriz de dados pessoais.
- Backlog inicial e ambientes/IaC base.

### Gates

Architecture review aprovada; RACI; budget; mercados-alvo; riscos críticos com owner; ADRs para decisões irreversíveis. Sem isso, não iniciar contratos financeiros.

## 4. Fase 1 — Fundação da plataforma (semanas 5–12)

### Backend

- API Gateway, OIDC/passkey básico, `player_id`, sessions e audit log.
- Game Registry, workload credentials e sandbox.
- PostgreSQL HA em development/staging; outbox/event bus.
- OpenTelemetry, trace IDs, logs e dashboards básicos.

### Web

- Design system acessível.
- Site institucional, `/games`, `/ecosystem`, `/status`, `/legal` e documentação inicial.
- Player portal: perfil, segurança e sessões.

### Jogos

- SDK server TypeScript/C# alpha.
- Troca de ticket e leitura de perfil em um vertical slice por jogo.

### Critérios de saída

Mesmo jogador reconhecido nos dois jogos; sem chave de servidor no cliente; p95 de sessão dentro da meta; restore de banco testado; contract test CI ativo.

## 5. Fase 2 — Catálogo, inventário e integração read-only (semanas 13–20)

### Entregas

- Catalog workflow e schemas de metadata.
- Inventory agregando fixtures on-chain/devnet e itens internos.
- Compatibility Registry e entitlements assinados.
- Player portal `/inventory`; asset details e provenance.
- Webhooks de entitlement e replay.
- Indexer devnet com checkpoints e rebuild.

### Piloto

Um cosmético de Fallen Tactics aparece com tradução visual em Beat Up. Nenhuma transferência financeira.

### Critérios de saída

Cache/fallback testado; asset desconhecido/quarentenado é seguro; reindex completo reproduz projeção; 100% das mudanças têm audit trail.

## 6. Fase 3 — Economia off-chain e rewards controlados (semanas 21–32)

### Entregas

- Ledger dupla entrada, accounts, postings, compensation e reports.
- Event intake idempotente; schema registry; DLQ/replay.
- Rewards campaigns, budgets, caps, antifraud delay e claims internos.
- Policy/Risk v1; device/account signals e manual review.
- Economy simulator p10/p50/p90 e dashboard faucets/sinks.
- Admin read-only para ledger e timeline.

### Piloto

Temporada fechada com rewards não transferíveis em 1%→5%→25% dos jogadores elegíveis.

### Critérios de saída

Ledger balance sempre zero por transação; duplicates/out-of-order testados; nenhum reward a cliente adulterado; economia dentro de guardrails; apelação operacional.

## 7. Fase 4 — Programas Solana e chain services (semanas 25–40, paralela)

### Sprint A — Base (25–28)

Workspace Anchor/Rust, common validation/errors, deployments localnet/devnet, program IDs e authority model.

### Sprint B — Asset Registry (29–32)

Collection policy, asset record, compatibility root, quarantine, events, property tests.

### Sprint C — Rewards Vault (33–36)

Campaign/vault, Merkle claim, receipt, expiry, pause, fuzz e adversarial tests.

### Sprint D — Marketplace Escrow (37–40)

Order/escrow/receipt, atomic fill, fee caps, cancel/expire, concurrency e compute profiling.

### Chain services

Relayer isolado, KMS/MPC, RPC router, simulation, intent store, indexer e reconciler.

### Critérios de saída

Invariantes cobertas; build reproduzível; program hashes registrados; devnet E2E; pause por módulo; nenhuma authority individual em produção planejada.

## 8. Fase 5 — Store e marketplace beta (semanas 33–44)

### Store

Catalog/search, product detail, quote, policy, checkout sandbox, order timeline e receipt. PSP apenas em sandbox até revisão regulatória.

### Marketplace

Listings, filters, asset page, wallet connect, simulation, order/escrow devnet, history, cancel/expire e disclosures.

### Portais

Player: wallets, transactions, orders, rewards e support. Studio: credentials, webhooks, catalog e event inspector. Admin: catalog approval, reconciliation e risk cases.

### Critérios de saída

E2E sem pagamento duplicado; quote expirado bloqueado; transferência atômica; WCAG 2.2 AA; CSP/security review; suporte consegue explicar cada estado.

## 9. Fase 6 — Hardening e auditorias (semanas 41–52)

### Segurança

- Auditoria externa de Rewards Vault, Marketplace Escrow e relayer.
- Pen test web/API, wallet recovery review e insider threat exercise.
- Fuzz/property/concurrency; SBOM e supply-chain controls.
- Incident drills: signer, RPC, indexer, ledger e marketplace.

### Confiabilidade

Load/soak, failover RPC, database restore, queue backlog, regional failure, reconciliation at scale, cost profiling e SLO burn alerts.

### Compliance

Termos, privacidade, disclosures, KYC/AML/age/region matrix, payments/custody review e support policies.

### Go/no-go devnet production rehearsal

Zero critical/high findings abertos; restore dentro do RTO; reconciliation fecha; policies testadas; authority ceremony ensaiada; rollback e communication plan aprovados.

## 10. Fase 7 — Mainnet limitada, sem bridge (meses 13–15)

### Rollout

1. Mainnet com ativos de valor mínimo e equipe interna.
2. 100 jogadores convidados.
3. 1% de coorte elegível.
4. 5% após duas semanas estáveis.
5. 25% após revisão econômica/risco.
6. Expansão apenas por gate formal.

MUT transferível só entra se existir decisão legal/produto separada. O MVP pode usar USDC, ativos e entitlements sem token próprio.

### Gates diários

Supply, ledger/reconciliation, failed transactions, fraud, wallet recovery, support volume, chain fees, RPC health, marketplace anomalies e retention sem incentivo.

## 11. Fase 8 — Launchpad e creator tooling (meses 16–18)

- Portal de aplicação, due diligence, sandbox provisioning e scorecard.
- SDK GA TypeScript/C#/Unity; Unreal beta.
- Creator catalog, collection review, drops e royalty reports.
- Studio analytics, budgets, webhooks e billing.
- Integração do terceiro jogo em 8–12 semanas.

Gate: novo jogo não obtém mint/reward authority; usa capacidades com caps e policies centrais.

## 12. Fase 9 — Escala e governança inicial (meses 19–24)

- Multi-region reads e disaster recovery avançado.
- Sharding de vault/campaign/hot accounts quando medido.
- Governança de signaling e grants com transparência.
- Marketplace otimizado, creator campaigns e B2B services.
- Publicação de standards e certification checklist.
- Decisão sobre bridge apenas após avaliação independente; implementação fora deste horizonte se gate não passar.

## 13. Roadmap por produto web

| Trimestre | Público | Jogador | Studio | Admin |
|---|---|---|---|---|
| Q1 | home, games, ecosystem, legal, status | perfil/segurança | docs alpha | audit viewer |
| Q2 | assets, developers | inventário, progresso | keys/webhooks | catalog/risk |
| Q3 | store beta, token transparency draft | wallets, rewards, transactions | event inspector | ledger/reconcile |
| Q4 | marketplace beta | orders/support/privacy | analytics/catalog | incident controls |
| Q5 | mainnet disclosures | limits/recovery | production onboarding | treasury/reporting |
| Q6 | launchpad/creators | missions | applications/billing | launch review |
| Q7–Q8 | localization/SEO | governance/grants | SDK GA | policy governance |

## 14. Roadmap por contrato

| Marco | Asset Registry | Rewards Vault | Escrow | Governance |
|---|---|---|---|---|
| M6 | spec/PDAs | spec | threat model | fora do MVP |
| M8 | devnet beta | devnet alpha | prototype | signaling design |
| M10 | audit-ready | audit-ready | devnet beta | - |
| M12 | audited | audited | audit-ready/audited | - |
| M13–15 | mainnet limited | mainnet limited | mainnet limited | signaling |
| M19–24 | stable/migration review | campaign scaling | fee/market review | grants pilot |

## 15. Marcos executivos

| Marco | Data relativa | Evidência |
|---|---:|---|
| A — Identity vertical slice | semana 12 | login nos dois jogos |
| B — Cross-game inventory | semana 20 | cosmético traduzido |
| C — Economy sandbox | semana 32 | temporada off-chain controlada |
| D — Solana devnet E2E | semana 40 | claim + escrow + reconcile |
| E — Commerce beta | semana 44 | checkout/order/entitlement |
| F — Security gate | semana 52 | auditorias e rehearsal |
| G — Mainnet limited | mês 15 | coortes e valores capped |
| H — Third-party game | mês 18 | launchpad integration |
| I — Platform scale | mês 24 | SLOs e governance pilot |

## 16. KPIs por gate

### Produto

Time-to-first-fun, onboarding completion, D1/D7/D30, cross-game activation, support contacts por mil usuários e satisfação de não pagadores.

### Engenharia

SLO, p95/p99, change failure rate, MTTR, queue age, reconciliation lag, deployment frequency, escaped defects e cost per MAU.

### Economia e risco

Faucet/sink, emissão líquida, concentração, fraud loss, false positive, duplicate prevented, chargeback, wash rate e revenue external.

## 17. Plano de releases

Trunk-based development, feature flags, semantic versioning, environments isolados e deploy canary. SDK mantém duas majors por 12 meses; depreciação mínima de 180 dias. Programs usam release candidate, audit commit, reproducible hash, multisig ceremony e post-deploy verification.

## 18. Definition of Done por capability

Uma capability só está concluída quando possui: requisitos e owner; threat model; código e revisão; testes unit/integration/contract; observabilidade; runbook; documentação/SDK; privacy/compliance review quando aplicável; rollback; SLO; suporte treinado; métricas de produto; aprovação do gate.

## 19. Riscos de cronograma

| Risco | Sinal | Resposta |
|---|---|---|
| token/legal indefinido | pareceres atrasados | lançar plataforma sem MUT |
| wallet provider lock-in | export/recovery limitada | adapter e exit test |
| auditoria encontra falha estrutural | high severity | congelar mainnet, redesenhar |
| jogos não têm servidor autoritativo | eventos não confiáveis | escopo de retrofit antes de rewards |
| microserviços prematuros | latência/operação alta | modular monolith e extração medida |
| economia depende de subsídio | retenção cai sem reward | interromper emissão e melhorar jogo |
| RPC/indexer instável | reconcile lag | multi-provider e independent replay |
| falta de suporte/compliance | cases acumulados | bloquear expansão de regiões/coortes |

## 20. Próximos dez dias úteis

1. Aprovar escopo do MVP sem bridge e sem obrigação de MUT.
2. Realizar workshops de arquitetura com cada jogo.
3. Inventariar stacks, servidores autoritativos e modelos de conta existentes.
4. Criar ADRs para cloud, backend, wallet, RPC/indexer, token e NFT standard.
5. Definir schemas `player`, `game`, `asset`, `entitlement` e `economy_event`.
6. Implementar spike de session exchange em um jogo.
7. Implementar ledger mínimo com property test de balanceamento.
8. Criar local validator e primeiro PDA de registry.
9. Wireframe das páginas públicas, player portal e store.
10. Montar threat model, compliance matrix, budget e staffing real.

