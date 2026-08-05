# 16 — Backend (Microserviços)

**Versão:** 0.1.0

---

## 1. Catálogo de Serviços

| Serviço | Responsabilidade | Datastores |
|---------|------------------|------------|
| **auth-service** | OAuth, JWT, wallet nonce login | Postgres, Redis |
| **user-service** | Perfis, preferências, LGPD | Postgres |
| **wallet-service** | Custodial policies, spend limits | Postgres, KMS/HSM |
| **catalog-service** | Games, DLCs, metadata store | Postgres, S3 |
| **order-service** | Checkout, estado de ordens | Postgres |
| **entitlement-service** | Licenças e download grants | Postgres |
| **marketplace-service** | Orquestração + quotes | Postgres |
| **nft-service** | Metadata pipeline, pin | Postgres, IPFS/Arweave |
| **payments-service** | Quotes, fee calc, fx display | Postgres, Redis |
| **bridge-orchestrator** | FSM bridge intents | Postgres, Queue |
| **rewards-service** | Seasons, missions, merkle gen | Postgres |
| **guild-service** | Guildas e membros | Postgres |
| **dao-service** | Index + UX proposals | Postgres |
| **launchpad-service** | Sales off-chain config | Postgres |
| **notification-service** | Email/push/in-app | Queue |
| **analytics-service** | Eventos produto | Kafka/ClickHouse |
| **admin-service** | RBAC ops | Postgres |
| **developer-service** | API keys, webhooks | Postgres |
| **indexer / chain-listener** | Parse Solana (+EVM) | Postgres, Redis, Elastic |
| **search-service** | Query games/NFTs | Elastic |

---

## 2. Diagrama de Comunicação

```
API Gateway
   ├─ auth-service
   ├─ user-service
   ├─ catalog / order / entitlement
   ├─ marketplace / nft / payments
   ├─ rewards / guild / dao / launchpad
   ├─ bridge-orchestrator
   ├─ developer-service
   └─ admin-service

chain-listener ──► indexer projections ──► read APIs
order/rewards ──► outbox ──► notification / webhooks
```

---

## 3. Blockchain Listener

Responsabilidades:
- Subscribe slots/transactions (Yellowstone gRPC / RPC WS)
- Decode Anchor events
- Upsert read models idempotentes (`signature` unique)
- Publicar domain events internos
- Backfill tool

EVM listeners separados por chain (P1).

---

## 4. Filas & Eventos

| Bus | Uso |
|-----|-----|
| Command queue | Jobs (pin IPFS, merkle build) |
| Domain events | `TradeExecuted`, `OrderPaid` |
| Outbox | Webhooks confiáveis |

---

## 5. AuthZ

- Users: JWT bearer
- Studios: API keys + mTLS opcional
- Admins: SSO + RBAC + hardware 2FA
- Service-to-service: mesh identity / JWT interno

---

## 6. Escalabilidade

- Stateless services atrás do gateway
- Autoscaling HPA
- Read replicas Postgres para indexer pesado
- Cache Redis em catálogo e balances display

---

## 7. MVP Packaging

Para acelerar:
1. `api-core` (auth, user, catalog, order, entitlement)
2. `chain-indexer`
3. `admin`
4. `worker` (notifications, pins)

Split em microserviços listados no V1.

---

## 8. SLOs por Serviço

| Serviço | Disponibilidade | Latência p95 |
|---------|-----------------|--------------|
| auth | 99.95% | 150ms |
| catalog read | 99.9% | 200ms |
| order write | 99.9% | 400ms |
| indexer lag | — | <3s normal |
