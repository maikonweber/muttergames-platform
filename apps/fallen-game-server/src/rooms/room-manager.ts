import { randomBytes } from 'node:crypto';
import type { WebSocket } from 'ws';
import type { AuthUser } from '../auth/jwt';
import type { ServerMessage } from '../protocol/messages';
import { PvpSession } from '../session/pvp-session';

export type ConnectedClient = {
  clientId: string;
  roomCode: string;
  socket: WebSocket;
  displayName: string;
  auth?: AuthUser | null;
};

export class RoomManager {
  private readonly rooms = new Map<string, PvpSession>();
  private readonly clients = new Map<string, ConnectedClient>();
  private readonly socketsByClient = new Map<string, WebSocket>();

  createRoom(): { roomCode: string; sessionId: string } {
    let code = '';
    do {
      code = randomBytes(3).toString('hex').toUpperCase().slice(0, 6);
    } while (this.rooms.has(code));

    const session = new PvpSession(code, {
      send: (clientId, message) => this.sendTo(clientId, message),
      broadcast: (message, except) => this.broadcast(code, message, except),
    });
    this.rooms.set(code, session);
    return { roomCode: code, sessionId: session.sessionId };
  }

  getRoom(code: string): PvpSession | undefined {
    return this.rooms.get(code.toUpperCase());
  }

  listRooms() {
    return [...this.rooms.values()].map((session) => ({
      roomCode: session.roomCode,
      sessionId: session.sessionId,
      players: session.playerCount,
      status: session.getSnapshot().status,
      createdAt: session.createdAt,
    }));
  }

  joinRoom(input: {
    roomCode: string;
    socket: WebSocket;
    displayName: string;
    auth?: AuthUser | null;
  }): { session: PvpSession; clientId: string; seat: number; resumeToken: string } {
    const code = input.roomCode.toUpperCase();
    const session = this.rooms.get(code);
    if (!session) throw new Error('ROOM_NOT_FOUND');

    const { clientId, seat, resumeToken } = session.addPlayer({
      displayName: input.displayName,
      auth: input.auth,
    });

    this.clients.set(clientId, {
      clientId,
      roomCode: code,
      socket: input.socket,
      displayName: input.displayName,
      auth: input.auth,
    });
    this.socketsByClient.set(clientId, input.socket);
    return { session, clientId, seat, resumeToken };
  }

  createAndJoin(input: {
    socket: WebSocket;
    displayName: string;
    auth?: AuthUser | null;
  }): { session: PvpSession; clientId: string; seat: number; roomCode: string; resumeToken: string } {
    const { roomCode } = this.createRoom();
    const session = this.rooms.get(roomCode)!;
    const { clientId, seat, resumeToken } = session.addPlayer({
      displayName: input.displayName,
      auth: input.auth,
    });
    this.clients.set(clientId, {
      clientId,
      roomCode,
      socket: input.socket,
      displayName: input.displayName,
      auth: input.auth,
    });
    this.socketsByClient.set(clientId, input.socket);
    return { session, clientId, seat, roomCode, resumeToken };
  }

  /** Reclaims a previously assigned seat using the resume token issued at `welcome` time. */
  resumeClient(input: {
    clientId: string;
    resumeToken: string;
    socket: WebSocket;
  }): { session: PvpSession; seat: number; roomCode: string } {
    const client = this.clients.get(input.clientId);
    if (!client) throw new Error('UNKNOWN_CLIENT');
    const session = this.rooms.get(client.roomCode);
    if (!session) throw new Error('NO_SESSION');

    const seat = session.resume(input.clientId, input.resumeToken);
    client.socket = input.socket;
    this.socketsByClient.set(input.clientId, input.socket);
    return { session, seat, roomCode: client.roomCode };
  }

  getClient(clientId: string): ConnectedClient | undefined {
    return this.clients.get(clientId);
  }

  getSessionByClient(clientId: string): PvpSession | undefined {
    const client = this.clients.get(clientId);
    if (!client) return undefined;
    return this.rooms.get(client.roomCode);
  }

  disconnect(clientId: string): void {
    const client = this.clients.get(clientId);
    if (!client) return;
    const session = this.rooms.get(client.roomCode);
    session?.markConnected(clientId, false);
    // Keep the client record around (minus the dead socket) so `resumeClient` can
    // reclaim the seat within the session's reconnect grace period.
    this.socketsByClient.delete(clientId);
  }

  private sendTo(clientId: string, message: ServerMessage): void {
    const socket = this.socketsByClient.get(clientId);
    if (!socket || socket.readyState !== socket.OPEN) return;
    socket.send(JSON.stringify(message));
  }

  private broadcast(roomCode: string, message: ServerMessage, except?: string): void {
    for (const client of this.clients.values()) {
      if (client.roomCode !== roomCode) continue;
      if (except && client.clientId === except) continue;
      if (client.socket.readyState === client.socket.OPEN) {
        client.socket.send(JSON.stringify(message));
      }
    }
  }
}
