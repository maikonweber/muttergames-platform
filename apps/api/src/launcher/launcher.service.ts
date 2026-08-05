import { BadRequestException, Inject, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { and, desc, eq } from 'drizzle-orm';
import { DRIZZLE } from '../drizzle/drizzle.constants';
import type { DrizzleDb } from '../drizzle/drizzle.module';
import { gameReleases, games } from '../drizzle/schema';

@Injectable()
export class LauncherService {
  constructor(
    @Inject(DRIZZLE) private readonly db: DrizzleDb,
    private readonly config: ConfigService,
  ) {}

  async catalog(platform: string) {
    if (platform !== 'windows') {
      throw new BadRequestException('Only the windows catalog is currently available');
    }

    const allGames = await this.db.select().from(games).where(eq(games.status, 'active'));
    const gameEntries = await Promise.all(
      allGames.map(async (game) => {
        const [release] = await this.db
          .select()
          .from(gameReleases)
          .where(
            and(
              eq(gameReleases.gameId, game.id),
              eq(gameReleases.platform, platform),
              eq(gameReleases.channel, 'stable'),
            ),
          )
          .orderBy(desc(gameReleases.publishedAt))
          .limit(1);

        if (release) {
          return {
            id: game.slug,
            name: game.name,
            description: game.description,
            status: 'available' as const,
            release: {
              version: release.version,
              downloadUrl: release.downloadUrl,
              sha256: release.sha256,
              sizeBytes: release.sizeBytes,
              executablePath: release.executablePath,
              publishedAt: release.publishedAt?.toISOString() ?? null,
              notes: release.releaseNotes ?? '',
            },
          };
        }

        return this.envFallback(game.slug, game.name, game.description);
      }),
    );

    if (!gameEntries.length) {
      gameEntries.push(
        this.envFallback(
          'fallen-tactics',
          'Fallen Tactics',
          'Roguelike tático em grid: comande heróis, cada um com o próprio deck, e monte builds únicas a cada run.',
        ),
        this.envFallback(
          'forge-of-champions',
          'Forge of Champions',
          'Monte seu campeão em cinco slots e dispute duelos competitivos de 8 a 12 minutos.',
        ),
        this.envFallback(
          'taskbar-planets-forger',
          'Taskbar Planets Forger',
          'Companion idle na barra de tarefas: poeira cósmica vira planetas, vida e prestígio em supernova.',
        ),
        this.envFallback(
          'beat-up',
          'Beat Up',
          'Dirija por uma cidade isométrica, aceite entregas e acumule MutterCoins no ritmo 2.5D.',
        ),
      );
    }

    return {
      schemaVersion: 1,
      platform,
      launcher: {
        latestVersion: this.config.get('LAUNCHER_VERSION', '0.1.0'),
        downloadUrl: this.config.get<string>('LAUNCHER_DOWNLOAD_URL') ?? null,
      },
      games: gameEntries,
    };
  }

  private envFallback(id: string, name: string, description: string) {
    const key =
      id === 'fallen-tactics' ? 'FALLEN_TACTICS' : id === 'beat-up' ? 'BEAT_UP' : id.toUpperCase().replace(/-/g, '_');
    const downloadUrl = this.config.get<string>(`${key}_DOWNLOAD_URL`) ?? null;
    const executablePath = this.config.get<string>(`${key}_EXECUTABLE_PATH`) ?? null;
    const sha256 = this.config.get<string>(`${key}_SHA256`) ?? null;
    const available = Boolean(downloadUrl && executablePath && sha256);
    return {
      id,
      name,
      description,
      status: available ? ('available' as const) : ('coming_soon' as const),
      release: {
        version: this.config.get(`${key}_VERSION`, '0.1.0'),
        downloadUrl: available ? downloadUrl : null,
        sha256: available ? sha256 : null,
        sizeBytes: available ? Number(this.config.get(`${key}_SIZE_BYTES`, 0)) || null : null,
        executablePath: available ? executablePath : null,
        publishedAt: available ? this.config.get<string>(`${key}_PUBLISHED_AT`) ?? null : null,
        notes: this.config.get(`${key}_RELEASE_NOTES`, 'Primeira release do launcher.'),
      },
    };
  }
}
