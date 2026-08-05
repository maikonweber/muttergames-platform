import {
  BadRequestException,
  ConflictException,
  Inject,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import * as ed25519 from '@noble/ed25519';
import { sha512 } from '@noble/hashes/sha2.js';
import bs58 from 'bs58';

ed25519.hashes.sha512 = sha512;
import { createHash, randomBytes } from 'node:crypto';
import { and, eq, isNull } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.constants';
import type { DrizzleDb } from '../drizzle/drizzle.module';
import { walletChallenges, walletLinks } from '../drizzle/schema';
import { SolanaFeatureService } from '../solana-feature/solana-feature.service';
import { CreateWalletChallengeDto } from './dto/create-wallet-challenge.dto';
import { VerifyWalletChallengeDto } from './dto/verify-wallet-challenge.dto';

@Injectable()
export class WalletsService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDb,
    private readonly solanaFeature: SolanaFeatureService,
  ) {}

  async createChallenge(dto: CreateWalletChallengeDto, userId?: string) {
    this.solanaFeature.assertWalletLinkAllowed();
    const nonce = randomBytes(16).toString('base64url');
    const issuedAt = new Date();
    const expiresAt = new Date(issuedAt.getTime() + 5 * 60_000);
    const message = [
      'MutterGames Wallet Link',
      'Version: 1',
      'Domain: localhost:3000',
      'URI: http://localhost:3000/account/wallets',
      `Chain: ${dto.chain}`,
      `Address: ${dto.address}`,
      `Nonce: ${nonce}`,
      `Issued At: ${issuedAt.toISOString()}`,
      `Expiration Time: ${expiresAt.toISOString()}`,
      'Statement: Esta assinatura nao movimenta fundos.',
    ].join('\n');

    const [entity] = await this.db
      .insert(walletChallenges)
      .values({
        userId: userId ?? dto.userId,
        address: dto.address,
        chain: dto.chain,
        nonceHash: createHash('sha256').update(nonce).digest('hex'),
        message,
        expiresAt,
      })
      .returning();

    return { challengeId: entity.id, message, expiresAt, algorithm: 'ed25519' };
  }

  async verify(dto: VerifyWalletChallengeDto, userId: string) {
    this.solanaFeature.assertWalletLinkAllowed();
    const [challenge] = await this.db
      .select()
      .from(walletChallenges)
      .where(and(eq(walletChallenges.id, dto.challengeId), isNull(walletChallenges.consumedAt)))
      .limit(1);
    if (!challenge) throw new NotFoundException('Challenge not found or already used');
    if (challenge.expiresAt.getTime() < Date.now()) {
      throw new BadRequestException('Challenge expired');
    }

    let signatureBytes: Uint8Array;
    let publicKeyBytes: Uint8Array;
    try {
      signatureBytes = bs58.decode(dto.signature);
      publicKeyBytes = bs58.decode(challenge.address);
    } catch {
      throw new BadRequestException('Invalid base58 signature or address');
    }

    const messageBytes = new TextEncoder().encode(challenge.message);
    const valid = await ed25519.verifyAsync(signatureBytes, messageBytes, publicKeyBytes);
    if (!valid) throw new UnauthorizedException('Invalid wallet signature');

    await this.db
      .update(walletChallenges)
      .set({ consumedAt: new Date(), userId })
      .where(eq(walletChallenges.id, challenge.id));

    try {
      const [link] = await this.db
        .insert(walletLinks)
        .values({
          userId,
          address: challenge.address,
          chain: challenge.chain,
          verifiedAt: new Date(),
        })
        .returning();
      return link;
    } catch {
      throw new ConflictException('Wallet already linked to another account');
    }
  }

  listLinks(userId: string) {
    return this.db.select().from(walletLinks).where(eq(walletLinks.userId, userId));
  }
}
