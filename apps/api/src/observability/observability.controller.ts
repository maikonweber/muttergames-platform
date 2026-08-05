import { Controller, Get, Header, Version } from '@nestjs/common';
import { ApiExcludeEndpoint } from '@nestjs/swagger';
import { Public } from '../common/decorators/public.decorator';
import { MetricsService } from './metrics.service';

@Controller()
export class ObservabilityController {
  constructor(private readonly metrics: MetricsService) {}

  @Public()
  @Get('metrics')
  @Version('1')
  @Header('Content-Type', 'text/plain; version=0.0.4')
  @ApiExcludeEndpoint()
  metricsText(): Promise<string> {
    return this.metrics.registry.metrics();
  }
}
