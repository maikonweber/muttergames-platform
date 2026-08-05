# 07 — Arquitetura de Software

**Versão:** 0.1.0  
**Estilo:** Modular Monolith na fase MVP → Microserviços no V1

---

## 1. Visão em Camadas

```
┌──────────────────────────────────────────────────────────────┐
│ CLIENTS                                                       │
│ Wallet App · Store Web · Admin · Dev Portal · Game Clients   │
└─────────────────────────────┬────────────────────────────────┘
                              │ HTTPS / WSS
┌─────────────────────────────▼────────────────────────────────┐
│ EDGE                                                          │
│ CDN · WAF · API Gateway · AuthN/AuthZ · Rate Limit           │
└─────────────────────────────┬────────────────────────────────┘
                              │
┌─────────────────────────────▼────────────────────────────────┐
│ APPLICATION SERVICES                                          │
│ Users · Catalog · Orders · Entitlements · NFT Metadata       │
│ Marketplace Orchestration · Rewards · Guilds · Notifications │
│ Launchpad · Analytics · Admin · Developer Platform           │
└───────────────┬─────────────────────────────┬────────────────┘
                │                             │
┌───────────────▼──────────────┐  ┌───────────▼────────────────┐
│ DATA PLANE                    │  │ BLOCKCHAIN PLANE            │
│ PostgreSQL · Redis · Elastic  │  │ Solana Programs             │
│ S3/MinIO · IPFS · Arweave     │  │ Bridge Relayers             │
│ Queue (Kafka/NATS/SQS)        │  │ RPC Providers (multi)       │
└───────────────┬──────────────┘  │ Indexer / Listener           │
                │                 └───────────┬────────────────┘
┌───────────────▼─────────────────────────────▼────────────────┐
│ OBSERVABILITY: Logs · Metrics · Traces · Audit               │
└──────────────────────────────────────────────────────────────┘
```

---

## 2. Módulos Lógicos

| Módulo | Responsabilidade |
|--------|------------------|
| **Identity** | Contas, OAuth, wallet-link, sessões, LGPD |
| **Wallet Gateway** | Custodial signing (HSM), policy engine |
| **Catalog** | Jogos, DLCs, coleções, categorias |
| **Orders & Payments** | Checkout, quotes, settlement coordination |
| **Entitlements** | Licenças, downloads, revogação |
| **Marketplace** | List/offer/auction orchestration + reads |
| **NFT Service** | Metadata pipeline, pin IPFS/Arweave |
| **Rewards** | Seasons, missions, merkle distributors |
| **Staking Adapter** | UX e indexing sobre programa on-chain |
| **Bridge Orchestrator** | Intent, status machine, alertas |
| **DAO Adapter** | Proposals UI + indexing |
| **Guilds** | Social graph + roles |
| **Developer Platform** | API keys, webhooks, sandbox |
| **Admin** | RBAC, params, moderation |
| **Indexer** | Parse txs → projections |
| **Notification** | Email/push/in-app |
| **Analytics** | Event pipeline, studio dashboards |

---

## 3. Diagrama de Dependências (simplificado)

```
Games/SDK ──► API Gateway ──► Identity
                         ├──► Catalog / Orders / Entitlements
                         ├──► Marketplace Service ──► Solana (via tx builder)
                         ├──► NFT Service ──► IPFS/Arweave
                         └──► Rewards / Guilds

Indexer ◄── Solana RPC / Webhooks
Indexer ──► PostgreSQL / Elastic (read models)

Bridge Orchestrator ◄──► Relayer Network ◄──► Destination Chains
```

---

## 4. Padrões Arquiteturais

| Padrão | Uso |
|--------|-----|
| API Gateway | Auth, routing, throttling |
| CQRS leve | Writes on-chain / reads no indexer |
| Outbox Pattern | Webhooks confiáveis |
| Saga / State machine | Bridge, orders, auctions |
| Sidecar/Agent | Relayers |
| BFF | Store BFF, Wallet BFF, Admin BFF |
| Feature flags | Rollouts |

---

## 5. Contratos entre Camadas

- **Clients ↔ API:** OpenAPI 3.1; erros RFC7807
- **API ↔ Chain:** serviços geram instruções; assinatura pelo user ou custodial HSM
- **API ↔ Indexer DB:** somente leitura nas projeções públicas
- **Games ↔ Mutter:** SDK + server-to-server com mTLS/API key

---

## 6. Ambientes

| Env | Uso |
|-----|-----|
| `local` | Dev machine + solana-test-validator |
| `dev` | Devnet + services shared |
| `staging` | Mainnet-beta programs clones / dedicated |
| `prod` | Mainnet |

---

## 7. Decisões MVP vs Escala

| Tópico | MVP | V1+ |
|--------|-----|-----|
| Deploy units | 2–4 serviços | Microserviços por domínio |
| Fila | Redis streams / SQS | Kafka |
| Search | Postgres FTS | OpenSearch |
| Custodial | Provider especializado ou HSM managed | MPC wallet |
| Realtime | Polling + poucas WSS | Fanout WSS dedicado |

---

## 8. ADRs obrigatórios (próximos)

Criar em `docs/architecture/adrs/` após aprovação:
- ADR-001: Solana como L1 primária
- ADR-002: Metaplex vs custom NFT program
- ADR-003: Custodial vs embedded wallet vendor
- ADR-004: Bridge build vs partnership (LayerZero/Wormhole/deBridge)
- ADR-005: Compressed NFTs para items high-volume
