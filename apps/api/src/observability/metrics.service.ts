import { Injectable } from '@nestjs/common';
import { Counter, Histogram, Registry, collectDefaultMetrics } from 'prom-client';

@Injectable()
export class MetricsService {
  readonly registry = new Registry();
  readonly requests = new Counter({ name: 'muttergames_http_requests_total', help: 'Total de requisições HTTP', labelNames: ['method', 'route', 'status'], registers: [this.registry] });
  readonly duration = new Histogram({ name: 'muttergames_http_request_duration_seconds', help: 'Duração HTTP em segundos', labelNames: ['method', 'route', 'status'], buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5], registers: [this.registry] });
  constructor() { collectDefaultMetrics({ register: this.registry, prefix: 'muttergames_' }); }
}
