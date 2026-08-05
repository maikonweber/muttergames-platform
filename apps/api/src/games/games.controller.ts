import { Body, Controller, Get, Param, Post, UseGuards, Version } from '@nestjs/common';
import { ApiBearerAuth, ApiHeader, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Public } from '../common/decorators/public.decorator';
import { TenantGuard } from '../common/guards/tenant.guard';
import { CreateGameDto } from './dto/create-game.dto';
import { CreateMembershipDto } from './dto/create-membership.dto';
import { GamesService } from './games.service';

@ApiTags('games')
@ApiBearerAuth()
@Controller('games')
export class GamesController {
  constructor(private readonly games: GamesService) {}

  @Public()
  @Get()
  @Version('1')
  @ApiOperation({ summary: 'Lista tenants/jogos' })
  list() {
    return this.games.list();
  }

  @Public()
  @Get(':gameId')
  @Version('1')
  @ApiOperation({ summary: 'Detalhe do jogo por id ou slug' })
  one(@Param('gameId') gameId: string) {
    return this.games.findBySlugOrId(gameId);
  }

  @Post()
  @Version('1')
  @ApiOperation({ summary: 'Cria um novo tenant/jogo' })
  create(@Body() dto: CreateGameDto) {
    return this.games.create(dto);
  }

  @Post(':gameId/memberships')
  @Version('1')
  @UseGuards(TenantGuard)
  @ApiHeader({ name: 'X-Game-Id', required: false })
  @ApiOperation({ summary: 'Adiciona membership ao tenant' })
  addMembership(@Param('gameId') gameId: string, @Body() dto: CreateMembershipDto) {
    return this.games.addMembership(gameId, dto);
  }

  @Get(':gameId/memberships')
  @Version('1')
  @UseGuards(TenantGuard)
  @ApiOperation({ summary: 'Lista memberships do tenant' })
  listMemberships(@Param('gameId') gameId: string) {
    return this.games.listMemberships(gameId);
  }
}
