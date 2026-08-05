import {
  ConflictException,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { and, desc, eq } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.constants';
import type { DrizzleDb } from '../drizzle/drizzle.module';
import { games, marketplaceItems, marketplaceOrders } from '../drizzle/schema';
import { SolanaFeatureService } from '../solana-feature/solana-feature.service';
import { CreateMarketplaceItemDto } from './dto/create-item.dto';
import { CreateOrderDto } from './dto/create-order.dto';

@Injectable()
export class MarketplaceService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDb,
    private readonly solanaFeature: SolanaFeatureService,
  ) {}

  private async resolveGame(idOrSlug: string) {
    const isUuid = /^[0-9a-f-]{36}$/i.test(idOrSlug);
    const [game] = await this.db
      .select()
      .from(games)
      .where(isUuid ? eq(games.id, idOrSlug) : eq(games.slug, idOrSlug))
      .limit(1);
    if (!game) throw new NotFoundException('Game tenant not found');
    return game;
  }

  findActive(gameIdOrSlug?: string) {
    if (!gameIdOrSlug) {
      return this.db
        .select()
        .from(marketplaceItems)
        .where(eq(marketplaceItems.status, 'active'))
        .orderBy(desc(marketplaceItems.createdAt));
    }
    return this.resolveGame(gameIdOrSlug).then((game) =>
      this.db
        .select()
        .from(marketplaceItems)
        .where(and(eq(marketplaceItems.status, 'active'), eq(marketplaceItems.gameId, game.id)))
        .orderBy(desc(marketplaceItems.createdAt)),
    );
  }

  async findOne(id: string) {
    const [item] = await this.db
      .select()
      .from(marketplaceItems)
      .where(eq(marketplaceItems.id, id))
      .limit(1);
    if (!item) throw new NotFoundException('Marketplace item not found');
    return item;
  }

  async createItem(dto: CreateMarketplaceItemDto) {
    const game = await this.resolveGame(dto.gameId);
    const [item] = await this.db
      .insert(marketplaceItems)
      .values({
        gameId: game.id,
        slug: dto.slug,
        name: dto.name,
        description: dto.description,
        assetType: dto.assetType,
        priceAtomic: Number(dto.priceAtomic),
        currencySymbol: dto.currencySymbol,
        supply: dto.supply,
        sold: 0,
        status: 'active',
        imageUrl: dto.imageUrl,
      })
      .returning();
    return item;
  }

  async createOrder(dto: CreateOrderDto, userId?: string) {
    this.solanaFeature.assertMarketplaceSettlementAllowed();
    const [existing] = await this.db
      .select()
      .from(marketplaceOrders)
      .where(eq(marketplaceOrders.idempotencyKey, dto.idempotencyKey))
      .limit(1);
    if (existing) return existing;

    return this.db.transaction(async (tx: DrizzleDb) => {
      const [item] = await tx
        .select()
        .from(marketplaceItems)
        .where(eq(marketplaceItems.id, dto.itemId))
        .for('update')
        .limit(1);

      if (!item || item.status !== 'active') throw new NotFoundException('Active item not found');
      if (item.sold + dto.quantity > item.supply) throw new ConflictException('Insufficient supply');

      await tx
        .update(marketplaceItems)
        .set({ sold: item.sold + dto.quantity, updatedAt: new Date() })
        .where(eq(marketplaceItems.id, item.id));

      const [order] = await tx
        .insert(marketplaceOrders)
        .values({
          gameId: item.gameId,
          itemId: item.id,
          userId,
          walletAddress: dto.walletAddress,
          quantity: dto.quantity,
          totalAtomic: item.priceAtomic * dto.quantity,
          currencySymbol: item.currencySymbol,
          status: 'created',
          idempotencyKey: dto.idempotencyKey,
        })
        .returning();
      return order;
    });
  }
}
