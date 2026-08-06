# MutterGames Platform

Monorepo inicial do ecossistema MutterGames.

## Estrutura

- `apps/web`: aplicacao web oficial do workspace.
- `apps/api`: API oficial do workspace.
- `apps/launcher`: launcher Windows que instala, atualiza e abre os jogos.
- `apps/fallen-game-server`: servidor dedicado PVP do Fallen Tactics.
- `Blockchain`: programa e documentacao da MutterCoin em Solana.
- `Beat Up`, `Fallen Tactics`, `TaskBarPlanetsForger`, `ForgeOfChampions`: jogos (Godot ou conceito).
- `Ecosystem`: specs de produto, arquitetura, **projetos**, integracoes e ferramentas.
- `infra`: configuracao local de observabilidade.
- `outputs`: documentos consolidados ([indice](outputs/README.md), [revisao](outputs/MutterGames-Project-Review.md)).
- `scripts`: bootstrap local e Creative Tools.

## Specs por projeto

Indice canônico: **[Ecosystem/projects/README.md](Ecosystem/projects/README.md)** (PRJ-01 … PRJ-11).

## Ferramentas

| Ferramenta | Onde | Spec |
|---|---|---|
| Creative Tools | `scripts/mutter-creative.sh` | [Ecosystem/tools/02-creative-tools-spec.md](Ecosystem/tools/02-creative-tools-spec.md) |
| OpenRouter Image | `scripts/openrouter-image.sh` | [Ecosystem/tools/06-openrouter-image-spec.md](Ecosystem/tools/06-openrouter-image-spec.md) |
| OpenRouter Game | `scripts/openrouter-game.sh` | [Ecosystem/tools/08-openrouter-game-spec.md](Ecosystem/tools/08-openrouter-game-spec.md) |
| Game Kit | `scripts/mutter-gamekit.sh` | [Ecosystem/tools/09-gamekit-spec.md](Ecosystem/tools/09-gamekit-spec.md) |
| Mutter Forge | `scripts/mutter-forge.sh` | [Ecosystem/tools/10-mutter-forge-spec.md](Ecosystem/tools/10-mutter-forge-spec.md) |
| Launcher | `apps/launcher` | [Ecosystem/tools/03-launcher-spec.md](Ecosystem/tools/03-launcher-spec.md) |
| Seed Lab | Taskbar Planets | [Ecosystem/tools/04-seed-lab-spec.md](Ecosystem/tools/04-seed-lab-spec.md) |
| Bootstrap local | `scripts/init-all.sh`, `run-*.sh` | [Ecosystem/tools/05-local-dev-toolchain-spec.md](Ecosystem/tools/05-local-dev-toolchain-spec.md) |

Indice: [Ecosystem/tools/README.md](Ecosystem/tools/README.md) · [scripts/README.md](scripts/README.md) · [Ecosystem/projects/](Ecosystem/projects/README.md).  
Guias rapidos: [creative-tools/README.md](scripts/creative-tools/README.md), [openrouter-image](scripts/creative-tools/openrouter-image.md), [openrouter-game](scripts/creative-tools/openrouter-game.md), [gamekit](scripts/creative-tools/gamekit.md).

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
