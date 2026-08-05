import { Body, Controller, Get, HttpCode, Param, Post, Put, UseGuards, Version } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { TenantGuard } from '../common/guards/tenant.guard';
import { IngestGameEventDto } from './dto/ingest-game-event.dto';
import { UpsertInventoryDto } from './dto/upsert-inventory.dto';
import { UpsertProfileDto } from './dto/upsert-profile.dto';
import { GameDataService } from './game-data.service';

@ApiTags('game-data')
@ApiBearerAuth()
@Controller('games/:gameId')
@UseGuards(TenantGuard)
export class GameDataController {
  constructor(private readonly gameData: GameDataService) {}

  @Get('me/profile')
  @Version('1')
  @ApiOperation({ summary: 'Perfil/progressão do jogador no tenant' })
  getProfile(@Param('gameId') gameId: string, @CurrentUser() user: AuthUser) {
    return this.gameData.getProfile(gameId, user.userId);
  }

  @Put('me/profile')
  @Version('1')
  @ApiOperation({ summary: 'Atualiza perfil/progressão no tenant' })
  upsertProfile(
    @Param('gameId') gameId: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: UpsertProfileDto,
  ) {
    return this.gameData.upsertProfile(gameId, user.userId, dto);
  }

  @Post('events')
  @Version('1')
  @HttpCode(202)
  @ApiOperation({ summary: 'Ingestão idempotente de game events' })
  ingest(
    @Param('gameId') gameId: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: IngestGameEventDto,
  ) {
    return this.gameData.ingestEvent(gameId, user.userId, dto);
  }

  @Get('me/inventory')
  @Version('1')
  @ApiOperation({ summary: 'Inventário do jogador no tenant' })
  inventory(@Param('gameId') gameId: string, @CurrentUser() user: AuthUser) {
    return this.gameData.listInventory(gameId, user.userId);
  }

  @Put('me/inventory')
  @Version('1')
  @ApiOperation({ summary: 'Upsert de item de inventário' })
  upsertInventory(
    @Param('gameId') gameId: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: UpsertInventoryDto,
  ) {
    return this.gameData.upsertInventory(gameId, user.userId, dto);
  }
}
