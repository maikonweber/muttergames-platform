import type { IncomingMessage, ServerResponse } from 'node:http';
import { config } from '../config';
import type { RoomManager } from '../rooms/room-manager';

function sendJson(res: ServerResponse, status: number, body: unknown): void {
  const payload = JSON.stringify(body);
  res.writeHead(status, {
    'content-type': 'application/json; charset=utf-8',
    'access-control-allow-origin': config.corsOrigin,
    'access-control-allow-headers': 'content-type, authorization',
    'access-control-allow-methods': 'GET,POST,OPTIONS',
  });
  res.end(payload);
}

async function readJson(req: IncomingMessage): Promise<unknown> {
  const chunks: Buffer[] = [];
  for await (const chunk of req) chunks.push(Buffer.from(chunk));
  if (!chunks.length) return {};
  return JSON.parse(Buffer.concat(chunks).toString('utf8'));
}

export function createHttpHandler(rooms: RoomManager) {
  return async (req: IncomingMessage, res: ServerResponse): Promise<void> => {
    const url = new URL(req.url ?? '/', `http://${req.headers.host ?? 'localhost'}`);

    if (req.method === 'OPTIONS') {
      sendJson(res, 204, {});
      return;
    }

    if (req.method === 'GET' && url.pathname === '/health') {
      sendJson(res, 200, {
        status: 'ok',
        gameId: config.gameId,
        protocolVersion: config.protocolVersion,
        wsPath: config.wsPath,
        udpPort: config.udpPort,
        rooms: rooms.listRooms().length,
        timestamp: new Date().toISOString(),
      });
      return;
    }

    if (req.method === 'GET' && url.pathname === '/v1/economy') {
      sendJson(res, 200, {
        currency: { symbol: 'MUTTER', decimals: 9, settlement: 'central-api-ledger' },
        gameId: config.gameId,
        rewardPolicy: 'Only server-validated match results may call POST /api/v1/muttercoins/internal/game-rewards.',
      });
      return;
    }

    if (req.method === 'GET' && url.pathname === '/v1/rooms') {
      sendJson(res, 200, { rooms: rooms.listRooms() });
      return;
    }

    if (req.method === 'POST' && url.pathname === '/v1/rooms') {
      const created = rooms.createRoom();
      sendJson(res, 201, {
        roomCode: created.roomCode,
        sessionId: created.sessionId,
        wsUrl: `ws://localhost:${config.httpPort}${config.wsPath}`,
        udp: { host: '127.0.0.1', port: config.udpPort },
        mode: 'pvp',
        maxPlayers: config.maxPlayersPerRoom,
      });
      return;
    }

    if (req.method === 'GET' && url.pathname.startsWith('/v1/rooms/')) {
      const code = url.pathname.split('/').pop() ?? '';
      const room = rooms.getRoom(code);
      if (!room) {
        sendJson(res, 404, { error: 'ROOM_NOT_FOUND' });
        return;
      }
      sendJson(res, 200, {
        roomCode: room.roomCode,
        sessionId: room.sessionId,
        snapshot: room.getSnapshot(),
      });
      return;
    }

    if (req.method === 'POST' && url.pathname === '/v1/debug/echo') {
      const body = await readJson(req);
      sendJson(res, 200, { echo: body });
      return;
    }

    sendJson(res, 404, { error: 'NOT_FOUND' });
  };
}
