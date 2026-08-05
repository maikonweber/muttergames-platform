import {
  BadRequestException,
  CanActivate,
  ExecutionContext,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Inject } from '@nestjs/common';
import { eq } from 'drizzle-orm';
import { DRIZZLE } from '../../drizzle/drizzle.constants';
import type { DrizzleDb } from '../../drizzle/drizzle.module';
import { games } from '../../drizzle/schema';

@Injectable()
export class TenantGuard implements CanActivate {
  constructor(@Inject(DRIZZLE) private readonly db: DrizzleDb) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<{
      params: { gameId?: string; slug?: string };
      headers: Record<string, string | undefined>;
      gameId?: string;
      game?: typeof games.$inferSelect;
    }>();

    const raw =
      request.params.gameId ??
      request.headers['x-game-id'] ??
      request.params.slug;

    if (!raw) throw new BadRequestException('gameId is required (path or X-Game-Id header)');

    const isUuid = /^[0-9a-f-]{36}$/i.test(raw);
    const [game] = await this.db
      .select()
      .from(games)
      .where(isUuid ? eq(games.id, raw) : eq(games.slug, raw))
      .limit(1);

    if (!game) throw new NotFoundException('Game tenant not found');
    request.gameId = game.id;
    request.game = game;
    return true;
  }
}
