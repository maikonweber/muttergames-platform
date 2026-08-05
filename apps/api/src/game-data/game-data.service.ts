import { ConflictException, Inject, Injectable, NotFoundException } from '@nestjs/common';
import { and, eq } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.constants';
import type { DrizzleDb } from '../drizzle/drizzle.module';
import { gameEvents, gameProfiles, games, inventoryItems } from '../drizzle/schema';
import { SolanaFeatureService } from '../solana-feature/solana-feature.service';
import { IngestGameEventDto } from './dto/ingest-game-event.dto';
import { UpsertInventoryDto } from './dto/upsert-inventory.dto';
import { UpsertProfileDto } from './dto/upsert-profile.dto';

@Injectable()
export class GameDataService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDb,
    private readonly solanaFeature: SolanaFeatureService,
  ) {}

  private async resolveGame(gameIdOrSlug: string) {
    const isUuid = /^[0-9a-f-]{36}$/i.test(gameIdOrSlug);
    const [game] = await this.db
      .select()
      .from(games)
      .where(isUuid ? eq(games.id, gameIdOrSlug) : eq(games.slug, gameIdOrSlug))
      .limit(1);
    if (!game) throw new NotFoundException('Game not found');
    return game;
  }

  async getProfile(gameIdOrSlug: string, userId: string) {
    const game = await this.resolveGame(gameIdOrSlug);
    const [profile] = await this.db
      .select()
      .from(gameProfiles)
      .where(and(eq(gameProfiles.gameId, game.id), eq(gameProfiles.userId, userId)))
      .limit(1);
    return profile ?? { gameId: game.id, userId, data: {}, createdAt: null, updatedAt: null };
  }

  async upsertProfile(gameIdOrSlug: string, userId: string, dto: UpsertProfileDto) {
    const game = await this.resolveGame(gameIdOrSlug);
    const [row] = await this.db
      .insert(gameProfiles)
      .values({ gameId: game.id, userId, data: dto.data, updatedAt: new Date() })
      .onConflictDoUpdate({
        target: [gameProfiles.gameId, gameProfiles.userId],
        set: { data: dto.data, updatedAt: new Date() },
      })
      .returning();
    return row;
  }

  async ingestEvent(gameIdOrSlug: string, userId: string | null, dto: IngestGameEventDto) {
    const game = await this.resolveGame(gameIdOrSlug);
    const existing = await this.db
      .select()
      .from(gameEvents)
      .where(eq(gameEvents.idempotencyKey, dto.idempotencyKey))
      .limit(1);
    if (existing.length) {
      if (existing[0].eventId !== dto.eventId) {
        throw new ConflictException('Idempotency key reused with different event');
      }
      return existing[0];
    }

    try {
      const [row] = await this.db
        .insert(gameEvents)
        .values({
          gameId: game.id,
          userId,
          eventId: dto.eventId,
          type: dto.type,
          buildVersion: dto.buildVersion,
          occurredAt: dto.occurredAt,
          payload: dto.payload,
          payloadHash: dto.payloadHash,
          idempotencyKey: dto.idempotencyKey,
        })
        .returning();
      return row;
    } catch {
      throw new ConflictException('Event already ingested');
    }
  }

  async listInventory(gameIdOrSlug: string, userId: string) {
    const game = await this.resolveGame(gameIdOrSlug);
    return this.db
      .select()
      .from(inventoryItems)
      .where(and(eq(inventoryItems.gameId, game.id), eq(inventoryItems.userId, userId)));
  }

  async upsertInventory(gameIdOrSlug: string, userId: string, dto: UpsertInventoryDto) {
    this.solanaFeature.assertInventorySyncAllowed();
    const game = await this.resolveGame(gameIdOrSlug);
    const [row] = await this.db
      .insert(inventoryItems)
      .values({
        gameId: game.id,
        userId,
        sku: dto.sku,
        name: dto.name,
        quantity: dto.quantity,
        metadata: dto.metadata ?? {},
        updatedAt: new Date(),
      })
      .onConflictDoUpdate({
        target: [inventoryItems.gameId, inventoryItems.userId, inventoryItems.sku],
        set: {
          name: dto.name,
          quantity: dto.quantity,
          metadata: dto.metadata ?? {},
          updatedAt: new Date(),
        },
      })
      .returning();
    return row;
  }
}
