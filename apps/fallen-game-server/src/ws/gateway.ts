import type { IncomingMessage, Server as HttpServer } from 'node:http';
import { WebSocketServer, type WebSocket } from 'ws';
import { verifyOptionalToken } from '../auth/jwt';
import { config } from '../config';
import { ClientMessageSchema } from '../protocol/messages';
import type { RoomManager } from '../rooms/room-manager';

type SocketState = {
  clientId?: string;
  authed?: boolean;
};

export function attachWebSocketGateway(httpServer: HttpServer, rooms: RoomManager): WebSocketServer {
  const wss = new WebSocketServer({ server: httpServer, path: config.wsPath });

  wss.on('connection', (socket: WebSocket, _req: IncomingMessage) => {
    const state: SocketState = {};

    socket.send(
      JSON.stringify({
        v: 1,
        type: 'event',
        server_seq: 0,
        session_id: '00000000-0000-0000-0000-000000000000',
        events: [],
        hint: 'Send hello to create/join a PVP room',
      }),
    );

    socket.on('message', (raw) => {
      try {
        const parsed = ClientMessageSchema.parse(JSON.parse(String(raw)));
        handleMessage(socket, state, rooms, parsed);
      } catch (error) {
        socket.send(
          JSON.stringify({
            v: 1,
            type: 'error',
            code: 'BAD_MESSAGE',
            message: error instanceof Error ? error.message : 'Invalid message',
          }),
        );
      }
    });

    socket.on('close', () => {
      if (state.clientId) rooms.disconnect(state.clientId);
    });
  });

  return wss;
}

function handleMessage(
  socket: WebSocket,
  state: SocketState,
  rooms: RoomManager,
  message: ReturnType<typeof ClientMessageSchema.parse>,
): void {
  switch (message.type) {
    case 'ping':
      socket.send(
        JSON.stringify({
          v: 1,
          type: 'pong',
          t: message.t,
          server_time: new Date().toISOString(),
        }),
      );
      return;

    case 'hello': {
      if (message.protocol_version !== config.protocolVersion) {
        socket.send(
          JSON.stringify({
            v: 1,
            type: 'error',
            code: 'PROTOCOL_MISMATCH',
            message: `Expected protocol ${config.protocolVersion}`,
          }),
        );
        return;
      }

      // Reconnect: same client_id + resume_token issued in a previous `welcome`.
      if (message.client_id && message.resume_token) {
        try {
          const resumed = rooms.resumeClient({
            clientId: message.client_id,
            resumeToken: message.resume_token,
            socket,
          });
          state.clientId = message.client_id;
          state.authed = true;

          socket.send(
            JSON.stringify({
              v: 1,
              type: 'welcome',
              client_id: message.client_id,
              session_id: resumed.session.sessionId,
              room_code: resumed.roomCode,
              seat: resumed.seat,
              seed: resumed.session.seed,
              protocol_version: config.protocolVersion,
              game_id: config.gameId,
              mode: 'pvp',
              resume_token: message.resume_token,
              reconnect_grace_ms: config.reconnectGraceMs,
            }),
          );
          resumed.session.sendSnapshot(message.client_id);
        } catch (error) {
          socket.send(
            JSON.stringify({
              v: 1,
              type: 'error',
              code: error instanceof Error ? error.message : 'RESUME_FAILED',
              message: error instanceof Error ? error.message : 'Failed to resume session',
            }),
          );
        }
        return;
      }

      let auth = null;
      try {
        auth = verifyOptionalToken(message.token);
      } catch (error) {
        socket.send(
          JSON.stringify({
            v: 1,
            type: 'error',
            code: String(error),
            message: 'Authentication failed',
          }),
        );
        return;
      }

      const displayName = message.display_name ?? auth?.username ?? `Guest-${Math.floor(Math.random() * 9999)}`;

      try {
        const joined = message.room_code
          ? rooms.joinRoom({
              roomCode: message.room_code,
              socket,
              displayName,
              auth,
            })
          : rooms.createAndJoin({ socket, displayName, auth });

        state.clientId = joined.clientId;
        state.authed = true;

        socket.send(
          JSON.stringify({
            v: 1,
            type: 'welcome',
            client_id: joined.clientId,
            session_id: joined.session.sessionId,
            room_code: joined.session.roomCode,
            seat: joined.seat,
            seed: joined.session.seed,
            protocol_version: config.protocolVersion,
            game_id: config.gameId,
            mode: 'pvp',
            resume_token: joined.resumeToken,
            reconnect_grace_ms: config.reconnectGraceMs,
          }),
        );
        joined.session.sendSnapshot(joined.clientId);
      } catch (error) {
        socket.send(
          JSON.stringify({
            v: 1,
            type: 'error',
            code: error instanceof Error ? error.message : 'JOIN_FAILED',
            message: error instanceof Error ? error.message : 'Failed to join room',
          }),
        );
      }
      return;
    }

    case 'command': {
      if (!state.clientId) {
        socket.send(JSON.stringify({ v: 1, type: 'error', code: 'NOT_JOINED', message: 'Send hello first' }));
        return;
      }
      const session = rooms.getSessionByClient(state.clientId);
      if (!session) {
        socket.send(JSON.stringify({ v: 1, type: 'error', code: 'NO_SESSION', message: 'Session missing' }));
        return;
      }
      try {
        session.handleCommand({ ...message, client_id: state.clientId });
      } catch (error) {
        socket.send(
          JSON.stringify({
            v: 1,
            type: 'error',
            code: error instanceof Error ? error.message : 'COMMAND_FAILED',
            message: error instanceof Error ? error.message : 'Command failed',
            seq: message.seq,
          }),
        );
      }
      return;
    }

    case 'resync_request': {
      if (!state.clientId) return;
      const session = rooms.getSessionByClient(state.clientId);
      session?.sendSnapshot(state.clientId);
      return;
    }
  }
}
