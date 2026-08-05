import { INestApplication, ValidationPipe, VersioningType } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { config as loadEnv } from 'dotenv';
import { resolve } from 'node:path';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { seedDatabase } from '../src/drizzle/seeds/platform.seed';
import { DRIZZLE } from '../src/drizzle/drizzle.constants';
import type { DrizzleDb } from '../src/drizzle/drizzle.module';

loadEnv({ path: resolve(__dirname, '../../../.env'), quiet: true });
loadEnv({ path: resolve(__dirname, '../.env'), quiet: true });

(BigInt.prototype as unknown as { toJSON: () => string }).toJSON = function toJSON() {
  return this.toString();
};

describe('MutterGames API (e2e)', () => {
  let app: INestApplication<App>;
  let server: App;
  let accessToken: string;
  let fallenSlug = 'fallen-tactics';
  const suffix = Date.now().toString(36);

  beforeAll(async () => {
    if (!process.env.DATABASE_URL) {
      throw new Error('DATABASE_URL is required for e2e tests');
    }

    process.env.AUTO_SEED = 'false';
    process.env.LOG_LEVEL = 'silent';
    process.env.SOLANA_FEATURE_MODE = 'v2';

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication({ logger: false });
    app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }));
    app.setGlobalPrefix('api');
    app.enableVersioning({ type: VersioningType.URI, defaultVersion: '1' });
    await app.init();
    server = app.getHttpServer();

    const db = app.get<DrizzleDb>(DRIZZLE);
    await seedDatabase(db, {
      solanaRpcUrl: process.env.SOLANA_RPC_URL,
      demoPassword: 'Str0ngP@ss!',
    });
  });

  afterAll(async () => {
    await app.close();
  });

  it('GET /health returns ok', async () => {
    const res = await request(server).get('/api/v1/health').expect(200);
    expect(res.body.status).toBe('ok');
    expect(res.body.timestamp).toBeDefined();
  });

  it('GET /features/solana returns mode and capabilities', async () => {
    const res = await request(server).get('/api/v1/features/solana').expect(200);
    expect(res.body.mode).toBe('v2');
    expect(res.body.capabilities.walletLink).toBe(true);
    expect(res.body.capabilities.chainIntents).toBe(true);
  });

  it('POST /games/:slug/admin/reset-equipment preserves wallets and wipes inventory', async () => {
    const login = await request(server)
      .post('/api/v1/auth/login')
      .send({ login: 'admin', password: 'Str0ngP@ss!' })
      .expect(201);
    const adminToken = login.body.accessToken as string;

    await request(server)
      .put(`/api/v1/games/${fallenSlug}/me/inventory`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ sku: 'reset-me', name: 'Temp Gear', quantity: 1 })
      .expect(200);

    const reset = await request(server)
      .post(`/api/v1/games/${fallenSlug}/admin/reset-equipment`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(201);

    expect(reset.body.preserved).toEqual(
      expect.arrayContaining(['users', 'wallet_links', 'marketplace_catalog']),
    );
    expect(reset.body.deleted.inventoryItems).toBeGreaterThanOrEqual(1);

    const inventory = await request(server)
      .get(`/api/v1/games/${fallenSlug}/me/inventory`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(inventory.body.every((i: { sku: string }) => i.sku !== 'reset-me')).toBe(true);
  });

  it('GET /games lists seeded tenants', async () => {
    const res = await request(server).get('/api/v1/games').expect(200);
    expect(Array.isArray(res.body)).toBe(true);
    const slugs = res.body.map((g: { slug: string }) => g.slug);
    expect(slugs).toEqual(expect.arrayContaining(['fallen-tactics', 'beat-up']));
  });

  it('POST /auth/register + /auth/login + GET /me', async () => {
    const email = `e2e_${suffix}@muttergames.test`;
    const username = `e2e_${suffix}`;

    const register = await request(server)
      .post('/api/v1/auth/register')
      .send({
        email,
        username,
        password: 'Str0ngP@ss!',
        displayName: 'E2E Player',
      })
      .expect(201);

    expect(register.body.user.email).toBe(email);
    expect(register.body.accessToken).toBeDefined();

    const login = await request(server)
      .post('/api/v1/auth/login')
      .send({ login: username, password: 'Str0ngP@ss!' })
      .expect(201);

    accessToken = login.body.accessToken as string;
    expect(accessToken).toMatch(/^eyJ/);

    const me = await request(server)
      .get('/api/v1/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);

    expect(me.body.username).toBe(username);
  });

  it('login with seeded demo player works', async () => {
    const res = await request(server)
      .post('/api/v1/auth/login')
      .send({ login: 'tactician', password: 'Str0ngP@ss!' })
      .expect(201);
    expect(res.body.user.email).toBe('player@muttergames.com');
  });

  it('GET /marketplace/items?gameId= filters by tenant', async () => {
    const res = await request(server)
      .get('/api/v1/marketplace/items')
      .query({ gameId: fallenSlug })
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.length).toBeGreaterThan(0);
    expect(res.body.every((item: { slug: string }) => typeof item.slug === 'string')).toBe(true);
  });

  it('POST /marketplace/orders creates idempotent order', async () => {
    const items = await request(server)
      .get('/api/v1/marketplace/items')
      .query({ gameId: fallenSlug })
      .expect(200);

    const itemId = items.body[0].id as string;
    const idempotencyKey = `e2e-order-${suffix}`;

    const first = await request(server)
      .post('/api/v1/marketplace/orders')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        itemId,
        walletAddress: 'DemoWalletAddress1111111111111111111111111',
        quantity: 1,
        idempotencyKey,
      })
      .expect(201);

    const second = await request(server)
      .post('/api/v1/marketplace/orders')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        itemId,
        walletAddress: 'DemoWalletAddress1111111111111111111111111',
        quantity: 1,
        idempotencyKey,
      })
      .expect(201);

    expect(first.body.id).toBe(second.body.id);
    expect(first.body.status).toBe('created');
  });

  it('GET /games/:slug/releases and patches', async () => {
    const releases = await request(server).get(`/api/v1/games/${fallenSlug}/releases`).expect(200);
    expect(Array.isArray(releases.body)).toBe(true);
    expect(releases.body[0].version).toBeDefined();

    const patch = await request(server)
      .get(`/api/v1/games/${fallenSlug}/patches`)
      .query({ from: '0.1.0' })
      .expect(200);
    expect(patch.body.toVersion).toBe('0.1.1');
  });

  it('PUT /games/:slug/me/profile and GET inventory/profile', async () => {
    await request(server)
      .put(`/api/v1/games/${fallenSlug}/me/profile`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ data: { level: 3, faction: 'iron' } })
      .expect(200);

    const profile = await request(server)
      .get(`/api/v1/games/${fallenSlug}/me/profile`)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);
    expect(profile.body.data.level).toBe(3);

    await request(server)
      .put(`/api/v1/games/${fallenSlug}/me/inventory`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ sku: 'test-badge', name: 'Test Badge', quantity: 2 })
      .expect(200);

    const inventory = await request(server)
      .get(`/api/v1/games/${fallenSlug}/me/inventory`)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);
    expect(inventory.body.some((i: { sku: string }) => i.sku === 'test-badge')).toBe(true);
  });

  it('POST /games/:slug/events is idempotent', async () => {
    const eventId = crypto.randomUUID();
    const idempotencyKey = crypto.randomUUID();
    const payload = {
      eventId,
      type: 'match.completed',
      buildVersion: '0.1.0',
      occurredAt: new Date().toISOString(),
      payload: { winner: true },
      idempotencyKey,
    };

    const first = await request(server)
      .post(`/api/v1/games/${fallenSlug}/events`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send(payload)
      .expect(202);

    const second = await request(server)
      .post(`/api/v1/games/${fallenSlug}/events`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send(payload)
      .expect(202);

    expect(first.body.id).toBe(second.body.id);
  });

  it('POST /wallets/challenges creates challenge', async () => {
    const res = await request(server)
      .post('/api/v1/wallets/challenges')
      .send({
        address: 'DemoWalletAddress1111111111111111111111111',
        chain: 'solana:devnet',
      })
      .expect(201);

    expect(res.body.challengeId).toBeDefined();
    expect(res.body.message).toContain('MutterGames Wallet Link');
  });

  it('POST /chain/intents creates pending intent', async () => {
    const res = await request(server)
      .post('/api/v1/chain/intents')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        kind: 'market_buy',
        walletAddress: 'DemoWalletAddress1111111111111111111111111',
        payload: { itemSlug: 'genesis-tactician' },
      })
      .expect(201);

    expect(res.body.status).toBe('pending');
    expect(res.body.quote.expiresAt).toBeDefined();
  });

  it('GET /launcher/catalog returns seeded releases', async () => {
    const res = await request(server)
      .get('/api/v1/launcher/catalog')
      .query({ platform: 'windows' })
      .expect(200);

    expect(res.body.schemaVersion).toBe(1);
    expect(res.body.games.length).toBeGreaterThanOrEqual(2);
    const fallen = res.body.games.find((g: { id: string }) => g.id === 'fallen-tactics');
    expect(fallen.status).toBe('available');
    expect(fallen.release.version).toBe('0.1.0');
  });

  it('GET /blockchain/networks lists seeded networks', async () => {
    const res = await request(server).get('/api/v1/blockchain/networks').expect(200);
    expect(res.body.some((n: { key: string }) => n.key === 'solana-devnet')).toBe(true);
  });

  it('rejects protected routes without bearer token', async () => {
    await request(server).get('/api/v1/me').expect(401);
  });
});
