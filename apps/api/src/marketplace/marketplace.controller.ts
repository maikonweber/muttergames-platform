import { Body, Controller, Get, Param, Post, Query, Version } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { CurrentUser, type AuthUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { CreateMarketplaceItemDto } from './dto/create-item.dto';
import { CreateOrderDto } from './dto/create-order.dto';
import { MarketplaceService } from './marketplace.service';

@ApiTags('marketplace')
@Controller('marketplace')
export class MarketplaceController {
  constructor(private readonly service: MarketplaceService) {}

  @Public()
  @Get('items')
  @Version('1')
  @ApiQuery({ name: 'gameId', required: false, description: 'Filtra por tenant (uuid ou slug)' })
  @ApiOperation({ summary: 'Lista itens ativos' })
  list(@Query('gameId') gameId?: string) {
    return this.service.findActive(gameId);
  }

  @Public()
  @Get('items/:id')
  @Version('1')
  item(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Post('items')
  @Version('1')
  @ApiBearerAuth()
  createItem(@Body() dto: CreateMarketplaceItemDto) {
    return this.service.createItem(dto);
  }

  @Post('orders')
  @Version('1')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Cria uma ordem idempotente' })
  createOrder(@CurrentUser() user: AuthUser, @Body() dto: CreateOrderDto) {
    return this.service.createOrder(dto, user.userId);
  }
}
