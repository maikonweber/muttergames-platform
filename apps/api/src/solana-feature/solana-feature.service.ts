import { ForbiddenException, Inject, Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { and, eq } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.constants';
import type { DrizzleDb } from '../drizzle/drizzle.module';
import {
  chainIntents,
  gameMemberships,
  games,
  inventoryItems,
  marketplaceItems,
  marketplaceOrders,
} from '../drizzle/schema';
import {
  capabilitiesForMode,
  descriptionForMode,
  parseSolanaFeatureMode,
  type SolanaFeatureMode,
  type SolanaFeatureStatus,
} from './solana-feature.types';

@Injectable()
export class SolanaFeatureService {
  constructor(
    private readonly config: ConfigService,
    @Inject(DRIZZLE) private readonly db: DrizzleDb,
  ) {}

  getMode(): SolanaFeatureMode {
    return parseSolanaFeatureMode(this.config.get<string>('SOLANA_FEATURE_MODE'));
  }

  getStatus(): SolanaFeatureStatus {
    const mode = this.getMode();
    return {
      mode,
      capabilities: capabilitiesForMode(mode),
      description: descriptionForMode(mode),
    };
  }

  assertWalletLinkAllowed() {
    if (!this.getStatus().capabilities.walletLink) {
      throw new ForbiddenException('Solana wallet link is disabled (SOLANA_FEATURE_MODE=off)');
    }
  }

  assertChainIntentsAllowed() {
    if (!this.getStatus().capabilities.chainIntents) {
      throw new ForbiddenException(
        `Solana chain intents require SOLANA_FEATURE_MODE=v2 (current: ${this.getMode()})`,
      );
    }
  }

  assertMarketplaceSettlementAllowed() {
    if (!this.getStatus().capabilities.marketplaceSettlement) {
      throw new ForbiddenException(
        `Marketplace settlement requires SOLANA_FEATURE_MODE=v2 (current: ${this.getMode()})`,
      );
    }
  }

  assertInventorySyncAllowed() {
    if (!this.getStatus().capabilities.inventorySync) {
      throw new ForbiddenException(
        `Inventory sync requires SOLANA_FEATURE_MODE=v2 (current: ${this.getMode()}). Use reset-equipment after the tester phase.`,
      );
    }
  }

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

  private async assertGameAdmin(gameId: string, userId: string) {
    const [membership] = await this.db
      .select()
      .from(gameMemberships)
      .where(and(eq(gameMemberships.gameId, gameId), eq(gameMemberships.userId, userId)))
      .limit(1);
    if (!membership || membership.role !== 'admin') {
      throw new ForbiddenException('Only game admins can reset equipment');
    }
  }

  /**
   * Reseta equipamentos/inventário do jogo, preservando users e wallet_links.
   * Também limpa pedidos de marketplace e chain intents do tenant.
   */
  async resetEquipment(gameIdOrSlug: string, userId: string) {
    const game = await this.resolveGame(gameIdOrSlug);
    await this.assertGameAdmin(game.id, userId);

    const deletedInventory = await this.db
      .delete(inventoryItems)
      .where(eq(inventoryItems.gameId, game.id))
      .returning({ id: inventoryItems.id });

    const deletedOrders = await this.db
      .delete(marketplaceOrders)
      .where(eq(marketplaceOrders.gameId, game.id))
      .returning({ id: marketplaceOrders.id });

    const deletedIntents = await this.db
      .delete(chainIntents)
      .where(eq(chainIntents.gameId, game.id))
      .returning({ id: chainIntents.id });

    await this.db
      .update(marketplaceItems)
      .set({ sold: 0, updatedAt: new Date() })
      .where(eq(marketplaceItems.gameId, game.id));

    return {
      gameId: game.id,
      gameSlug: game.slug,
      preserved: ['users', 'wallet_links', 'marketplace_catalog'],
      deleted: {
        inventoryItems: deletedInventory.length,
        marketplaceOrders: deletedOrders.length,
        chainIntents: deletedIntents.length,
      },
      marketplaceSoldReset: true,
      note: 'Users and wallet links were preserved. Equipment inventory was wiped.',
      at: new Date().toISOString(),
      mode: this.getMode(),
    };
  }

  async resetEquipmentAll(userId: string) {
    const adminMemberships = await this.db
      .select({ gameId: gameMemberships.gameId })
      .from(gameMemberships)
      .where(and(eq(gameMemberships.userId, userId), eq(gameMemberships.role, 'admin')));

    if (!adminMemberships.length) {
      throw new ForbiddenException('Only game admins can reset equipment');
    }

    const results = [];
    for (const row of adminMemberships) {
      results.push(await this.resetEquipment(row.gameId, userId));
    }

    return {
      games: results.length,
      results,
      preserved: ['users', 'wallet_links'],
    };
  }
}
