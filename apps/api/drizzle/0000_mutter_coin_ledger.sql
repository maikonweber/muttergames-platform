CREATE TABLE IF NOT EXISTS "mutter_coin_balances" (
  "user_id" uuid PRIMARY KEY NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
  "balance_atomic" bigint NOT NULL DEFAULT 0,
  "updated_at" timestamp with time zone NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS "mutter_coin_ledger" (
  "id" uuid PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
  "game_id" uuid REFERENCES "games"("id") ON DELETE SET NULL,
  "amount_atomic" bigint NOT NULL,
  "balance_after_atomic" bigint NOT NULL,
  "kind" text NOT NULL,
  "description" text NOT NULL,
  "idempotency_key" text NOT NULL,
  "metadata" jsonb NOT NULL DEFAULT '{}'::jsonb,
  "created_at" timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT "mutter_coin_ledger_idempotency_uidx" UNIQUE("idempotency_key")
);

CREATE INDEX IF NOT EXISTS "mutter_coin_ledger_user_created_idx" ON "mutter_coin_ledger" ("user_id", "created_at");
CREATE INDEX IF NOT EXISTS "mutter_coin_ledger_game_idx" ON "mutter_coin_ledger" ("game_id");
