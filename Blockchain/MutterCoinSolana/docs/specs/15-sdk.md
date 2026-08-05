# 15 — SDK & Portal do Desenvolvedor

**Versão:** 0.1.0

---

## 1. Objetivo

Permitir que studios integrem auth, inventário, mints, compras e rewards da MutterCoin em horas, com sandbox completo.

---

## 2. Matriz de SDKs

| Plataforma | Linguagem | Prioridade | Uso |
|------------|-----------|------------|-----|
| Unity | C# | P0 | Games client |
| Web | TypeScript/JS | P0 | WebGL / portal |
| Server | TypeScript / Go / Rust / Python | P0/P1 | Trusted backend |
| Unreal | C++/Blueprints | P1 | Games |
| Godot | GDScript/C# | P1 | Games |
| Native | Rust | P2 | Custom clients |

---

## 3. Capacidades do SDK Client

| Módulo | Funções |
|--------|---------|
| Auth | `Login()`, `LinkWallet()`, `GetSession()` |
| Inventory | `GetItems()`, `SubscribeInventory()` |
| Mint/Reward | `ClaimReward(id)` (server-authorized) |
| Marketplace | `GetListings()`, `Buy()`, `List()` |
| Token | `GetBalance()`, `RequestTransfer()` |
| Analytics | `TrackEvent()` |
| Bridge | deep-link to wallet (P1) |

**Regra:** operações que criam valor (mint) exigem **autorização server-side**.

---

## 4. APIs

### REST (P0)
```
POST /v1/auth/session
GET  /v1/players/{id}/inventory
POST /v1/games/{id}/rewards/claim
GET  /v1/catalog/games
POST /v1/marketplace/listings/{id}/buy
GET  /v1/transactions/{sig}
```

### GraphQL (P1)
Consultas compostas de catálogo + ownership + histórico.

### WebSocket (P1)
Eventos: `inventory.updated`, `order.filled`, `reward.available`.

### Webhooks (P1)
`order.completed`, `entitlement.granted`, `nft.minted` — HMAC SHA-256.

---

## 5. Developer Portal

| Feature | Descrição |
|---------|-----------|
| Projects | App ID por jogo |
| API Keys | Live/Test + scopes |
| Webhooks | Endpoint config + delivery logs |
| Sandbox faucet | SOL/MUTTER/dev NFTs |
| Docs | Guias Unity/Unreal/Godot |
| Usage metrics | Rate, errors |
| Revenue | Payouts dashboard |

---

## 6. Ambientes

| Env | Chain | API base |
|-----|-------|----------|
| Sandbox | Solana Devnet | `https://sandbox-api.mutter.gg` |
| Staging | Dedicated | `https://staging-api.mutter.gg` |
| Production | Mainnet | `https://api.mutter.gg` |

(Domains ilustrativos.)

---

## 7. Segurança SDK

- API keys **somente server-side** para mint authority calls
- Client keys com scopes mínimos (read inventory, start auth)
- Certificate pinning opcional em mobile/engines
- Replay protection em reward grants (`grant_id` único)

---

## 8. Exemplo Unity (ilustrativo)

```csharp
await Mutter.Auth.LoginAsync();
var items = await Mutter.Inventory.GetAsync();
await Mutter.Rewards.ClaimAsync(rewardId); // valida no server Mutter
```

---

## 9. Versionamento

- SemVer; changelog obrigatório
- Compatibility matrix engine × SDK
- Deprecation window ≥ 6 meses para breaking changes
