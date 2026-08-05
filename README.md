# MutterGames Platform

Monorepo inicial do ecossistema MutterGames.

## Estrutura

- `apps/web`: aplicacao web oficial do workspace.
- `apps/api`: API oficial do workspace.
- `apps/launcher`: launcher Windows que instala, atualiza e abre os jogos.
- `Blockchain`: programa e documentacao da MutterCoin em Solana.
- `Beat Up` e `Fallen Tactics`: projetos dos jogos em Godot.
- `Ecosystem`: especificacoes de produto, arquitetura e integracoes.
- `infra`: configuracao local de observabilidade.
- `outputs`: documentos consolidados do projeto.
- `scripts`: atalhos para inicializacao local.

`muttergames-web` e uma copia web independente mantida como referencia. O app
executado pela raiz e pelo Docker Compose e sempre `apps/web`.

## Aplicacoes

- `apps/web`: Next.js com site, blockchain, marketplace e portal de wallet.
- `apps/api`: NestJS com API central, PostgreSQL, Swagger, Pino e Prometheus.
- `infra`: Prometheus, Grafana, Loki e Grafana Alloy.

## Iniciar com Docker

```powershell
Copy-Item .env.example .env
docker compose up --build
```

Para executar apenas uma parte do monorepo, instale Node.js 22 e pnpm 11 e use
`pnpm dev:web` ou `pnpm dev:api` na raiz.

Servicos disponiveis:

- Web: http://localhost:3000
- API: http://localhost:3001/api/v1
- Swagger: http://localhost:3001/docs
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3002 (`admin` / `admin`, apenas local)
- Alloy: http://localhost:12345

## Rotas principais

- `GET /api/v1/blockchain/networks`
- `GET /api/v1/blockchain/networks/:key/status`
- `GET /api/v1/marketplace/items`
- `POST /api/v1/marketplace/orders`
- `POST /api/v1/wallets/challenges`
- `GET /api/v1/health`
- `GET /api/v1/launcher/catalog?platform=windows`
- `GET /api/v1/metrics`

## Seguranca

As credenciais sao valores locais e devem ser alteradas antes de qualquer ambiente compartilhado. O fluxo de wallet usa Devnet e somente cria um desafio de assinatura; ele nao envia transacoes financeiras.

`TYPEORM_SYNCHRONIZE=true` existe apenas no Compose de desenvolvimento. Producao deve usar migracoes versionadas e manter essa opcao desativada.
