# PRJ-02 — API Central

**Pasta:** `apps/api`  
**Pacote:** `@muttergames/api`  
**Stack:** NestJS 11, TypeScript, Drizzle + Postgres (`DATABASE_URL`), Swagger, Pino, Prometheus  
**Status:** MVP local  
**Owner:** Eng plataforma

## 1. Objetivo

API autoritativa da plataforma: auth, wallets, marketplace, games, launcher catalog, intents de chain, health e métricas.

## 2. Não-objetivos

- Autoridade de combate PVP (isso é `fallen-game-server`).
- Mainnet / custódia de chaves privilegiadas no cliente.
- `TYPEORM_SYNCHRONIZE` em produção.

## 3. Módulos

`auth`, `wallets`, `marketplace`, `games`, `game-data`, `launcher`, `chain`, `blockchain`, `solana-feature`, `patches`, `observability`, `health`.

## 4. Requisitos

| ID | Requisito | Aceite |
|---|---|---|
| API-RF-01 | Versionamento `/api/v1` | Prefixo estável |
| API-RF-02 | Swagger | `/docs` |
| API-RF-03 | Health + metrics | Endpoints documentados |
| API-RF-04 | Catálogo launcher | `GET /launcher/catalog?platform=windows` |
| API-RF-05 | Wallet challenges | Nonce/domain/expiry; Devnet |
| API-RF-06 | Marketplace items/orders | Fluxo local de protótipo |
| API-RF-07 | OpenAPI alinhado | `Ecosystem/apis/openapi.yaml` como contrato alvo |
| API-RF-08 | Scripts de schema Drizzle | `db:generate` / `migrate` / `push` / `studio` / `seed` |

## 5. Como rodar

```bash
scripts/init-all.sh   # ou docker compose
pnpm dev:api
# http://localhost:3001/api/v1  (API_PORT=3001)
# http://localhost:3001/docs
```

## 6. Segurança (dev)

- Secrets locais apenas; trocar antes de ambiente compartilhado.
- Sem txs financeiras automáticas no fluxo de wallet.
- Produção: migrações versionadas, sync desligado.

## 7. Docs

- [`apps/api/README.md`](../../apps/api/README.md)
- [`Ecosystem/apis/openapi.yaml`](../apis/openapi.yaml)
- Arquitetura: [`../architecture/01-system-architecture.md`](../architecture/01-system-architecture.md)
