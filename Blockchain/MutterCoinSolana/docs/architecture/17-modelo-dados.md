# 17 — Modelo de Dados

**Versão:** 0.1.0

---

## 1. Poliglota de Persistência

| Store | Uso |
|-------|-----|
| **PostgreSQL** | Source of truth off-chain (users, orders, entitlements, configs) |
| **Redis** | Sessions, rate limits, caches, locks |
| **Elastic/OpenSearch** | Search games/NFTs/users públicos |
| **S3/MinIO** | Builds, mídia, exports |
| **IPFS** | Metadata NFT mutável-pin |
| **Arweave** | Snapshot imutável de metadata crítica |
| **ClickHouse** (P1) | Analytics de alto volume |
| **Queue log** | Kafka/NATS/SQS event streams |

**On-chain** permanece source of truth para ownership e settlement.

---

## 2. Diagrama ER (núcleo)

```
users 1───* wallets
users 1───* entitlements
publishers 1───* products
products 1───* product_versions
products 1───* reviews
orders *───* order_items → products
listings (projection) → nft_assets
nft_assets *─── trades (projection)
stake_positions (projection)
bridge_intents
guilds 1───* guild_members
api_keys → publishers
webhook_deliveries
admin_audit_logs
```

---

## 3. Tabelas Principais (Postgres)

### users
`id, email_hash, display_name, locale, created_at, deleted_at, consent_flags`

### wallets
`id, user_id, address, chain, type(custodial|external), is_primary, created_at`

### publishers
`id, name, owner_user_id, payout_wallet, status, kyc_status`

### products
`id, publisher_id, slug, type, title, description, price_amount, price_currency,
 revenue_share_bps, status, categories[], compatibility jsonb, license_type`

### product_versions
`id, product_id, semver, changelog, build_hash, build_uri, size_bytes, published_at`

### orders
`id, buyer_user_id, status, total_amount, currency, tx_signature, created_at`

### order_items
`id, order_id, product_id, unit_price, quantity`

### entitlements
`id, user_id, product_id, order_id, status, granted_at, revoked_at`

### nft_assets (projection + cache)
`mint, collection, owner, uri, attributes jsonb, compressed bool, updated_slot`

### listings (projection)
`listing_pda, mint, seller, price, currency, status, created_slot`

### trades (projection)
`id, mint, buyer, seller, price, royalty_paid, fee_paid, signature, slot, ts`

### bridge_intents
`id, user_id, src_chain, dst_chain, amount, status, src_tx, dst_tx, nonce, created_at`

### stake_positions (projection)
`owner, pool, amount, lock_until, updated_slot`

### seasons / reward_claims
`season_id, merkle_root, claims(user, amount, proof_claimed)`

### guilds / guild_members
`guild_id, name, leader, roles, user_id, joined_at`

### api_keys
`id, publisher_id, key_hash, scopes[], env, revoked_at`

### admin_audit_logs
`id, actor_id, action, entity, before, after, ip, ts`

---

## 4. Índices críticos

- `wallets(address)` unique
- `products(slug)` unique
- `entitlements(user_id, product_id)`
- `trades(mint, ts desc)`
- `bridge_intents(nonce, src_chain)` unique
- `nft_assets(owner)`
- GIN em `attributes` / `categories`

---

## 5. IPFS / Arweave

```
metadata.json → ipfs://CID
anchor: arweave_tx (publish milestone)
on-chain URI aponta para ipfs; gateway Mutter + público
```

---

## 6. Retenção & LGPD

| Dado | Retenção |
|------|----------|
| Logs acesso | 12 meses |
| Audit admin | 24 meses+ |
| Analytics PII-free | 24 meses |
| Conta deletada | anonimização ≤ 30 dias (exceto obrigações legais) |
| Orders financeiras | conforme legal/tax |

---

## 7. Migrações

- Flyway/Liquibase ou Prisma migrate
- Expand/contract pattern
- Projections reconstruíveis do chain history
