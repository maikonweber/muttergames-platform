import { ConflictException, Inject, Injectable, NotFoundException } from '@nestjs/common';
import { asc, eq } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.constants';
import type { DrizzleDb } from '../drizzle/drizzle.module';
import { gameMemberships, games } from '../drizzle/schema';
import { CreateGameDto } from './dto/create-game.dto';
import { CreateMembershipDto } from './dto/create-membership.dto';

@Injectable()
export class GamesService {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDb) {}

  list() {
    return this.db.select().from(games).orderBy(asc(games.name));
  }

  async findBySlugOrId(idOrSlug: string) {
    const isUuid = /^[0-9a-f-]{36}$/i.test(idOrSlug);
    const [game] = await this.db
      .select()
      .from(games)
      .where(isUuid ? eq(games.id, idOrSlug) : eq(games.slug, idOrSlug))
      .limit(1);
    if (!game) throw new NotFoundException('Game not found');
    return game;
  }

  async create(dto: CreateGameDto) {
    try {
      const [game] = await this.db
        .insert(games)
        .values({
          slug: dto.slug,
          name: dto.name,
          description: dto.description ?? '',
          status: dto.status ?? 'active',
        })
        .returning();
      return game;
    } catch {
      throw new ConflictException('Game slug already exists');
    }
  }

  async addMembership(gameId: string, dto: CreateMembershipDto) {
    const game = await this.findBySlugOrId(gameId);
    try {
      const [row] = await this.db
        .insert(gameMemberships)
        .values({ gameId: game.id, userId: dto.userId, role: dto.role })
        .returning();
      return row;
    } catch {
      throw new ConflictException('Membership already exists');
    }
  }

  async listMemberships(gameId: string) {
    const game = await this.findBySlugOrId(gameId);
    return this.db.select().from(gameMemberships).where(eq(gameMemberships.gameId, game.id));
  }
}
