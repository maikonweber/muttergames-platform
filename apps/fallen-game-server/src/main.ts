import { createServer } from 'node:http';
import { config } from './config';
import { createHttpHandler } from './http/routes';
import { RoomManager } from './rooms/room-manager';
import { startUdpGateway } from './udp/gateway';
import { attachWebSocketGateway } from './ws/gateway';

async function main(): Promise<void> {
  const rooms = new RoomManager();
  const httpServer = createServer(createHttpHandler(rooms));
  attachWebSocketGateway(httpServer, rooms);
  const udp = startUdpGateway(rooms);

  httpServer.listen(config.httpPort, config.httpHost, () => {
    // eslint-disable-next-line no-console
    console.log(
      `[fallen-gs] HTTP+WS on http://${config.httpHost}:${config.httpPort} (ws path ${config.wsPath})`,
    );
    // eslint-disable-next-line no-console
    console.log(`[fallen-gs] PVP mode for tenant ${config.gameId}`);
  });

  const shutdown = () => {
    udp.close();
    httpServer.close(() => process.exit(0));
  };
  process.on('SIGINT', shutdown);
  process.on('SIGTERM', shutdown);
}

void main().catch((error: unknown) => {
  // eslint-disable-next-line no-console
  console.error(error);
  process.exit(1);
});
