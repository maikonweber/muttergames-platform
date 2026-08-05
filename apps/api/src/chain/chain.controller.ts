import { Body, Controller, Get, Param, Post, Version } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { ChainService } from './chain.service';
import { ConfirmChainIntentDto } from './dto/confirm-chain-intent.dto';
import { CreateChainIntentDto } from './dto/create-chain-intent.dto';

@ApiTags('chain')
@ApiBearerAuth()
@Controller('chain')
export class ChainController {
  constructor(private readonly chain: ChainService) {}

  @Post('intents')
  @Version('1')
  @ApiOperation({ summary: 'Cria intent on-chain (Solana)' })
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateChainIntentDto) {
    return this.chain.createIntent(user.userId, dto);
  }

  @Get('intents/:id')
  @Version('1')
  @ApiOperation({ summary: 'Consulta intent' })
  get(@Param('id') id: string) {
    return this.chain.getIntent(id);
  }

  @Post('intents/:id/confirm')
  @Version('1')
  @ApiOperation({ summary: 'Confirma intent com signature da tx' })
  confirm(@Param('id') id: string, @Body() dto: ConfirmChainIntentDto) {
    return this.chain.confirm(id, dto);
  }

  @Public()
  @Get('tx/:signature')
  @Version('1')
  @ApiOperation({ summary: 'Lookup por signature Solana' })
  byTx(@Param('signature') signature: string) {
    return this.chain.byTx(signature);
  }
}
