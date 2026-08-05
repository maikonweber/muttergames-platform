import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { asc, eq } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.constants';
import type { DrizzleDb } from '../drizzle/drizzle.module';
import { blockchainNetworks } from '../drizzle/schema';
import { CreateNetworkDto } from './dto/create-network.dto';

type NetworkStatus = {
  key: string;
  cluster: string;
  enabled: boolean;
  status: 'online' | 'degraded' | 'disabled';
};

@Injectable()
export class BlockchainService {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDb) {}

  findAll() {
    return this.db.select().from(blockchainNetworks).orderBy(asc(blockchainNetworks.name));
  }

  async findOne(key: string) {
    const [network] = await this.db
      .select()
      .from(blockchainNetworks)
      .where(eq(blockchainNetworks.key, key))
      .limit(1);
    if (!network) throw new NotFoundException('Blockchain network not found');
    return network;
  }

  async create(dto: CreateNetworkDto) {
    const [row] = await this.db
      .insert(blockchainNetworks)
      .values({
        key: dto.key,
        name: dto.name,
        cluster: dto.cluster,
        rpcUrl: dto.rpcUrl,
        enabled: dto.enabled ?? true,
      })
      .returning();
    return row;
  }

  async getStatus(key: string): Promise<NetworkStatus> {
    const network = await this.findOne(key);
    if (!network.enabled) {
      return { key, cluster: network.cluster, enabled: false, status: 'disabled' };
    }

    try {
      const response = await fetch(network.rpcUrl, {
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ jsonrpc: '2.0', id: 1, method: 'getHealth' }),
        signal: AbortSignal.timeout(2_500),
      });
      const body = (await response.json()) as { result?: string };
      const status = response.ok && body.result === 'ok' ? 'online' : 'degraded';
      return { key, cluster: network.cluster, enabled: true, status };
    } catch {
      return { key, cluster: network.cluster, enabled: true, status: 'degraded' };
    }
  }
}
