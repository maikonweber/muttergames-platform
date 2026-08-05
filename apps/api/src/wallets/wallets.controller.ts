import { Body, Controller, Get, HttpCode, Post, Version } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { CreateWalletChallengeDto } from './dto/create-wallet-challenge.dto';
import { VerifyWalletChallengeDto } from './dto/verify-wallet-challenge.dto';
import { WalletsService } from './wallets.service';

@ApiTags('wallets')
@Controller()
export class WalletsController {
  constructor(private readonly wallets: WalletsService) {}

  @Public()
  @Post('wallets/challenges')
  @Version('1')
  @ApiOperation({ summary: 'Cria challenge de assinatura Solana' })
  createChallenge(@Body() dto: CreateWalletChallengeDto) {
    return this.wallets.createChallenge(dto);
  }

  @Post('me/wallet-links/challenge')
  @Version('1')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Challenge autenticado para vincular wallet' })
  createAuthenticatedChallenge(@CurrentUser() user: AuthUser, @Body() dto: CreateWalletChallengeDto) {
    return this.wallets.createChallenge(dto, user.userId);
  }

  @Post('me/wallet-links/verify')
  @Version('1')
  @HttpCode(200)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Verifica assinatura e vincula wallet' })
  verify(@CurrentUser() user: AuthUser, @Body() dto: VerifyWalletChallengeDto) {
    return this.wallets.verify(dto, user.userId);
  }

  @Get('me/wallet-links')
  @Version('1')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Lista wallets vinculadas' })
  list(@CurrentUser() user: AuthUser) {
    return this.wallets.listLinks(user.userId);
  }
}
