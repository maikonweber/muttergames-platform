import { Body, Controller, Get, Headers, Post, UnauthorizedException, Version } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { SpendMutterCoinsDto } from './dto/spend-mutter-coins.dto';
import { CreditGameRewardDto } from './dto/credit-game-reward.dto';
import { MutterCoinsService } from './mutter-coins.service';

@ApiTags('muttercoins')
@ApiBearerAuth()
@Controller('muttercoins')
export class MutterCoinsController {
  constructor(private readonly coins: MutterCoinsService, private readonly config: ConfigService) {}

  @Get('me')
  @Version('1')
  @ApiOperation({ summary: 'Saldo e ultimos lancamentos de MutterCoins' })
  summary(@CurrentUser() user: AuthUser) { return this.coins.summary(user.userId); }

  @Post('me/spend')
  @Version('1')
  @ApiOperation({ summary: 'Debita MutterCoins de forma idempotente' })
  spend(@CurrentUser() user: AuthUser, @Body() dto: SpendMutterCoinsDto) {
    return this.coins.spend(user.userId, dto.amountAtomic, dto.description, dto.idempotencyKey, dto.metadata);
  }

  @Post('internal/game-rewards')
  @Public()
  @Version('1')
  @ApiOperation({ summary: 'Crédito interno após validação do servidor de jogo' })
  async creditGameReward(@Headers('x-game-reward-key') key: string | undefined, @Body() dto: CreditGameRewardDto) {
    const expected = this.config.get<string>('GAME_SERVER_REWARD_KEY');
    if (!expected || key !== expected) throw new UnauthorizedException('Invalid game reward key');
    return this.coins.creditVerifiedGameReward({
      userId: dto.userId,
      gameId: dto.gameId,
      amountAtomic: BigInt(dto.amountAtomic),
      kind: 'game_reward',
      description: dto.description,
      idempotencyKey: dto.idempotencyKey,
      metadata: dto.metadata,
    });
  }
}
