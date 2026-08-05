import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { eq } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.constants';
import type { DrizzleDb } from '../drizzle/drizzle.module';
import { chainIntents } from '../drizzle/schema';
import { SolanaFeatureService } from '../solana-feature/solana-feature.service';
import { ConfirmChainIntentDto } from './dto/confirm-chain-intent.dto';
import { CreateChainIntentDto } from './dto/create-chain-intent.dto';

@Injectable()
export class ChainService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDb,
    private readonly solanaFeature: SolanaFeatureService,
  ) {}

  async createIntent(userId: string, dto: CreateChainIntentDto) {
    this.solanaFeature.assertChainIntentsAllowed();
    const expiresAt = new Date(Date.now() + 10 * 60_000);
    const [row] = await this.db
      .insert(chainIntents)
      .values({
        userId,
        gameId: dto.gameId,
        kind: dto.kind,
        status: 'pending',
        walletAddress: dto.walletAddress,
        networkKey: dto.networkKey ?? 'solana-devnet',
        payload: dto.payload,
        expiresAt,
      })
      .returning();
    return {
      ...row,
      quote: {
        expiresAt,
        note: 'Assine e envie a transação on-chain; confirme com POST /chain/intents/:id/confirm',
      },
    };
  }

  async getIntent(id: string) {
    const [row] = await this.db.select().from(chainIntents).where(eq(chainIntents.id, id)).limit(1);
    if (!row) throw new NotFoundException('Chain intent not found');
    return row;
  }

  async confirm(id: string, dto: ConfirmChainIntentDto) {
    this.solanaFeature.assertChainIntentsAllowed();
    const intent = await this.getIntent(id);
    if (intent.status !== 'pending') return intent;
    const [row] = await this.db
      .update(chainIntents)
      .set({
        status: 'submitted',
        txSignature: dto.txSignature,
        updatedAt: new Date(),
      })
      .where(eq(chainIntents.id, id))
      .returning();
    return row;
  }

  async byTx(signature: string) {
    const [row] = await this.db
      .select()
      .from(chainIntents)
      .where(eq(chainIntents.txSignature, signature))
      .limit(1);
    if (!row) throw new NotFoundException('Transaction not found');
    return row;
  }
}
