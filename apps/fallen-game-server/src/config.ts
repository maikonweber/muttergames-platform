import { config as loadEnv } from 'dotenv';
import { resolve } from 'node:path';

loadEnv({ path: resolve(__dirname, '../../../.env') });
loadEnv({ path: resolve(__dirname, '../.env') });

function num(name: string, fallback: number): number {
  const raw = process.env[name];
  if (!raw) return fallback;
  const value = Number(raw);
  return Number.isFinite(value) ? value : fallback;
}

export const config = {
  gameId: 'fallen-tactics',
  protocolVersion: 1,
  httpHost: process.env.FALLEN_GS_HOST ?? '0.0.0.0',
  httpPort: num('FALLEN_GS_HTTP_PORT', 4010),
  wsPath: process.env.FALLEN_GS_WS_PATH ?? '/v1/session',
  udpPort: num('FALLEN_GS_UDP_PORT', 9001),
  jwtSecret: process.env.JWT_SECRET ?? 'muttergames-dev-jwt-secret-change-me',
  requireAuth: (process.env.FALLEN_GS_REQUIRE_AUTH ?? 'false') === 'true',
  maxPlayersPerRoom: num('FALLEN_GS_MAX_PLAYERS', 2),
  turnTimeoutMs: num('FALLEN_GS_TURN_TIMEOUT_MS', 90_000),
  roomIdleMs: num('FALLEN_GS_ROOM_IDLE_MS', 30 * 60_000),
  reconnectGraceMs: num('FALLEN_GS_RECONNECT_GRACE_MS', 60_000),
  corsOrigin: process.env.WEB_ORIGIN ?? '*',
};
