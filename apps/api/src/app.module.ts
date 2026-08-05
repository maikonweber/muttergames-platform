import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_GUARD, APP_INTERCEPTOR } from '@nestjs/core';
import { LoggerModule } from 'nestjs-pino';
import { randomUUID } from 'node:crypto';
import { AuthModule } from './auth/auth.module';
import { BlockchainModule } from './blockchain/blockchain.module';
import { ChainModule } from './chain/chain.module';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';
import { DrizzleModule } from './drizzle/drizzle.module';
import { GameDataModule } from './game-data/game-data.module';
import { GamesModule } from './games/games.module';
import { HealthModule } from './health/health.module';
import { LauncherModule } from './launcher/launcher.module';
import { MarketplaceModule } from './marketplace/marketplace.module';
import { MetricsInterceptor } from './observability/metrics.interceptor';
import { ObservabilityModule } from './observability/observability.module';
import { PatchesModule } from './patches/patches.module';
import { SolanaFeatureModule } from './solana-feature/solana-feature.module';
import { WalletsModule } from './wallets/wallets.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env', '../../.env', '../.env'],
    }),
    LoggerModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        pinoHttp: {
          level: config.get('LOG_LEVEL', 'info'),
          redact: ['req.headers.authorization', 'req.headers.cookie'],
          genReqId: (request) => {
            const requestId = request.headers['x-request-id'];
            return typeof requestId === 'string' ? requestId : randomUUID();
          },
        },
      }),
    }),
    DrizzleModule,
    SolanaFeatureModule,
    HealthModule,
    ObservabilityModule,
    AuthModule,
    GamesModule,
    PatchesModule,
    GameDataModule,
    ChainModule,
    BlockchainModule,
    MarketplaceModule,
    WalletsModule,
    LauncherModule,
  ],
  providers: [
    { provide: APP_INTERCEPTOR, useClass: MetricsInterceptor },
    { provide: APP_GUARD, useClass: JwtAuthGuard },
  ],
})
export class AppModule {}
