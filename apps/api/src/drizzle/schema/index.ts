import {
  boolean,
  bigint,
  index,
  integer,
  jsonb,
  pgTable,
  text,
  timestamp,
  uniqueIndex,
  uuid,
} from 'drizzle-orm/pg-core';

export const users = pgTable(
  'users',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    email: text('email').notNull(),
    username: text('username').notNull(),
    displayName: text('display_name'),
    passwordHash: text('password_hash').notNull(),
    status: text('status').notNull().default('active'),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    uniqueIndex('users_email_uidx').on(t.email),
    uniqueIndex('users_username_uidx').on(t.username),
  ],
);

export const refreshTokens = pgTable(
  'refresh_tokens',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    userId: uuid('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' }),
    tokenHash: text('token_hash').notNull(),
    expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
    revokedAt: timestamp('revoked_at', { withTimezone: true }),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    uniqueIndex('refresh_tokens_hash_uidx').on(t.tokenHash),
    index('refresh_tokens_user_idx').on(t.userId),
  ],
);

export const games = pgTable(
  'games',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    slug: text('slug').notNull(),
    name: text('name').notNull(),
    description: text('description').notNull().default(''),
    status: text('status').notNull().default('active'),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [uniqueIndex('games_slug_uidx').on(t.slug)],
);

export const gameMemberships = pgTable(
  'game_memberships',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    gameId: uuid('game_id')
      .notNull()
      .references(() => games.id, { onDelete: 'cascade' }),
    userId: uuid('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' }),
    role: text('role').notNull().default('player'),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    uniqueIndex('game_memberships_game_user_uidx').on(t.gameId, t.userId),
    index('game_memberships_user_idx').on(t.userId),
  ],
);

export const walletChallenges = pgTable(
  'wallet_challenges',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    userId: uuid('user_id').references(() => users.id, { onDelete: 'set null' }),
    address: text('address').notNull(),
    chain: text('chain').notNull(),
    nonceHash: text('nonce_hash').notNull(),
    message: text('message').notNull(),
    expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
    consumedAt: timestamp('consumed_at', { withTimezone: true }),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [index('wallet_challenges_address_idx').on(t.address)],
);

export const walletLinks = pgTable(
  'wallet_links',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    userId: uuid('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' }),
    address: text('address').notNull(),
    chain: text('chain').notNull(),
    verifiedAt: timestamp('verified_at', { withTimezone: true }).defaultNow().notNull(),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    uniqueIndex('wallet_links_chain_address_uidx').on(t.chain, t.address),
    index('wallet_links_user_idx').on(t.userId),
  ],
);

/** Saldo off-chain de $MUTTER. A fonte de verdade para auditoria é o ledger abaixo. */
export const mutterCoinBalances = pgTable(
  'mutter_coin_balances',
  {
    userId: uuid('user_id')
      .primaryKey()
      .references(() => users.id, { onDelete: 'cascade' }),
    balanceAtomic: bigint('balance_atomic', { mode: 'bigint' }).notNull().default(0n),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  },
);

/** Lançamentos imutáveis: positivos creditam e negativos debitm MutterCoins. */
export const mutterCoinLedger = pgTable(
  'mutter_coin_ledger',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    userId: uuid('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' }),
    gameId: uuid('game_id').references(() => games.id, { onDelete: 'set null' }),
    amountAtomic: bigint('amount_atomic', { mode: 'bigint' }).notNull(),
    balanceAfterAtomic: bigint('balance_after_atomic', { mode: 'bigint' }).notNull(),
    kind: text('kind').notNull(),
    description: text('description').notNull(),
    idempotencyKey: text('idempotency_key').notNull(),
    metadata: jsonb('metadata').$type<Record<string, unknown>>().notNull().default({}),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    uniqueIndex('mutter_coin_ledger_idempotency_uidx').on(t.idempotencyKey),
    index('mutter_coin_ledger_user_created_idx').on(t.userId, t.createdAt),
    index('mutter_coin_ledger_game_idx').on(t.gameId),
  ],
);

export const marketplaceItems = pgTable(
  'marketplace_items',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    gameId: uuid('game_id')
      .notNull()
      .references(() => games.id, { onDelete: 'cascade' }),
    slug: text('slug').notNull(),
    name: text('name').notNull(),
    description: text('description').notNull(),
    assetType: text('asset_type').notNull(),
    priceAtomic: bigint('price_atomic', { mode: 'number' }).notNull(),
    currencySymbol: text('currency_symbol').notNull(),
    supply: integer('supply').notNull().default(0),
    sold: integer('sold').notNull().default(0),
    status: text('status').notNull().default('draft'),
    imageUrl: text('image_url'),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    uniqueIndex('marketplace_items_game_slug_uidx').on(t.gameId, t.slug),
    index('marketplace_items_game_status_idx').on(t.gameId, t.status),
  ],
);

export const marketplaceOrders = pgTable(
  'marketplace_orders',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    gameId: uuid('game_id')
      .notNull()
      .references(() => games.id, { onDelete: 'cascade' }),
    itemId: uuid('item_id')
      .notNull()
      .references(() => marketplaceItems.id, { onDelete: 'restrict' }),
    userId: uuid('user_id').references(() => users.id, { onDelete: 'set null' }),
    walletAddress: text('wallet_address').notNull(),
    quantity: integer('quantity').notNull(),
    totalAtomic: bigint('total_atomic', { mode: 'number' }).notNull(),
    currencySymbol: text('currency_symbol').notNull(),
    status: text('status').notNull().default('created'),
    idempotencyKey: text('idempotency_key').notNull(),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    uniqueIndex('marketplace_orders_idempotency_uidx').on(t.idempotencyKey),
    index('marketplace_orders_game_idx').on(t.gameId),
  ],
);

export const blockchainNetworks = pgTable(
  'blockchain_networks',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    key: text('key').notNull(),
    name: text('name').notNull(),
    cluster: text('cluster').notNull(),
    rpcUrl: text('rpc_url').notNull(),
    enabled: boolean('enabled').notNull().default(true),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [uniqueIndex('blockchain_networks_key_uidx').on(t.key)],
);

export const gameReleases = pgTable(
  'game_releases',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    gameId: uuid('game_id')
      .notNull()
      .references(() => games.id, { onDelete: 'cascade' }),
    platform: text('platform').notNull().default('windows'),
    channel: text('channel').notNull().default('stable'),
    version: text('version').notNull(),
    downloadUrl: text('download_url').notNull(),
    sha256: text('sha256').notNull(),
    sizeBytes: bigint('size_bytes', { mode: 'number' }),
    executablePath: text('executable_path').notNull(),
    releaseNotes: text('release_notes'),
    publishedAt: timestamp('published_at', { withTimezone: true }),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    uniqueIndex('game_releases_unique_uidx').on(t.gameId, t.platform, t.channel, t.version),
    index('game_releases_game_idx').on(t.gameId),
  ],
);

export const gamePatches = pgTable(
  'game_patches',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    gameId: uuid('game_id')
      .notNull()
      .references(() => games.id, { onDelete: 'cascade' }),
    platform: text('platform').notNull().default('windows'),
    channel: text('channel').notNull().default('stable'),
    fromVersion: text('from_version').notNull(),
    toVersion: text('to_version').notNull(),
    downloadUrl: text('download_url').notNull(),
    sha256: text('sha256').notNull(),
    sizeBytes: bigint('size_bytes', { mode: 'number' }),
    releaseNotes: text('release_notes'),
    publishedAt: timestamp('published_at', { withTimezone: true }),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    uniqueIndex('game_patches_unique_uidx').on(
      t.gameId,
      t.platform,
      t.channel,
      t.fromVersion,
      t.toVersion,
    ),
    index('game_patches_lookup_idx').on(t.gameId, t.fromVersion, t.channel),
  ],
);

export const gameProfiles = pgTable(
  'game_profiles',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    gameId: uuid('game_id')
      .notNull()
      .references(() => games.id, { onDelete: 'cascade' }),
    userId: uuid('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' }),
    data: jsonb('data').$type<Record<string, unknown>>().notNull().default({}),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [uniqueIndex('game_profiles_game_user_uidx').on(t.gameId, t.userId)],
);

export const gameEvents = pgTable(
  'game_events',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    gameId: uuid('game_id')
      .notNull()
      .references(() => games.id, { onDelete: 'cascade' }),
    userId: uuid('user_id').references(() => users.id, { onDelete: 'set null' }),
    eventId: uuid('event_id').notNull(),
    type: text('type').notNull(),
    buildVersion: text('build_version').notNull(),
    occurredAt: timestamp('occurred_at', { withTimezone: true }).notNull(),
    payload: jsonb('payload').$type<Record<string, unknown>>().notNull().default({}),
    payloadHash: text('payload_hash'),
    idempotencyKey: text('idempotency_key').notNull(),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    uniqueIndex('game_events_idempotency_uidx').on(t.idempotencyKey),
    uniqueIndex('game_events_event_id_uidx').on(t.eventId),
    index('game_events_game_type_idx').on(t.gameId, t.type),
  ],
);

export const inventoryItems = pgTable(
  'inventory_items',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    gameId: uuid('game_id')
      .notNull()
      .references(() => games.id, { onDelete: 'cascade' }),
    userId: uuid('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' }),
    sku: text('sku').notNull(),
    name: text('name').notNull(),
    quantity: integer('quantity').notNull().default(1),
    metadata: jsonb('metadata').$type<Record<string, unknown>>().notNull().default({}),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    uniqueIndex('inventory_items_unique_uidx').on(t.gameId, t.userId, t.sku),
    index('inventory_items_user_idx').on(t.userId),
  ],
);

export const chainIntents = pgTable(
  'chain_intents',
  {
    id: uuid('id').defaultRandom().primaryKey(),
    gameId: uuid('game_id').references(() => games.id, { onDelete: 'set null' }),
    userId: uuid('user_id').references(() => users.id, { onDelete: 'set null' }),
    kind: text('kind').notNull(),
    status: text('status').notNull().default('pending'),
    walletAddress: text('wallet_address').notNull(),
    networkKey: text('network_key').notNull().default('solana-devnet'),
    payload: jsonb('payload').$type<Record<string, unknown>>().notNull().default({}),
    txSignature: text('tx_signature'),
    expiresAt: timestamp('expires_at', { withTimezone: true }),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (t) => [
    index('chain_intents_user_idx').on(t.userId),
    index('chain_intents_tx_idx').on(t.txSignature),
  ],
);
