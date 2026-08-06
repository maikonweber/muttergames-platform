import { ConflictException, Inject, Injectable } from '@nestjs/common';
import { desc, eq } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.constants';
import type { DrizzleDb } from '../drizzle/drizzle.module';
import { games, mutterCoinBalances, mutterCoinLedger } from '../drizzle/schema';

type Entry = {
  userId: string;
  amountAtomic: bigint;
  kind: string;
  description: string;
  idempotencyKey: string;
  gameId?: string;
  metadata?: Record<string, unknown>;
};

@Injectable()
export class MutterCoinsService {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDb) {}

  async summary(userId: string) {
    const [balance] = await this.db.select().from(mutterCoinBalances).where(eq(mutterCoinBalances.userId, userId));
    const transactions = await this.db
      .select()
      .from(mutterCoinLedger)
      .where(eq(mutterCoinLedger.userId, userId))
      .orderBy(desc(mutterCoinLedger.createdAt))
      .limit(20);
    return { symbol: 'MUTTER', decimals: 9, balanceAtomic: balance?.balanceAtomic ?? 0n, transactions };
  }

  async spend(userId: string, amountAtomic: string, description: string, idempotencyKey: string, metadata?: Record<string, unknown>) {
    const amount = BigInt(amountAtomic);
    if (amount <= 0n) throw new ConflictException('Amount must be positive');
    return this.record({ userId, amountAtomic: -amount, kind: 'spend', description, idempotencyKey, metadata });
  }

  /** Uso exclusivo de resultado validado no servidor; nunca chame a partir de um cliente de jogo. */
  creditVerifiedReward(entry: Entry) {
    if (entry.amountAtomic <= 0n) throw new ConflictException('Reward must be positive');
    return this.record({ ...entry, kind: entry.kind || 'game_reward' });
  }

  async creditVerifiedGameReward(entry: Entry & { gameId: string }) {
    const isUuid = /^[0-9a-f-]{36}$/i.test(entry.gameId);
    const [game] = await this.db.select().from(games).where(isUuid ? eq(games.id, entry.gameId) : eq(games.slug, entry.gameId)).limit(1);
    if (!game) throw new ConflictException('Game not found');
    return this.creditVerifiedReward({ ...entry, gameId: game.id });
  }

  private async record(entry: Entry) {
    const existing = await this.db.select().from(mutterCoinLedger).where(eq(mutterCoinLedger.idempotencyKey, entry.idempotencyKey)).limit(1);
    if (existing.length) return existing[0];

    return this.db.transaction(async (tx) => {
      const duplicate = await tx.select().from(mutterCoinLedger).where(eq(mutterCoinLedger.idempotencyKey, entry.idempotencyKey)).limit(1);
      if (duplicate.length) return duplicate[0];
      await tx.insert(mutterCoinBalances).values({ userId: entry.userId, balanceAtomic: 0n }).onConflictDoNothing();
      const [balance] = await tx.select().from(mutterCoinBalances).where(eq(mutterCoinBalances.userId, entry.userId)).for('update');
      const next = balance.balanceAtomic + entry.amountAtomic;
      if (next < 0n) throw new ConflictException('Insufficient MutterCoins balance');
      await tx.update(mutterCoinBalances).set({ balanceAtomic: next, updatedAt: new Date() }).where(eq(mutterCoinBalances.userId, entry.userId));
      const [row] = await tx.insert(mutterCoinLedger).values({ ...entry, balanceAfterAtomic: next, metadata: entry.metadata ?? {} }).returning();
      return row;
    });
  }
}
