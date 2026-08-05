import { Inject, Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { DRIZZLE } from './drizzle.constants';
import type { DrizzleDb } from './drizzle.module';
import { seedDatabase } from './seeds/platform.seed';

@Injectable()
export class SeedService implements OnModuleInit {
  private readonly logger = new Logger(SeedService.name);

  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDb,
    private readonly config: ConfigService,
  ) {}

  async onModuleInit(): Promise<void> {
    if (this.config.get('AUTO_SEED', 'true') === 'false') {
      this.logger.log('AUTO_SEED=false — skipping platform seed');
      return;
    }

    try {
      const result = await seedDatabase(this.db, {
        solanaRpcUrl: this.config.get('SOLANA_RPC_URL', 'https://api.devnet.solana.com'),
        demoPassword: this.config.get('SEED_DEMO_PASSWORD', 'Str0ngP@ss!'),
      });
      this.logger.log(`Platform seed complete: ${JSON.stringify(result.seeded)}`);
    } catch (error) {
      this.logger.warn(`Seed skipped/failed: ${(error as Error).message}`);
    }
  }
}
