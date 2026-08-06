# PRJ-04 — Fallen Game Server

**Pasta:** `apps/fallen-game-server`  
**Pacote:** `@muttergames/fallen-game-server`  
**Stack:** Node/TypeScript (HTTP + WebSocket + UDP)  
**Status:** Protótipo PVP (salas 1v1)  
**Owner:** Eng Fallen Tactics / Networking

## 1. Objetivo

Servidor dedicado **autoritativo** para partidas PVP de Fallen Tactics: salas, snapshot de estado, comandos de turno, latência.

## 2. Canais

| Canal | Porta default | Uso |
|---|---|---|
| HTTP | `4010` | health, criar/listar salas |
| WebSocket | `4010` `/v1/session` | commands + state |
| UDP | `9001` | ping/latency + cursor (`magic: FTPV`); **nunca** combate |

## 3. Requisitos

| ID | Requisito | Aceite |
|---|---|---|
| FGS-RF-01 | Criar/listar salas HTTP | `POST/GET /v1/rooms` |
| FGS-RF-02 | Sessão WS com hello/welcome/snapshot | Dois jogadores iniciam match |
| FGS-RF-03 | Comandos `play_card` / `end_turn` / `surrender` | Broadcast de event/snapshot |
| FGS-RF-04 | UDP complementar apenas | Combate/estado autoritativo só no WS |
| FGS-RF-05 | Alinhamento com docs do jogo | `NETWORKING_SERVERS.md`, `PVP_*` |

## 4. Como rodar

```bash
pnpm --filter @muttergames/fallen-game-server start:dev
# ou pnpm dev:fallen-gs
```

## 5. Docs

- [`apps/fallen-game-server/README.md`](../../apps/fallen-game-server/README.md)
- Cliente: `Fallen Tactics/.../docs/PVP_CLIENT.md`
- Protocolo: `.../docs/NETWORKING_SERVERS.md`
- Status: `.../docs/PVP_SERVER_STATUS.md`
- Integração: [`../game-integrations/fallen-tactics.md`](../game-integrations/fallen-tactics.md)

## 6. Limites atuais

- Foco 1v1; torneios/valor on-chain fora do escopo até antifraude e auditoria.
- JWT opcional — validar antes de ambientes compartilhados.
