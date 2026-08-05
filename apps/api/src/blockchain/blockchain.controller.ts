import { Body, Controller, Get, Param, Post, Version } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { Public } from '../common/decorators/public.decorator';
import { BlockchainService } from './blockchain.service';
import { CreateNetworkDto } from './dto/create-network.dto';

@ApiTags('blockchain')
@Controller('blockchain')
export class BlockchainController {
  constructor(private readonly service: BlockchainService) {}

  @Public()
  @Get('networks')
  @Version('1')
  @ApiOperation({ summary: 'Lista redes blockchain configuradas' })
  list() {
    return this.service.findAll();
  }

  @Public()
  @Get('networks/:key/status')
  @Version('1')
  @ApiOperation({ summary: 'Retorna o estado da integração da rede' })
  status(@Param('key') key: string) {
    return this.service.getStatus(key);
  }

  @Post('networks')
  @Version('1')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Registra uma rede blockchain' })
  create(@Body() dto: CreateNetworkDto) {
    return this.service.create(dto);
  }
}
