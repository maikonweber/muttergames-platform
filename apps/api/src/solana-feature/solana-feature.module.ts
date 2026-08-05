import { Global, Module } from '@nestjs/common';
import { SolanaFeatureController } from './solana-feature.controller';
import { SolanaFeatureService } from './solana-feature.service';

@Global()
@Module({
  controllers: [SolanaFeatureController],
  providers: [SolanaFeatureService],
  exports: [SolanaFeatureService],
})
export class SolanaFeatureModule {}
