import { Global, Inject, Module, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { drizzle, type NodePgDatabase } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import { DRIZZLE } from './drizzle.constants';
import * as schema from './schema';
import { SeedService } from './seed.service';

export type DrizzleDb = NodePgDatabase<typeof schema>;

export const PG_POOL = Symbol('PG_POOL');

@Global()
@Module({
  providers: [
    {
      provide: PG_POOL,
      inject: [ConfigService],
      useFactory: (config: ConfigService): Pool => {
        const url = config.getOrThrow<string>('DATABASE_URL');
        return new Pool({ connectionString: url, max: 10 });
      },
    },
    {
      provide: DRIZZLE,
      inject: [PG_POOL],
      useFactory: (pool: Pool): DrizzleDb => drizzle(pool, { schema }),
    },
    SeedService,
  ],
  exports: [DRIZZLE, PG_POOL],
})
export class DrizzleModule implements OnModuleDestroy {
  private closed = false;

  constructor(@Inject(PG_POOL) private readonly pool: Pool) {}

  async onModuleDestroy(): Promise<void> {
    if (this.closed) return;
    this.closed = true;
    await this.pool.end();
  }
}
