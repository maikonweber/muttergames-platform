# Fallen Tactics — Game Server (PVP)

Servidor dedicado autoritativo para **Fallen Tactics PVP**:

| Canal | Porta default | Uso |
|-------|---------------|-----|
| HTTP | `4010` | health, criar/listar salas |
| WebSocket | `4010` path `/v1/session` | commands + state (canal principal) |
| UDP | `9001` | ping/latency + cursor (complementar) |

Alinhado a `Fallen Tactics/project-fallen-tactics/docs/NETWORKING_SERVERS.md`.

**Spec Ecosystem:** [`Ecosystem/projects/04-fallen-game-server.md`](../../Ecosystem/projects/04-fallen-game-server.md)

## Run local

```bash
pnpm install
pnpm --filter @muttergames/fallen-game-server start:dev
```

## HTTP

- `GET /health`
- `POST /v1/rooms` → `{ roomCode, sessionId, wsUrl, udp }`
- `GET /v1/rooms`
- `GET /v1/rooms/:code`

## WebSocket protocol (JSON)

1. Connect `ws://localhost:4010/v1/session`
2. Send `hello` (create room or join with `room_code`)
3. Receive `welcome` + `snapshot`
4. When 2 players join, match starts (`match_started` + `turn_started`)
5. Active player sends `command` (`play_card` / `end_turn` / `surrender`)
6. Server broadcasts `event` / `snapshot`

### hello (create)

```json
{
  "v": 1,
  "type": "hello",
  "protocol_version": 1,
  "display_name": "Tactician",
  "token": "<optional JWT from MutterGames API>"
}
```

### hello (join)

```json
{
  "v": 1,
  "type": "hello",
  "protocol_version": 1,
  "room_code": "A1B2C3",
  "display_name": "Rival"
}
```

### command

```json
{
  "v": 1,
  "type": "command",
  "session_id": "<uuid>",
  "client_id": "<id>",
  "seq": 1,
  "cmd": { "op": "play_card", "unit_id": "hero_alpha", "card_uid": "golpe", "target": { "cell": [6, 3] } }
}
```

## UDP

```json
{ "magic": "FTPV", "v": 1, "type": "ping", "seq": 1, "payload": { "t": 123 } }
```

Combat resolution **never** goes over UDP.

## Env

| Var | Default |
|-----|---------|
| `FALLEN_GS_HTTP_PORT` | `4010` |
| `FALLEN_GS_UDP_PORT` | `9001` |
| `FALLEN_GS_WS_PATH` | `/v1/session` |
| `FALLEN_GS_REQUIRE_AUTH` | `false` |
| `JWT_SECRET` | same as API |
| `FALLEN_GS_MAX_PLAYERS` | `2` |
| `FALLEN_GS_TURN_TIMEOUT_MS` | `90000` |
