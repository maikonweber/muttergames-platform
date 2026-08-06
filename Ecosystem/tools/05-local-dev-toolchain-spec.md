# Spec — Local Dev Toolchain (TOOL-04)

**Versão:** 1.0.0  
**Data:** 2026-08-05  
**Entrada:** `scripts/` + Docker Compose na raiz

## 1. Objetivo

Padronizar o bootstrap e a execução local da plataforma MutterGames (API, web, dados, observabilidade e opcionalmente Solana) sem depender de setup manual ad hoc.

## 2. Componentes

| Script | Função |
|---|---|
| `scripts/init-all.sh` | Cria `.env`, `pnpm install`, sobe Postgres + stack de observabilidade |
| `scripts/run-api.sh` | Sobe API |
| `scripts/run-web.sh` | Sobe web |
| `scripts/run-local-stack.sh` | Orquestra stack local |
| `scripts/run-solana-local.sh` | Sandbox Solana (se CLI presente) |
| `scripts/mutter-creative.sh` | Creative Tools (TOOL-01) |
| `docker compose up --build` | Stack completa documentada no README raiz |

## 3. Pré-requisitos

| Recurso | Versão / nota |
|---|---|
| Node.js | 22 |
| pnpm | 11 (`packageManager` no `package.json`) |
| Docker / Compose | Obrigatório para DB e observabilidade |
| .NET SDK 8 | Somente para build do launcher |
| Godot 4.7+ | Jogos |
| Solana CLI | Opcional |
| Bash | WSL ou Git Bash no Windows |

## 4. Requisitos funcionais

| ID | Requisito | Aceite |
|---|---|---|
| DV-RF-01 | `init-all` falha se faltar pnpm ou docker | Mensagem clara, exit ≠0 |
| DV-RF-02 | Copia `.env.example` → `.env` se ausente | Não sobrescreve `.env` existente |
| DV-RF-03 | Sobe postgres, prometheus, loki, alloy, grafana | Containers healthy/local |
| DV-RF-04 | Avisa se Solana CLI ausente | Continua sem bloquear |
| DV-RF-05 | README raiz documenta URLs locais | Web `:3000`, API `:3001`, etc. |

## 5. Serviços locais de referência

| Serviço | URL |
|---|---|
| Web | http://localhost:3000 |
| API | http://localhost:3001/api/v1 |
| Swagger | http://localhost:3001/docs |
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3002 (`admin`/`admin` local) |
| Alloy | http://localhost:12345 |
| Fallen Game Server | http://localhost:4010 (quando iniciado) |

## 6. Comandos pnpm da raiz

| Script | Ação |
|---|---|
| `pnpm dev:web` | Next.js oficial (`apps/web`) |
| `pnpm dev:api` | NestJS API |
| `pnpm dev:fallen-gs` | Game server PVP |
| `pnpm build:launcher` | Publica launcher win-x64 em `outputs/launcher` |
| `pnpm build` / `typecheck` / `lint` | Workspace |

## 7. Segurança local

- Credenciais do Compose são **somente locais**; trocar antes de ambiente compartilhado.
- `TYPEORM_SYNCHRONIZE=true` só em desenvolvimento.
- Wallet flow usa Devnet e challenge de assinatura — sem tx financeira automática.

## 8. Critérios de aceite

1. Em máquina limpa com deps instaladas, `init-all` + `dev:api` + `dev:web` sobe health OK.  
2. Swagger responde com rotas do README.  
3. Ausência de Solana CLI não impede API/web.  
4. `muttergames-web` **não** é iniciado pelos scripts oficiais.

## 9. Evolução

| Item | Prioridade |
|---|---|
| Script PowerShell espelho (`init-all.ps1`) | P1 (dev Windows-first) |
| `make`/`just` targets unificados | P2 |
| Profile Compose `games` (fallen-gs + mocks) | P2 |
| Healthcheck agregado `scripts/doctor-platform.sh` | P1 |
