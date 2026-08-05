import { z } from 'zod';

export const HelloMessageSchema = z.object({
  v: z.literal(1),
  type: z.literal('hello'),
  protocol_version: z.number().int().positive(),
  token: z.string().optional(),
  room_code: z.string().length(6).optional(),
  display_name: z.string().min(1).max(32).optional(),
  content_hash: z.string().optional(),
  last_server_seq: z.number().int().nonnegative().optional(),
  /** Present together with `resume_token` when reclaiming a seat after a dropped connection. */
  client_id: z.string().min(1).optional(),
  resume_token: z.string().min(1).optional(),
});

export const CommandMessageSchema = z.object({
  v: z.literal(1),
  type: z.literal('command'),
  session_id: z.string().uuid(),
  client_id: z.string().min(1),
  seq: z.number().int().positive(),
  cmd: z.discriminatedUnion('op', [
    z.object({
      op: z.literal('play_card'),
      unit_id: z.string().min(1),
      card_uid: z.string().min(1),
      target: z.object({ cell: z.tuple([z.number().int(), z.number().int()]) }).optional(),
    }),
    z.object({
      op: z.literal('end_turn'),
      unit_id: z.string().min(1).optional(),
    }),
    z.object({
      op: z.literal('surrender'),
    }),
    z.object({
      op: z.literal('ready'),
    }),
  ]),
});

export const PingMessageSchema = z.object({
  v: z.literal(1),
  type: z.literal('ping'),
  t: z.number().optional(),
});

export const ResyncMessageSchema = z.object({
  v: z.literal(1),
  type: z.literal('resync_request'),
  session_id: z.string().uuid(),
  last_server_seq: z.number().int().nonnegative().optional(),
});

export const ClientMessageSchema = z.discriminatedUnion('type', [
  HelloMessageSchema,
  CommandMessageSchema,
  PingMessageSchema,
  ResyncMessageSchema,
]);

export type ClientMessage = z.infer<typeof ClientMessageSchema>;
export type CommandMessage = z.infer<typeof CommandMessageSchema>;

export type ServerEvent =
  | { op: 'player_joined'; client_id: string; display_name: string; seat: number }
  | { op: 'player_left'; client_id: string; grace_ms?: number }
  | { op: 'player_reconnected'; client_id: string }
  | { op: 'match_started'; seed: number; seats: string[] }
  | { op: 'turn_started'; client_id: string; turn: number; deadline_at: string }
  | {
      op: 'card_played';
      unit_id: string;
      card_uid: string;
      client_id: string;
      cost: number;
      target?: { cell: [number, number] };
    }
  | { op: 'damage'; source_id: string; target_id: string; amount: number; blocked: number; hp_after: number }
  | { op: 'block_gained'; unit_id: string; amount: number; block_after: number }
  | { op: 'block_stripped'; unit_id: string }
  | { op: 'stance_changed'; unit_id: string; stance: 'balance' | 'guard' | 'offense' }
  | { op: 'vulnerable_applied'; unit_id: string; stacks: number }
  | { op: 'reaction_triggered'; unit_id: string; kind: string }
  | { op: 'card_blocked'; unit_id: string; card_uid: string; reason: 'no_attack' | 'requires_setup' }
  | { op: 'hand_drawn'; client_id: string; count: number }
  | { op: 'turn_ended'; client_id: string; turn: number }
  | { op: 'match_ended'; winner_client_id: string | null; reason: string };

export type ServerMessage =
  | {
      v: 1;
      type: 'welcome';
      client_id: string;
      session_id: string;
      room_code: string;
      seat: number;
      seed: number;
      protocol_version: number;
      game_id: string;
      mode: 'pvp';
      /** Present to a client for reclaiming its seat via `hello { client_id, resume_token }`. */
      resume_token: string;
      reconnect_grace_ms: number;
    }
  | {
      v: 1;
      type: 'event';
      server_seq: number;
      session_id: string;
      events: ServerEvent[];
    }
  | {
      v: 1;
      type: 'snapshot';
      server_seq: number;
      session_id: string;
      state: PvpSnapshot;
    }
  | { v: 1; type: 'pong'; t?: number; server_time: string }
  | { v: 1; type: 'error'; code: string; message: string; seq?: number }
  | { v: 1; type: 'goodbye'; reason: string };

export type PvpSnapshotPlayer = {
  client_id: string;
  display_name: string;
  seat: number;
  hp: number;
  max_hp: number;
  energy: number;
  max_energy: number;
  block: number;
  stance: 'balance' | 'guard' | 'offense';
  vulnerable_stacks: number;
  no_attack_this_turn: boolean;
  connected: boolean;
  deck_count: number;
  discard_count: number;
  hand_count: number;
  /** Only populated in the snapshot sent to the owning client — opponents never see your hand. */
  hand: string[] | null;
};

export type PvpSnapshot = {
  status: 'lobby' | 'active' | 'finished';
  turn: number;
  active_client_id: string | null;
  deadline_at: string | null;
  players: PvpSnapshotPlayer[];
  units: Array<{
    id: string;
    owner_client_id: string;
    hp: number;
    cell: [number, number];
  }>;
  winner_client_id: string | null;
};
