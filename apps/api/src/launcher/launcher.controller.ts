import { Controller, Get, Query, Version } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { Public } from '../common/decorators/public.decorator';
import { LauncherService } from './launcher.service';

@ApiTags('launcher')
@Controller('launcher')
export class LauncherController {
  constructor(private readonly launcher: LauncherService) {}

  @Public()
  @Get('catalog')
  @Version('1')
  @ApiOperation({ summary: 'Catálogo de releases consumido pelo site e pelo launcher Windows' })
  catalog(@Query('platform') platform = 'windows') {
    return this.launcher.catalog(platform);
  }
}
