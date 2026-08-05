import { ConflictException, Inject, Injectable, NotFoundException } from '@nestjs/common';
import { and, desc, eq } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.constants';
import type { DrizzleDb } from '../drizzle/drizzle.module';
import { gamePatches, gameReleases, games } from '../drizzle/schema';
import { CreatePatchDto } from './dto/create-patch.dto';
import { CreateReleaseDto } from './dto/create-release.dto';

@Injectable()
export class PatchesService {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDb) {}

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

  async listReleases(gameIdOrSlug: string, platform = 'windows', channel = 'stable') {
    const game = await this.resolveGame(gameIdOrSlug);
    return this.db
      .select()
      .from(gameReleases)
      .where(
        and(
          eq(gameReleases.gameId, game.id),
          eq(gameReleases.platform, platform),
          eq(gameReleases.channel, channel),
        ),
      )
      .orderBy(desc(gameReleases.publishedAt));
  }

  async createRelease(gameIdOrSlug: string, dto: CreateReleaseDto) {
    const game = await this.resolveGame(gameIdOrSlug);
    try {
      const [row] = await this.db
        .insert(gameReleases)
        .values({
          gameId: game.id,
          platform: dto.platform,
          channel: dto.channel,
          version: dto.version,
          downloadUrl: dto.downloadUrl,
          sha256: dto.sha256.toLowerCase(),
          sizeBytes: dto.sizeBytes,
          executablePath: dto.executablePath,
          releaseNotes: dto.releaseNotes,
          publishedAt: new Date(),
        })
        .returning();
      return row;
    } catch {
      throw new ConflictException('Release already exists for this version/channel');
    }
  }

  async findPatch(
    gameIdOrSlug: string,
    fromVersion: string,
    platform = 'windows',
    channel = 'stable',
  ) {
    const game = await this.resolveGame(gameIdOrSlug);
    const [patch] = await this.db
      .select()
      .from(gamePatches)
      .where(
        and(
          eq(gamePatches.gameId, game.id),
          eq(gamePatches.fromVersion, fromVersion),
          eq(gamePatches.platform, platform),
          eq(gamePatches.channel, channel),
        ),
      )
      .limit(1);
    if (!patch) throw new NotFoundException('Patch not found');
    return patch;
  }

  async createPatch(gameIdOrSlug: string, dto: CreatePatchDto) {
    const game = await this.resolveGame(gameIdOrSlug);
    try {
      const [row] = await this.db
        .insert(gamePatches)
        .values({
          gameId: game.id,
          platform: dto.platform,
          channel: dto.channel,
          fromVersion: dto.fromVersion,
          toVersion: dto.toVersion,
          downloadUrl: dto.downloadUrl,
          sha256: dto.sha256.toLowerCase(),
          sizeBytes: dto.sizeBytes,
          releaseNotes: dto.releaseNotes,
          publishedAt: new Date(),
        })
        .returning();
      return row;
    } catch {
      throw new ConflictException('Patch already exists for this version range');
    }
  }
}
