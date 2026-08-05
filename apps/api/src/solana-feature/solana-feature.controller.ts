import { Controller, Get, Param, Post, Version } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { SolanaFeatureService } from './solana-feature.service';

@ApiTags('solana-feature')
@Controller()
export class SolanaFeatureController {
  constructor(private readonly feature: SolanaFeatureService) {}

  @Public()
  @Get('features/solana')
  @Version('1')
  @ApiOperation({ summary: 'Status da feature flag Solana (off | tester | v2)' })
  status() {
    return this.feature.getStatus();
  }

  @Post('games/:gameId/admin/reset-equipment')
  @Version('1')
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Reseta equipamentos do jogo (inventário/pedidos/intents), preservando users e wallets',
  })
  resetEquipment(@Param('gameId') gameId: string, @CurrentUser() user: AuthUser) {
    return this.feature.resetEquipment(gameId, user.userId);
  }

  @Post('admin/reset-equipment')
  @Version('1')
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Reseta equipamentos em todos os jogos onde o usuário é admin',
  })
  resetAll(@CurrentUser() user: AuthUser) {
    return this.feature.resetEquipmentAll(user.userId);
  }
}
