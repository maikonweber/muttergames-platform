# MutterGames Ecosystem — Manual SRE da Infraestrutura

**Versão:** 1.0  
**Data:** 4 de agosto de 2026  
**Público:** SRE, Platform, Blockchain, Security, Data, Game Backend e Incident Command  
**Objetivo:** operar a plataforma com confiabilidade, segurança e recuperação verificável

> Este é o baseline operacional. Provedores e nomes concretos devem ser registrados em ADRs. Nenhum serviço externo é considerado infalível; toda dependência crítica possui timeout, circuit breaker, observabilidade e estratégia de degradação.

## 1. Escopo e responsabilidades

SRE responde por SLOs, capacidade, observabilidade, incident command, disponibilidade, DR, automação e redução de toil. Product define criticidade e trade-offs; times de serviço possuem produção, runbooks e on-call. Security comanda incidentes de chave/exploit; Economy responde por integridade do ledger; Blockchain responde por programas, relayer e authorities.

### 1.1 Princípios operacionais

- Integridade financeira supera disponibilidade de escrita.
- Gameplay degrada antes de falhar por dependência blockchain.
- “Desconhecido” não vira “sucesso”; operações incertas ficam pendentes.
- Alertar por impacto/sintoma; causas auxiliares ficam em dashboard.
- Automatizar tarefas repetíveis; ações destrutivas exigem confirmação e trilha.
- Toda dependência crítica tem owner, SLA externo e exit strategy.

## 2. Topologia de produção

```text
Internet / Game Servers
  → DNS + CDN + DDoS/WAF
  → Regional Load Balancer
  → Kubernetes/Container Platform (multi-AZ)
       ├─ API Gateway/BFF
       ├─ Identity / Profile / Game Registry
       ├─ Catalog / Inventory / Entitlements
       ├─ Economy / Rewards / Marketplace / Policy
       ├─ Workers / Webhooks / Notifications
       └─ Chain Zone (network-isolated)
            ├─ Relayer
            ├─ Signer connector → KMS/MPC
            ├─ RPC router → Provider A/B/C
            ├─ Indexer
            └─ Reconciler

Data: PostgreSQL HA multi-AZ | Redis | Event Bus | Object Storage | Warehouse
Ops: Metrics | Logs | Traces | Synthetic probes | Paging | Status page
Chain: Solana mainnet/devnet | programs | multisig | treasury/vaults
```

### 2.1 Failure domains

Conta cloud, região, AZ, cluster, namespace, database, queue partition, RPC provider, indexer e Solana cluster. Produção e não produção não compartilham credentials, authorities, mints, database ou signing keys.

## 3. Catálogo de serviços e criticidade

| Tier | Serviços | Impacto | On-call |
|---|---|---|---|
| T0 | Economy/Ledger, Signer, Reconciler, program authorities | perda/integridade financeira | 24x7, página imediata |
| T1 | Identity, API Gateway, Inventory, Orders, Relayer | jornada central indisponível | 24x7 |
| T2 | Catalog, Marketplace browse, Webhooks, Policy | degradação parcial | horário + escalada |
| T3 | Analytics, Launchpad, Creator tools | impacto não imediato | horário comercial |

Cada serviço possui `service.yaml`: owner, tier, repo, dashboards, SLO, dependencies, data class, runbook, pager, deploy e rollback.

## 4. SLIs, SLOs e error budgets

### 4.1 Definições

Disponibilidade mede requisições válidas que completam com resultado semanticamente correto. Latência exclui requests inválidos, mas inclui dependências necessárias. Freshness mede idade da projeção/indexação. Correctness mede reconciliação e invariantes.

| Jornada/serviço | SLI | SLO mensal |
|---|---|---:|
| Login/session | sucesso válido / tentativas válidas | 99,95% |
| Inventory | resposta correta e fresca | 99,95% |
| Economy intake | evento aceito de forma durável | 99,95% |
| Quote/order | conclusão sem erro interno | 99,90% |
| Ledger integrity | transações balanceadas | 100% |
| Reconciliation | finalized reconciliado <5 min | 99,90% + 100% diário |
| Web público | synthetic success | 99,90% |
| Webhooks | entrega <15 min | 99,50% |

### 4.2 Error budget policy

- Consumo <25% no período: operação normal.
- 25–50%: revisar tendências e riscos de releases.
- 50–75%: congelar mudanças de risco alto; priorizar confiabilidade.
- >75% ou burn 14,4x/1h: feature freeze do serviço afetado.
- 100%: apenas correções, segurança e reversões até plano aprovado.

Integridade de ledger, duplicate payment/claim e chave comprometida não usam budget: qualquer ocorrência é incidente.

### 4.3 Burn-rate alerts

Multi-window: 14,4x em 1h/5m para página; 6x em 6h/30m para página; 3x em 1d/2h para ticket urgente; 1x em 3d/6h para backlog. Exigir tráfego mínimo para evitar ruído.

## 5. Capacity planning

### 5.1 Unidade de demanda

MAU/DAU, CCU, logins/s, inventory reads/s, events/s, orders/min, chain intents/min, webhooks/s, database TPS, queue ingress/egress, storage/day e RPC calls/transaction.

### 5.2 Headroom

CPU/memory sustentados abaixo de 60% em T0/T1; banco com 40% de headroom em IOPS/connections/storage; queue suporta 2h de pico; RPC contratado para 3x p95 e provider alternativo aquecido. Autoscaling não substitui limite de dependência.

### 5.3 Forecast

Revisão mensal e antes de campanha/lançamento. Cenários p50, p90 e evento extremo. Testes: load, spike, soak 24h, backlog recovery e coordinated omission. Resultado inclui gargalo, custo e limite operacional seguro.

## 6. Ambientes e infraestrutura como código

Ambientes: local, development, staging, production. Staging replica topologia e policies, não dados pessoais. IaC é fonte de verdade; mudanças manuais são detectadas e revertidas ou registradas. Estado IaC criptografado, versionado e com lock. Modules versionados; policy-as-code bloqueia rede pública, volumes sem encryption, IAM amplo e recursos sem tags.

Tags obrigatórias: `service`, `owner`, `environment`, `data_class`, `cost_center`, `criticality`, `managed_by`, `backup_policy`.

## 7. Compute e orquestração

Workloads stateless em múltiplas AZs, PodDisruptionBudget, requests/limits medidos, readiness distinta de liveness e graceful shutdown. Workers usam visibility timeout maior que p99, heartbeats e idempotência. T0 não faz deploy simultâneo em todas as zonas.

Namespaces e service accounts por domínio. NetworkPolicy default-deny. Chain Zone recebe somente intents do Economy e sai apenas para KMS/RPC. Admin access via bastion/zero-trust, JIT e gravação/auditoria.

## 8. Banco de dados

### 8.1 PostgreSQL

HA multi-AZ, encryption, PITR, automatic failover e conexão por pool. Ledger usa transações ACID, constraints e isolamento adequado; nenhum float. Migrations expand/contract, online quando possível, com dry-run, lock timeout e rollback/roll-forward.

### 8.2 Backups

PITR ≥35 dias; snapshot diário ≥90 dias; cópia imutável/separada conforme risco; restauração trimestral. Backup só é válido quando restore e checksum passam. Evidência registra duração, RPO observado e gaps.

### 8.3 Alertas de banco

Replication lag, failover, connection saturation, CPU/IOPS, storage forecast, deadlocks, long transactions, lock waits, vacuum/bloat, query regression, backup failure e checksum. Ledger imbalance página imediatamente.

## 9. Cache, filas e eventos

Redis é cache/coordenação efêmera, nunca sistema de registro. Definir TTL, eviction, stampede protection e fallback. Event bus usa schema registry, retention, DLQ e replay. Producer implementa transactional outbox; consumer deduplica por `event_id`.

Alertas: oldest message age, consumer lag, DLQ rate, redelivery, partition skew, publish failure e outbox backlog. Runbook diferencia consumidor lento, poison message e dependência indisponível.

## 10. Blockchain/RPC/Indexer

### 10.1 RPC routing

Providers A/B mais leitura independente C. Health score considera latency, error, slot lag, blockhash freshness, simulation divergence e rate limit. Escrita usa strategy explícita; não broadcast descontrolado que duplique efeitos.

### 10.2 Relayer

Sem PII e sem acesso administrativo geral. Apenas intent assinado, program/mint allowlist, caps, nonce e expiry. Estado: `RECEIVED`, `SIMULATED`, `SUBMITTED`, `CONFIRMED`, `FINALIZED`, `FAILED`, `UNKNOWN`. `UNKNOWN` sempre consulta chain antes de retry.

### 10.3 Indexer

Checkpoints por slot, replay determinístico e rebuild testado. Projeção expõe `indexed_slot` e freshness. Divergência entre providers/indexer abre incidente; indexer nunca sobrepõe ledger sem reconciler.

### 10.4 Programs e authorities

Deployment registra program ID, binary hash, audit commit, upgrade authority, multisig, timelock e slot. Monitorar authority change, upgrade, pause, mint supply, vault balance, campaign root, fee config e transações anômalas.

## 11. Observabilidade

### 11.1 Telemetria

OpenTelemetry; `trace_id` atravessa game event, API, queue, ledger, intent e chain signature. Logs estruturados incluem service, version, environment, severity, actor class e event ID, sem secret/PII. Métricas usam labels limitados; nunca player ID/mint arbitrário em label.

### 11.2 Dashboards mínimos

1. Executive health: SLO, incidents, traffic, revenue/economy guardrails.
2. API: RED por rota/region/version.
3. Economy: balance, reservations, postings, claims, budgets.
4. Chain: RPC, slots, finality, intents, fees, program events.
5. Data: DB, cache, queues, storage e backups.
6. Commerce: quotes, orders, payment, escrow e refunds.
7. Security/Risk: auth failures, admin actions, policy e fraud.

### 11.3 Retenção

Hot logs 14–30 dias, searchable audit conforme política maior, metrics 13 meses agregadas, traces amostrados com 100% de erros/T0. Retenções finais dependem de privacy/legal matrix.

## 12. Alerting

Página exige ação imediata e impacto real/provável. Todo alerta contém resumo, impacto, dashboard, runbook, owner e silence rule. Proibido alertar apenas por CPU sem correlação. Revisão mensal remove alertas sem ação e mede false pages.

### 12.1 Alertas página imediata

- Ledger imbalance diferente de zero.
- Duplicate payment/claim confirmado.
- Signer/authority change inesperada.
- Supply/vault anomaly.
- SLO fast burn T0/T1.
- Database unavailable/failover failed.
- Reconciliation parada >15 min com valor em risco.
- Escrow invariant/exploit signal.
- Secret/key compromise confirmado ou provável.

## 13. Incident management

### 13.1 Severidade

| Sev | Definição | Ack | Atualização |
|---|---|---:|---:|
| SEV-0 | chave/exploit/perda ativa ou integridade sistêmica | 5 min | 15 min |
| SEV-1 | jornada crítica indisponível ou risco material | 10 min | 30 min |
| SEV-2 | degradação parcial com workaround | 30 min | 60 min |
| SEV-3 | baixo impacto | 1 dia útil | conforme ticket |

### 13.2 Papéis

Incident Commander decide prioridades; Operations Lead executa; Communications Lead atualiza status/stakeholders; Scribe mantém timeline; Security/Economy/Blockchain Lead entra conforme domínio. IC não deve operar teclado em incidente complexo.

### 13.3 Processo

Detectar → declarar → classificar → estabilizar → preservar evidência → comunicar → recuperar → reconciliar → monitorar → encerrar → postmortem. Primeiro objetivo é limitar blast radius: pausar somente o módulo afetado.

### 13.4 Comunicação

Status inicial informa impacto, início, componentes e próxima atualização; não especula causa. Clientes recebem mudanças materiais. Incidente de segurança segue counsel/privacy. Postmortem sem culpa em 5 dias úteis para SEV-0/1, com ações, owners e prazos.

## 14. Runbooks

### RB-01 — RPC indisponível

**Sinais:** erro/timeout, slot lag, simulation failure. **Ações:** confirmar múltiplas fontes; retirar provider ruim do pool; bloquear novas operações de valor se simulação/finalidade incerta; manter gameplay; colocar intents em fila; comunicar pending; acompanhar backlog. **Recuperação:** reinserir gradualmente, consultar signatures antes de retry e reconciliar 100%.

### RB-02 — Indexer atrasado/divergente

Comparar slot com providers; parar projeção incorreta; exibir freshness; failover/replay de checkpoint; não alterar ledger. Rebuild em paralelo, comparar hashes/counts e promover apenas após validação.

### RB-03 — Ledger imbalance

SEV-0. Congelar novos postings do domínio afetado; preservar DB/logs; identificar primeira transação divergente; não editar entradas; corrigir via compensação após aprovação Economy/Security; reconciliar período completo e produzir relatório.

### RB-04 — Claim/pagamento duplicado

Pausar campanha/checkout afetado; validar duplicata on-chain e ledger; bloquear replay vector; preservar ids/signatures; determinar exposição; compensação/restauração somente por processo aprovado; criar regression test.

### RB-05 — Signer ou authority comprometida

SEV-0. Acionar Security e multisig; pausar programas/relayer; revogar credential/rota KMS; rotacionar conforme ceremony; monitorar accounts/vaults; preservar evidence; comunicar. Não mover fundos sem plano e aprovação multisig.

### RB-06 — Marketplace exploit

Pausar create/fill, manter leitura; bloquear UI/relayer; identificar orders/receipts e accounts; verificar invariantes on-chain; snapshot de estado; audit fix; testnet rehearsal; retomada em caps reduzidos.

### RB-07 — Banco primário indisponível

Confirmar failover automático e replication state; impedir split brain; reduzir tráfego não crítico; promover réplica somente conforme runbook do provider; validar ledger/outbox; reconciliar após retorno. Restaurar backup é último recurso com aprovação IC/Economy.

### RB-08 — Queue backlog/DLQ

Medir age/rate e dependência downstream; limitar producer se necessário; escalar consumer com segurança; isolar poison messages; não apagar DLQ; replay controlado com idempotência e monitoramento.

### RB-09 — Account takeover

Revogar sessões, bloquear ações de risco, iniciar recovery/cooldown, preservar logs e notificar. Não pedir seed. Investigar alteração de passkey/wallet e possíveis transfers; envolver compliance quando necessário.

### RB-10 — Metadata/catalog compromise

Congelar publish/update e assets afetados; manter hash/provenance anterior; remover conteúdo malicioso da entrega; corrigir authority/credential; republish versionado e revisar acessos.

### RB-11 — DDoS/abuso

Ativar regras WAF/rate por rota/identity; preservar login/gameplay prioritário; degradar busca/imagens/analytics; coordenar CDN/provider; observar collateral damage e retirar regras gradualmente.

### RB-12 — Falha de deploy

Interromper rollout; avaliar error/SLO; rollback da aplicação ou roll-forward seguro. Migration destrutiva não é revertida automaticamente; usar expand/contract. Validar versão, cache, schemas e queues antes de retomar.

## 15. Continuidade e disaster recovery

### 15.1 Objetivos

| Componente | RPO | RTO |
|---|---:|---:|
| Ledger/Orders | próximo de zero após commit | 60 min |
| Identity/Profile | ≤5 min | 60 min |
| Catalog/Inventory projection | reconstruível | 2 h |
| Event bus | ≤5 min conforme retenção | 2 h |
| Analytics | 24 h | 24 h |
| Web público | conteúdo versionado | 2 h |

### 15.2 DR exercise

Trimestral para banco/ledger; semestral regional completo. Testa acesso de emergência, DNS, secrets, restores, queues, dependencies, reconciliation, status page e retorno à região primária. Evidência mede RPO/RTO real e ações.

### 15.3 Modo degradado

- Chain indisponível: gameplay/login/read cache; saques/claims/listings pendentes ou pausados.
- Economy indisponível: nenhuma concessão; jogo acumula eventos localmente com limite.
- Inventory indisponível: snapshot assinado dentro do TTL; sem trade/consume.
- Policy indisponível: fail-closed para valor; fail-open apenas para gameplay não financeiro previamente aprovado.

## 16. Deploy, change e release engineering

Trunk-based, artifacts imutáveis, SBOM, assinatura e provenance. Deploy canary 1/5/25/100%, cada etapa com SLI e business guardrails. Mudança T0 exige reviewer de domínio, janela, rollback e comunicação. Program release exige audit commit, deterministic build, multisig ceremony, program verification e monitoring dedicado.

Emergency change preserva ticket, dois aprovadores quando possível e revisão em 24h. Feature flags têm owner e expiry; flags permanentes viram configuração ou são removidas.

## 17. Segurança operacional

MFA/passkeys, JIT, break-glass selado e testado, access review trimestral, secret rotation, endpoint security, phishing drills e segregação. Logs de admin e KMS vão para conta/sink restrito. Egress control impede exfiltração do signer. Vendors críticos têm assessment, incident clause, SLA e exit test.

## 18. On-call

Rotação sustentável, primary/secondary, handoff e follow-the-sun conforme escala. Página deve chegar por dois canais. Runbooks acessíveis fora do cluster. Após noite pesada, compensação e descanso. Métricas: pages/shift, actionable %, MTTA, MTTR, escalations e toil.

## 19. Toil e automação

Meta: toil <30% do tempo SRE. Automatizar reconcile triage, credential rotation reminders, capacity reports, restore verification, deployment checks, certificate expiry, runbook validation e incident timeline. Automação destrutiva usa dry-run, scope explícito e approval.

## 20. FinOps

Budgets e anomaly alerts por serviço/ambiente. Unit costs: por MAU, login, milhão de events, order, chain intent e GB indexado. Otimização não reduz redundancy T0 nem retention obrigatória. Campanhas e novos jogos incluem capacity/cost review.

## 21. Testes de resiliência

Game-days trimestrais: perda de RPC, indexer lag, queue backlog, database failover, KMS timeout, deploy ruim e WAF rule. Chaos em produção começa por dependências não financeiras e blast radius mínimo. Hipótese, abort conditions e observabilidade são obrigatórias.

## 22. Checklist de prontidão de produção

- Service owner, tier, SLO, dashboards, pager e runbook.
- Capacity/load/soak e limite seguro documentados.
- Backup/restore e DR conforme classe.
- Threat model e security gates concluídos.
- Logs/traces sem secrets/PII proibida.
- Alerts testados e acionáveis.
- Deploy/rollback ensaiados.
- Dependency timeouts, retries, circuit breakers e fallback.
- Cost budget e tags.
- Support/status/comms preparados.
- Ledger/chain/reconcile invariants verificadas quando aplicável.

## 23. Checklist diário do operador

SLO burn; incidentes abertos; ledger balance; reconciliation lag; supply/vault changes; RPC/indexer health; database/queue capacity; failed backups; certificate/key expiry; deploys; fraud/market anomalies e error budget.

## 24. Checklist semanal/mensal

**Semanal:** error budget review, capacity forecast, DLQ, slow queries, top alerts, vulnerabilities e runbook gaps. **Mensal:** SLO report, access/vendor/cost review, restore sample, dependency SLA, game launch forecast e postmortem actions. **Trimestral:** DR, game-day, authority verification, multisig access, audit evidence e architecture risk review.

## 25. Métricas de maturidade SRE

SLO coverage; actionable alert ratio; MTTA/MTTR; change failure rate; restore success; reconciliation freshness; percent services with tested runbook; toil; vulnerability remediation; capacity forecast error; unit cost e postmortem action completion.

## 26. Documentos operacionais dependentes

- `MutterGames-Requirements-Catalog.md`
- `MutterGames-Implementation-Spec.md`
- `MutterGames-Engineering-Roadmap.md`
- Inventário real de serviços e providers
- ADRs de cloud, data, wallet, RPC/indexer e contracts
- Runbooks executáveis com URLs internas
- Security incident response e compliance matrix

