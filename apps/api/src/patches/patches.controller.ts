import { Body, Controller, Get, Param, Post, Query, UseGuards, Version } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { Public } from '../common/decorators/public.decorator';
import { TenantGuard } from '../common/guards/tenant.guard';
import { CreatePatchDto } from './dto/create-patch.dto';
import { CreateReleaseDto } from './dto/create-release.dto';
import { PatchesService } from './patches.service';

@ApiTags('patches')
@ApiBearerAuth()
@Controller('games/:gameId')
@UseGuards(TenantGuard)
export class PatchesController {
  constructor(private readonly patches: PatchesService) {}

  @Public()
  @Get('releases')
  @Version('1')
  @ApiQuery({ name: 'platform', required: false })
  @ApiQuery({ name: 'channel', required: false })
  @ApiOperation({ summary: 'Lista releases full do jogo' })
  listReleases(
    @Param('gameId') gameId: string,
    @Query('platform') platform = 'windows',
    @Query('channel') channel = 'stable',
  ) {
    return this.patches.listReleases(gameId, platform, channel);
  }

  @Post('releases')
  @Version('1')
  @ApiOperation({ summary: 'Publica release full' })
  createRelease(@Param('gameId') gameId: string, @Body() dto: CreateReleaseDto) {
    return this.patches.createRelease(gameId, dto);
  }

  @Public()
  @Get('patches')
  @Version('1')
  @ApiQuery({ name: 'from', required: true })
  @ApiQuery({ name: 'platform', required: false })
  @ApiQuery({ name: 'channel', required: false })
  @ApiOperation({ summary: 'Busca patch delta a partir de uma versão' })
  findPatch(
    @Param('gameId') gameId: string,
    @Query('from') from: string,
    @Query('platform') platform = 'windows',
    @Query('channel') channel = 'stable',
  ) {
    return this.patches.findPatch(gameId, from, platform, channel);
  }

  @Post('patches')
  @Version('1')
  @ApiOperation({ summary: 'Publica patch delta' })
  createPatch(@Param('gameId') gameId: string, @Body() dto: CreatePatchDto) {
    return this.patches.createPatch(gameId, dto);
  }
}
