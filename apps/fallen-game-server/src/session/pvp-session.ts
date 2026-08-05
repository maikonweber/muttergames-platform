import { randomBytes, randomInt, randomUUID } from 'node:crypto';
import type { AuthUser } from '../auth/jwt';
import { getCard, PVP_HAND_SIZE, PVP_STARTER_DECK } from '../combat/cards';
import { beginTurn, createUnitState, resolveCard, type CombatUnitState } from '../combat/rules';
import { config } from '../config';
import type { CommandMessage, PvpSnapshot, PvpSnapshotPlayer, ServerEvent, ServerMessage } from '../protocol/messages';

export type SeatPlayer = {
  clientId: string;
  displayName: string;
  userId?: string;
  seat: number;
  connected: boolean;
  lastSeq: number;
  unitId: string;
  unit: CombatUnitState;
  drawPile: string[];
  hand: string[];
  discardPile: string[];
  resumeToken: string;
  graceTimer: NodeJS.Timeout | null;
};

type SendFn = (clientId: string, message: ServerMessage) => void;
type BroadcastFn = (message: ServerMessage, except?: string) => void;

function shuffle<T>(arr: T[]): T[] {
  const out = [...arr];
  for (let i = out.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

export class PvpSession {
  readonly sessionId: string;
  readonly roomCode: string;
  readonly seed: number;
  readonly createdAt = Date.now();

  private status: PvpSnapshot['status'] = 'lobby';
  private turn = 0;
  private activeClientId: string | null = null;
  private deadlineAt: string | null = null;
  private winnerClientId: string | null = null;
  private serverSeq = 0;
  private readonly players = new Map<string, SeatPlayer>();
  private turnTimer: NodeJS.Timeout | null = null;
  private readonly send: SendFn;
  private readonly broadcast: BroadcastFn;

  constructor(roomCode: string, hooks: { send: SendFn; broadcast: BroadcastFn }) {
    this.sessionId = randomUUID();
    this.roomCode = roomCode;
    this.seed = randomInt(1, 2_147_483_647);
    this.send = hooks.send;
    this.broadcast = hooks.broadcast;
  }

  get playerCount(): number {
    return this.players.size;
  }

  get isFull(): boolean {
    return this.players.size >= config.maxPlayersPerRoom;
  }

  /** Snapshot with all hands hidden — used for room listings / status checks only. */
  getSnapshot(): PvpSnapshot {
    return this.buildSnapshot(null);
  }

  addPlayer(input: {
    displayName: string;
    auth?: AuthUser | null;
  }): { clientId: string; seat: number; resumeToken: string } {
    if (this.status !== 'lobby') throw new Error('MATCH_ALREADY_STARTED');
    if (this.isFull) throw new Error('ROOM_FULL');

    const seat = this.players.size;
    const clientId = randomBytes(8).toString('hex');
    const resumeToken = randomBytes(16).toString('hex');
    const player: SeatPlayer = {
      clientId,
      displayName: input.displayName,
      userId: input.auth?.userId,
      seat,
      connected: true,
      lastSeq: 0,
      unitId: seat === 0 ? 'hero_alpha' : 'hero_bravo',
      unit: createUnitState(),
      drawPile: shuffle(PVP_STARTER_DECK),
      hand: [],
      discardPile: [],
      resumeToken,
      graceTimer: null,
    };
    this.players.set(clientId, player);

    this.emit([
      {
        op: 'player_joined',
        client_id: clientId,
        display_name: player.displayName,
        seat,
      },
    ]);

    if (this.isFull) {
      this.startMatch();
    }

    return { clientId, seat, resumeToken };
  }

  /** Reclaims a seat after a dropped connection. Throws if the token doesn't match or the match is over. */
  resume(clientId: string, resumeToken: string): number {
    const player = this.players.get(clientId);
    if (!player) throw new Error('UNKNOWN_CLIENT');
    if (player.resumeToken !== resumeToken) throw new Error('RESUME_TOKEN_INVALID');
    if (this.status === 'finished') throw new Error('MATCH_ALREADY_FINISHED');
    this.markConnected(clientId, true);
    return player.seat;
  }

  markConnected(clientId: string, connected: boolean): void {
    const player = this.players.get(clientId);
    if (!player) return;
    const wasConnected = player.connected;
    player.connected = connected;

    if (connected) {
      if (player.graceTimer) {
        clearTimeout(player.graceTimer);
        player.graceTimer = null;
      }
      if (!wasConnected) {
        this.emit([{ op: 'player_reconnected', client_id: clientId }]);
        this.broadcastSnapshot();
      }
      return;
    }

    if (!wasConnected) return; // already marked disconnected, avoid double timers
    const graceMs = this.status === 'active' ? config.reconnectGraceMs : null;
    this.emit([{ op: 'player_left', client_id: clientId, grace_ms: graceMs ?? undefined }]);
    if (graceMs === null) return;

    if (player.graceTimer) clearTimeout(player.graceTimer);
    player.graceTimer = setTimeout(() => {
      player.graceTimer = null;
      if (player.connected) return; // reconnected in the meantime
      if (this.status !== 'active') return;
      const winnerClientId = [...this.players.values()].find((p) => p.clientId !== clientId)?.clientId ?? null;
      this.finishMatch(winnerClientId, 'disconnect_timeout');
    }, graceMs);
  }

  handleCommand(message: CommandMessage): void {
    const player = this.players.get(message.client_id);
    if (!player) throw new Error('UNKNOWN_CLIENT');
    if (message.session_id !== this.sessionId) throw new Error('BAD_SESSION');
    if (message.seq <= player.lastSeq) return; // idempotent
    player.lastSeq = message.seq;

    if (this.status !== 'active') throw new Error('MATCH_NOT_ACTIVE');
    if (this.activeClientId !== player.clientId) throw new Error('NOT_YOUR_TURN');

    switch (message.cmd.op) {
      case 'ready':
        return;
      case 'play_card':
        this.applyPlayCard(player, message.cmd);
        break;
      case 'end_turn':
        this.endTurn(player.clientId);
        break;
      case 'surrender':
        this.finishMatch(
          [...this.players.values()].find((p) => p.clientId !== player.clientId)?.clientId ?? null,
          'surrender',
        );
        break;
    }
  }

  sendSnapshot(clientId: string): void {
    this.send(clientId, {
      v: 1,
      type: 'snapshot',
      server_seq: this.serverSeq,
      session_id: this.sessionId,
      state: this.buildSnapshot(clientId),
    });
  }

  dispose(): void {
    if (this.turnTimer) clearTimeout(this.turnTimer);
    for (const player of this.players.values()) {
      if (player.graceTimer) clearTimeout(player.graceTimer);
    }
  }

  private startMatch(): void {
    this.status = 'active';
    this.turn = 1;
    const seats = [...this.players.values()].sort((a, b) => a.seat - b.seat);
    this.activeClientId = seats[0]?.clientId ?? null;
    this.deadlineAt = new Date(Date.now() + config.turnTimeoutMs).toISOString();

    this.emit([
      {
        op: 'match_started',
        seed: this.seed,
        seats: seats.map((p) => p.clientId),
      },
      {
        op: 'turn_started',
        client_id: this.activeClientId!,
        turn: this.turn,
        deadline_at: this.deadlineAt,
      },
    ]);
    if (this.activeClientId) this.beginTurnFor(this.activeClientId);
    this.armTurnTimer();
    this.broadcastSnapshot();
  }

  private applyPlayCard(
    player: SeatPlayer,
    cmd: Extract<CommandMessage['cmd'], { op: 'play_card' }>,
  ): void {
    if (cmd.unit_id !== player.unitId) throw new Error('UNIT_NOT_OWNED');

    const cardDef = getCard(cmd.card_uid);
    if (!cardDef) throw new Error('UNKNOWN_CARD');

    const handIndex = player.hand.indexOf(cmd.card_uid);
    if (handIndex === -1) throw new Error('CARD_NOT_IN_HAND');
    if (player.unit.energy < cardDef.cost) throw new Error('NOT_ENOUGH_ENERGY');

    const opponent = [...this.players.values()].find((p) => p.clientId !== player.clientId);

    player.unit.energy -= cardDef.cost;
    player.hand.splice(handIndex, 1);
    player.discardPile.push(cmd.card_uid);

    const events: ServerEvent[] = [
      {
        op: 'card_played',
        unit_id: cmd.unit_id,
        card_uid: cmd.card_uid,
        client_id: player.clientId,
        cost: cardDef.cost,
        target: cmd.target,
      },
    ];

    if (opponent) {
      const result = resolveCard(cardDef, player.unit, opponent.unit);

      for (const entry of result.casterLog) {
        events.push(...this.mapLogEntry(player.unitId, entry));
        if (entry.op === 'blocked_no_attack') events.push({ op: 'card_blocked', unit_id: player.unitId, card_uid: cmd.card_uid, reason: 'no_attack' });
        if (entry.op === 'blocked_requires_setup') events.push({ op: 'card_blocked', unit_id: player.unitId, card_uid: cmd.card_uid, reason: 'requires_setup' });
      }
      for (const entry of result.targetLog) {
        events.push(...this.mapLogEntry(opponent.unitId, entry));
      }

      if (result.anyHit && player.unit.pressureReady) {
        player.unit.pressureReady = false;
        this.drawCards(player, 1);
        events.push({ op: 'hand_drawn', client_id: player.clientId, count: 1 });
      }

      if (opponent.unit.hp <= 0) {
        this.emit(events);
        this.finishMatch(player.clientId, 'hp_zero');
        return;
      }
    }

    this.emit(events);
    this.broadcastSnapshot();
  }

  private mapLogEntry(
    unitId: string,
    entry: ReturnType<typeof resolveCard>['casterLog'][number],
  ): ServerEvent[] {
    switch (entry.op) {
      case 'damage': {
        const source = [...this.players.values()].find((p) => p.unitId !== unitId);
        return [
          {
            op: 'damage',
            source_id: source?.unitId ?? '',
            target_id: unitId,
            amount: entry.amount,
            blocked: entry.blocked,
            hp_after: entry.hpAfter,
          },
        ];
      }
      case 'block':
        return [{ op: 'block_gained', unit_id: unitId, amount: entry.amount, block_after: entry.blockAfter }];
      case 'stance':
        return [{ op: 'stance_changed', unit_id: unitId, stance: entry.stance }];
      case 'vulnerable':
        return [{ op: 'vulnerable_applied', unit_id: unitId, stacks: entry.stacks }];
      case 'strip_block':
        return [{ op: 'block_stripped', unit_id: unitId }];
      case 'reaction':
        return [{ op: 'reaction_triggered', unit_id: unitId, kind: entry.kind }];
      case 'flag':
      case 'blocked_no_attack':
      case 'blocked_requires_setup':
        return [];
    }
  }

  private drawCards(player: SeatPlayer, count: number): void {
    for (let i = 0; i < count; i += 1) {
      if (player.drawPile.length === 0) {
        if (player.discardPile.length === 0) break;
        player.drawPile = shuffle(player.discardPile);
        player.discardPile = [];
      }
      const card = player.drawPile.pop();
      if (!card) break;
      player.hand.push(card);
    }
  }

  private beginTurnFor(clientId: string): void {
    const player = this.players.get(clientId);
    if (!player) return;
    beginTurn(player.unit);
    this.drawCards(player, Math.max(0, PVP_HAND_SIZE - player.hand.length));
  }

  private endTurn(clientId: string): void {
    const player = this.players.get(clientId);
    if (!player) return;
    while (player.hand.length > 0) {
      player.discardPile.push(player.hand.pop()!);
    }

    const ordered = [...this.players.values()].sort((a, b) => a.seat - b.seat);
    const idx = ordered.findIndex((p) => p.clientId === clientId);
    const next = ordered[(idx + 1) % ordered.length];
    this.turn += 1;
    this.activeClientId = next?.clientId ?? null;
    this.deadlineAt = new Date(Date.now() + config.turnTimeoutMs).toISOString();

    if (this.activeClientId) this.beginTurnFor(this.activeClientId);

    this.emit([
      { op: 'turn_ended', client_id: clientId, turn: this.turn - 1 },
      {
        op: 'turn_started',
        client_id: this.activeClientId!,
        turn: this.turn,
        deadline_at: this.deadlineAt,
      },
    ]);
    this.armTurnTimer();
    this.broadcastSnapshot();
  }

  private finishMatch(winnerClientId: string | null, reason: string): void {
    this.status = 'finished';
    this.winnerClientId = winnerClientId;
    this.activeClientId = null;
    this.deadlineAt = null;
    if (this.turnTimer) clearTimeout(this.turnTimer);
    this.emit([{ op: 'match_ended', winner_client_id: winnerClientId, reason }]);
    this.broadcastSnapshot();
  }

  private armTurnTimer(): void {
    if (this.turnTimer) clearTimeout(this.turnTimer);
    this.turnTimer = setTimeout(() => {
      if (this.status !== 'active' || !this.activeClientId) return;
      try {
        this.endTurn(this.activeClientId);
      } catch {
        // ignore timeout races
      }
    }, config.turnTimeoutMs);
  }

  private emit(events: ServerEvent[]): void {
    this.serverSeq += 1;
    this.broadcast({
      v: 1,
      type: 'event',
      server_seq: this.serverSeq,
      session_id: this.sessionId,
      events,
    });
  }

  private buildSnapshot(viewerClientId: string | null): PvpSnapshot {
    const players: PvpSnapshotPlayer[] = [...this.players.values()].map((p) => ({
      client_id: p.clientId,
      display_name: p.displayName,
      seat: p.seat,
      hp: p.unit.hp,
      max_hp: p.unit.maxHp,
      energy: p.unit.energy,
      max_energy: p.unit.maxEnergy,
      block: p.unit.block,
      stance: p.unit.stance,
      vulnerable_stacks: p.unit.vulnerableStacks,
      no_attack_this_turn: p.unit.noAttackThisTurn,
      connected: p.connected,
      deck_count: p.drawPile.length,
      discard_count: p.discardPile.length,
      hand_count: p.hand.length,
      hand: p.clientId === viewerClientId ? [...p.hand] : null,
    }));

    return {
      status: this.status,
      turn: this.turn,
      active_client_id: this.activeClientId,
      deadline_at: this.deadlineAt,
      players,
      units: [...this.players.values()].map((p) => ({
        id: p.unitId,
        owner_client_id: p.clientId,
        hp: p.unit.hp,
        cell: [p.seat === 0 ? 1 : 6, 3] as [number, number],
      })),
      winner_client_id: this.winnerClientId,
    };
  }

  private broadcastSnapshot(): void {
    this.serverSeq += 1;
    for (const clientId of this.players.keys()) {
      this.send(clientId, {
        v: 1,
        type: 'snapshot',
        server_seq: this.serverSeq,
        session_id: this.sessionId,
        state: this.buildSnapshot(clientId),
      });
    }
  }
}
