import * as bcrypt from 'bcryptjs';
import { and, eq, sql } from 'drizzle-orm';
import type { NodePgDatabase } from 'drizzle-orm/node-postgres';
import * as schema from '../schema';

export type SeedDb = NodePgDatabase<typeof schema>;

export type SeedOptions = {
  solanaRpcUrl?: string;
  demoPassword?: string;
};

export type SeedResult = {
  games: {
    fallenTacticsId: string;
    forgeOfChampionsId: string;
    taskbarPlanetsForgerId: string;
    beatUpId: string;
  };
  users: { adminId: string; playerId: string };
  seeded: {
    games: boolean;
    networks: boolean;
    marketplace: boolean;
    users: boolean;
    releases: boolean;
    patches: boolean;
    memberships: boolean;
  };
};

const PLATFORM_GAMES = [
  {
    slug: 'fallen-tactics',
    name: 'Fallen Tactics',
    description:
      'Roguelike tático em grid: comande heróis, cada um com o próprio deck, e monte builds únicas a cada run.',
  },
  {
    slug: 'forge-of-champions',
    name: 'Forge of Champions',
    description:
      'Monte seu campeão em cinco slots e dispute duelos competitivos de 8 a 12 minutos.',
  },
  {
    slug: 'taskbar-planets-forger',
    name: 'Taskbar Planets Forger',
    description:
      'Companion idle na barra de tarefas: poeira cósmica vira planetas, vida e prestígio em supernova.',
  },
  {
    slug: 'beat-up',
    name: 'Beat Up',
    description:
      'Dirija por uma cidade isométrica, aceite entregas e acumule MutterCoins no ritmo 2.5D.',
  },
] as const;

const {
  blockchainNetworks,
  gameMemberships,
  gamePatches,
  gameReleases,
  games,
  marketplaceItems,
  users,
} = schema;

export async function seedDatabase(db: SeedDb, options: SeedOptions = {}): Promise<SeedResult> {
  const demoPassword = options.demoPassword ?? 'Str0ngP@ss!';
  const solanaRpcUrl = options.solanaRpcUrl ?? 'https://api.devnet.solana.com';
  const seeded = {
    games: false,
    networks: false,
    marketplace: false,
    users: false,
    releases: false,
    patches: false,
    memberships: false,
  };

  for (const game of PLATFORM_GAMES) {
    const [existing] = await db.select({ id: games.id }).from(games).where(eq(games.slug, game.slug)).limit(1);
    if (!existing) {
      await db.insert(games).values({ ...game, status: 'active' });
      seeded.games = true;
    } else {
      await db
        .update(games)
        .set({ name: game.name, description: game.description })
        .where(eq(games.slug, game.slug));
    }
  }

  const allGames = await db.select().from(games);
  const fallen = allGames.find((g) => g.slug === 'fallen-tactics');
  const forge = allGames.find((g) => g.slug === 'forge-of-champions');
  const taskbar = allGames.find((g) => g.slug === 'taskbar-planets-forger');
  const beatUp = allGames.find((g) => g.slug === 'beat-up');
  if (!fallen || !forge || !taskbar || !beatUp) {
    throw new Error('Required game tenants were not seeded');
  }

  const [{ networkCount }] = await db
    .select({ networkCount: sql<number>`count(*)::int` })
    .from(blockchainNetworks);
  if (!networkCount) {
    await db.insert(blockchainNetworks).values([
      {
        key: 'solana-devnet',
        name: 'Solana Devnet',
        cluster: 'devnet',
        rpcUrl: solanaRpcUrl,
        enabled: true,
      },
      {
        key: 'solana-mainnet',
        name: 'Solana Mainnet',
        cluster: 'mainnet-beta',
        rpcUrl: 'https://api.mainnet-beta.solana.com',
        enabled: false,
      },
    ]);
    seeded.networks = true;
  }

  const [{ itemCount }] = await db
    .select({ itemCount: sql<number>`count(*)::int` })
    .from(marketplaceItems);
  if (!itemCount) {
    await db.insert(marketplaceItems).values([
      {
        gameId: fallen.id,
        slug: 'genesis-tactician',
        name: 'Genesis Tactician',
        description: 'Skin de comandante da colecao Genesis.',
        assetType: 'skin',
        priceAtomic: 25_000_000,
        currencySymbol: 'USDC',
        supply: 500,
        sold: 72,
        status: 'active',
      },
      {
        gameId: beatUp.id,
        slug: 'forge-gloves',
        name: 'Forge Gloves',
        description: 'Luvas cosmeticas para Beat Up.',
        assetType: 'equipment',
        priceAtomic: 18_000_000,
        currencySymbol: 'USDC',
        supply: 750,
        sold: 188,
        status: 'active',
      },
      {
        gameId: fallen.id,
        slug: 'war-room-pass',
        name: 'War Room Pass',
        description: 'Passe sazonal do Fallen Tactics.',
        assetType: 'pass',
        priceAtomic: 9_900_000,
        currencySymbol: 'USDC',
        supply: 2000,
        sold: 410,
        status: 'active',
      },
    ]);
    seeded.marketplace = true;
  }

  const passwordHash = await bcrypt.hash(demoPassword, 12);
  const demoUsers = [
    {
      email: 'admin@muttergames.com',
      username: 'admin',
      displayName: 'Mutter Admin',
      passwordHash,
      status: 'active',
    },
    {
      email: 'player@muttergames.com',
      username: 'tactician',
      displayName: 'Tactician',
      passwordHash,
      status: 'active',
    },
  ];

  for (const user of demoUsers) {
    const [existing] = await db.select({ id: users.id }).from(users).where(eq(users.email, user.email)).limit(1);
    if (!existing) {
      await db.insert(users).values(user);
      seeded.users = true;
    }
  }

  const [admin] = await db.select().from(users).where(eq(users.email, 'admin@muttergames.com')).limit(1);
  const [player] = await db.select().from(users).where(eq(users.email, 'player@muttergames.com')).limit(1);
  if (!admin || !player) throw new Error('Demo users were not seeded');

  const memberships = [
    { gameId: fallen.id, userId: admin.id, role: 'admin' },
    { gameId: forge.id, userId: admin.id, role: 'admin' },
    { gameId: taskbar.id, userId: admin.id, role: 'admin' },
    { gameId: beatUp.id, userId: admin.id, role: 'admin' },
    { gameId: fallen.id, userId: player.id, role: 'player' },
    { gameId: forge.id, userId: player.id, role: 'player' },
    { gameId: taskbar.id, userId: player.id, role: 'player' },
    { gameId: beatUp.id, userId: player.id, role: 'player' },
  ];
  for (const membership of memberships) {
    const [existing] = await db
      .select({ id: gameMemberships.id })
      .from(gameMemberships)
      .where(
        and(
          eq(gameMemberships.gameId, membership.gameId),
          eq(gameMemberships.userId, membership.userId),
        ),
      )
      .limit(1);
    if (!existing) {
      await db.insert(gameMemberships).values(membership);
      seeded.memberships = true;
    }
  }

  const [{ releaseCount }] = await db
    .select({ releaseCount: sql<number>`count(*)::int` })
    .from(gameReleases);
  if (!releaseCount) {
    await db.insert(gameReleases).values([
      {
        gameId: fallen.id,
        platform: 'windows',
        channel: 'stable',
        version: '0.1.0',
        downloadUrl: 'https://cdn.muttergames.local/fallen-tactics/0.1.0/FallenTactics.zip',
        sha256: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        sizeBytes: 512_000_000,
        executablePath: 'FallenTactics.exe',
        releaseNotes: 'Primeira release seed do Fallen Tactics.',
        publishedAt: new Date('2026-08-01T12:00:00.000Z'),
      },
      {
        gameId: beatUp.id,
        platform: 'windows',
        channel: 'stable',
        version: '0.1.0',
        downloadUrl: 'https://cdn.muttergames.local/beat-up/0.1.0/BeatUp.zip',
        sha256: 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb',
        sizeBytes: 420_000_000,
        executablePath: 'BeatUp.exe',
        releaseNotes: 'Primeira release seed do Beat Up.',
        publishedAt: new Date('2026-08-01T12:00:00.000Z'),
      },
    ]);
    seeded.releases = true;
  }

  const [{ patchCount }] = await db.select({ patchCount: sql<number>`count(*)::int` }).from(gamePatches);
  if (!patchCount) {
    await db.insert(gamePatches).values([
      {
        gameId: fallen.id,
        platform: 'windows',
        channel: 'stable',
        fromVersion: '0.1.0',
        toVersion: '0.1.1',
        downloadUrl: 'https://cdn.muttergames.local/fallen-tactics/patches/0.1.0-0.1.1.zip',
        sha256: 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
        sizeBytes: 35_000_000,
        releaseNotes: 'Hotfix de balanceamento.',
        publishedAt: new Date('2026-08-03T12:00:00.000Z'),
      },
    ]);
    seeded.patches = true;
  }

  return {
    games: {
      fallenTacticsId: fallen.id,
      forgeOfChampionsId: forge.id,
      taskbarPlanetsForgerId: taskbar.id,
      beatUpId: beatUp.id,
    },
    users: { adminId: admin.id, playerId: player.id },
    seeded,
  };
}
