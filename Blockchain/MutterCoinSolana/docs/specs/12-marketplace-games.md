# 12 — Marketplace de Games

**Versão:** 0.1.0

---

## 1. Objetivo

Store oficial do ecossistema MutterCorp para distribuição digital de jogos e conteúdos relacionados, com settlement em `$MUTTER`/SOL e revenue share on-chain/off-chain híbrido.

---

## 2. Catálogo de Produtos

| Tipo | Descrição | Entitlement |
|------|-----------|-------------|
| Game | Jogo base | Licença permanente |
| DLC | Conteúdo expansível | Add-on linked ao game |
| Asset Pack | Packs para creators | Download + license |
| Item / Skin / Character / Land | Pode redirecionar ao NFT market | NFT ou soft item |
| Map | Mapas / mods aprovados | License |
| Currency Pack | Soft currency (se permitido) | Credit in-game |
| License Seat | B2B seats | Seat management |
| Bundle | Combos com desconto | Multi-entitlements |
| Subscription | Acesso temporal | Recurring (P2) |

---

## 3. Modelo de Dados do Item de Catálogo

| Campo | Obrigatório | Notas |
|-------|-------------|-------|
| `id` | sim | UUID |
| `slug` | sim | único |
| `title` | sim | |
| `type` | sim | enum acima |
| `publisher_id` | sim | Studio |
| `creator_wallet` | sim | payout |
| `price` | sim | amount + currency |
| `price_history` | auto | série temporal |
| `royalty_bps` | sim | secondary se NFT |
| `revenue_share_bps` | sim | primary split platform/studio |
| `collection` | opcional | |
| `categories` / `tags` | sim | |
| `rating_avg` / `reviews` | derivado | |
| `downloads_count` | derivado | |
| `versions[]` | sim | semver + changelog |
| `compatibility` | sim | OS, CPU, GPU, engine |
| `license_type` | sim | EULA template |
| `build_hash` | sim | SHA-256 |
| `build_uri` | sim | S3/CDN signed |
| `media` | sim | cover, screenshots, trailer |
| `age_rating` | sim | |
| `status` | sim | draft/review/live/delisted |
| `integrity_sig` | sim | ed25519 publisher |

---

## 4. Fluxos Principais

### 4.1 Publicação
```
Studio submit → Automated checks (malware scan, hash, size)
 → Moderação humana
 → Pricing & regions
 → Live
```

### 4.2 Compra
```
Browse → Product page → Purchase → Pay → Entitlement → Download token
```

### 4.3 Update de versão
```
Upload build → New version pending → Optional forced update flag → Publish
```

### 4.4 Reembolso (política)
- Janela configurável (ex.: 14 dias + <2h playtime)
- Offline decision engine + chargeback handling
- Revoga entitlement e download keys

---

## 5. Discovery

- Rankings (trending, top paid, top free)
- Tags / gênero / features (multiplayer, GameFi, NFT-ready)
- Editorials MutterCorp
- “Jogáveis com sua wallet” (possui assets X)

---

## 6. Integração NFT Markets

Produtos podem embutir deep-links:
- Skins oficiais → coleção verificada
- Terrenos → land marketplace
- Personagens → character market

Badge **Verified Collection** quando `publisher_id` == authority on-chain.

---

## 7. Licenças & DRM leve

- Entitlement server-side (source of truth)
- Download URLs assinadas (TTL curto)
- Opcional NFT receipt (soulbound) como proof de compra
- Sem DRM invasivo no MVP; foco em autenticação + ToS

---

## 8. Avaliações

- Só compradores verificados
- Rate limit; anti-spam
- Report/moderation

---

## 9. Métricas Studio

- GMV, refunds, conversion funnel
- Geos (agregado, privacy-safe)
- Retention proxy via launch events SDK

---

## 10. Requisitos de Integridade

| Controle | Descrição |
|----------|-----------|
| Hash pin | SHA-256 por build |
| Quarantine | Scan antivírus/malware pipeline |
| Signed metadata | Publisher key |
| Immutable audit | Quem publicou o quê e quando |

---

## 11. Estados do Produto

```
draft → in_review → changes_requested → approved → live → delisted → archived
```
