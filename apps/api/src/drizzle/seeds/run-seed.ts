import { config as loadEnv } from 'dotenv';
import { drizzle } from 'drizzle-orm/node-postgres';
import { resolve } from 'node:path';
import { Pool } from 'pg';
import * as schema from '../schema';
import { seedDatabase } from './platform.seed';

loadEnv({ path: resolve(__dirname, '../../../../.env') });
loadEnv({ path: resolve(__dirname, '../../../.env') });

async function main(): Promise<void> {
  const url = process.env.DATABASE_URL;
  if (!url) throw new Error('DATABASE_URL is required');

  const pool = new Pool({ connectionString: url, max: 5 });
  const db = drizzle(pool, { schema });

  try {
    const result = await seedDatabase(db, {
      solanaRpcUrl: process.env.SOLANA_RPC_URL,
      demoPassword: process.env.SEED_DEMO_PASSWORD ?? 'Str0ngP@ss!',
    });
    // eslint-disable-next-line no-console
    console.log(JSON.stringify({ ok: true, ...result }, null, 2));
  } finally {
    await pool.end();
  }
}

void main().catch((error: unknown) => {
  // eslint-disable-next-line no-console
  console.error(error);
  process.exit(1);
});
