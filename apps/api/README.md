# MutterGames API (`apps/api`)

API central NestJS do monorepo (`@muttergames/api`).

**Spec Ecosystem:** [`Ecosystem/projects/02-api.md`](../../Ecosystem/projects/02-api.md)

## Stack

- NestJS 11, TypeScript
- Persistência local via Drizzle (dev)
- Swagger, Pino, métricas Prometheus

## Rodar

```bash
# na raiz (após scripts/init-all.sh ou Compose com Postgres)
pnpm dev:api
# ou
scripts/run-api.sh
```

| Serviço | URL |
|---|---|
| API | http://localhost:3001/api/v1 |
| Swagger | http://localhost:3001/docs |
| Health | `GET /api/v1/health` |
| Metrics | `GET /api/v1/metrics` |

## Módulos principais

`auth`, `wallets`, `marketplace`, `games`, `game-data`, `launcher`, `chain`, `blockchain`, `health`, `observability`.

Contrato ampliado: [`Ecosystem/apis/openapi.yaml`](../../Ecosystem/apis/openapi.yaml).

## Dev vs produção

- Credenciais do Compose são locais — trocar antes de ambiente compartilhado.
- `TYPEORM_SYNCHRONIZE` / sync automático só em desenvolvimento; produção usa migrações.
- Wallet flow: challenge de assinatura em Devnet; não envia transações financeiras automaticamente.

## Launcher

O módulo `launcher` monta o catálogo Windows a partir de env (`*_DOWNLOAD_URL`, `*_SHA256`, `*_EXECUTABLE_PATH`). Spec: [`Ecosystem/tools/03-launcher-spec.md`](../../Ecosystem/tools/03-launcher-spec.md).
