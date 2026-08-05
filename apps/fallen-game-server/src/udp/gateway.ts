import dgram from 'node:dgram';
import { config } from '../config';
import type { RoomManager } from '../rooms/room-manager';

/**
 * UDP complementary channel (docs N4):
 * - ping / latency probe
 * - cursor presence (lossy ok)
 * Never used for authoritative combat resolution.
 */
export type UdpEnvelope = {
  magic: 'FTPV';
  v: 1;
  type: 'ping' | 'pong' | 'cursor';
  session_id?: string;
  client_id?: string;
  seq?: number;
  payload?: Record<string, unknown>;
};

export function startUdpGateway(rooms: RoomManager): dgram.Socket {
  const socket = dgram.createSocket('udp4');

  socket.on('message', (buf, rinfo) => {
    let msg: UdpEnvelope;
    try {
      msg = JSON.parse(buf.toString('utf8')) as UdpEnvelope;
    } catch {
      return;
    }
    if (msg.magic !== 'FTPV' || msg.v !== 1) return;

    if (msg.type === 'ping') {
      const pong: UdpEnvelope = {
        magic: 'FTPV',
        v: 1,
        type: 'pong',
        session_id: msg.session_id,
        client_id: msg.client_id,
        seq: msg.seq,
        payload: { server_time: new Date().toISOString(), echo: msg.payload ?? {} },
      };
      socket.send(Buffer.from(JSON.stringify(pong)), rinfo.port, rinfo.address);
      return;
    }

    if (msg.type === 'cursor') {
      if (!msg.session_id || !msg.client_id) return;
      const session = [...rooms.listRooms()].find((r) => r.sessionId === msg.session_id);
      if (!session) return;
      // Presence only — no state mutation.
      return;
    }
  });

  socket.bind(config.udpPort, config.httpHost, () => {
    // eslint-disable-next-line no-console
    console.log(`[fallen-gs] UDP listening on ${config.httpHost}:${config.udpPort}`);
  });

  return socket;
}
