/**
 * Ported subset of `Fallen Tactics/project-fallen-tactics/scripts/combat/effect_resolver.gd`
 * and the combat-relevant parts of `scripts/combat/unit.gd` (BattleUnit).
 *
 * Facing/flank/back damage multipliers are intentionally omitted — they depend on the
 * tactical grid, which the game server does not model yet for PVP (1v1 direct duel).
 */

import type { CardDef, Stance } from './cards';

export type CombatUnitState = {
  hp: number;
  maxHp: number;
  energy: number;
  maxEnergy: number;
  energyRegen: number;
  block: number;
  stance: Stance;
  vulnerableStacks: number;
  noAttackThisTurn: boolean;
  pressureReady: boolean;
  nextAttackBonus: number;
  preparedReaction: '' | 'parry';
};

export function createUnitState(overrides: Partial<CombatUnitState> = {}): CombatUnitState {
  return {
    hp: 30,
    maxHp: 30,
    energy: 3,
    maxEnergy: 3,
    energyRegen: 3,
    block: 0,
    stance: 'balance',
    vulnerableStacks: 0,
    noAttackThisTurn: false,
    pressureReady: false,
    nextAttackBonus: 0,
    preparedReaction: '',
    ...overrides,
  };
}

export type RuleLogEntry =
  | { op: 'damage'; amount: number; blocked: number; hpAfter: number }
  | { op: 'block'; amount: number; blockAfter: number }
  | { op: 'stance'; stance: Stance }
  | { op: 'vulnerable'; stacks: number }
  | { op: 'strip_block' }
  | { op: 'reaction'; kind: string; energyAfter: number }
  | { op: 'flag'; name: string }
  | { op: 'blocked_no_attack' }
  | { op: 'blocked_requires_setup' };

export type ResolveResult = {
  /** Log entries targeting the caster's own unit. */
  casterLog: RuleLogEntry[];
  /** Log entries targeting the opponent's unit (only populated for enemy-targeted cards). */
  targetLog: RuleLogEntry[];
  /** True if at least one damage/charge effect actually connected — used to trigger Pressão's card draw. */
  anyHit: boolean;
};

function damageAmount(base: number, caster: CombatUnitState): number {
  let dmg = base;
  if (caster.stance === 'offense') dmg += 1;
  if (caster.pressureReady) dmg += 2;
  if (caster.nextAttackBonus > 0) {
    dmg += caster.nextAttackBonus;
    caster.nextAttackBonus = 0;
  }
  return dmg;
}

/** Port of `BattleUnit.take_damage` (minus facing-based multipliers). */
function applyDamage(target: CombatUnitState, rawAmount: number): { dealt: number; blocked: number; reacted: boolean } {
  let dmg = rawAmount;
  if (target.stance === 'offense') dmg += 1;
  if (target.vulnerableStacks > 0) {
    dmg = Math.floor(dmg * 1.5);
    target.vulnerableStacks -= 1;
  }
  if (target.preparedReaction === 'parry') {
    target.preparedReaction = '';
    target.energy = Math.min(target.maxEnergy, target.energy + 1);
    return { dealt: 0, blocked: 0, reacted: true };
  }
  const blocked = Math.min(target.block, dmg);
  target.block -= blocked;
  dmg -= blocked;
  target.hp = Math.max(0, target.hp - dmg);
  return { dealt: dmg, blocked, reacted: false };
}

function addBlock(unit: CombatUnitState, amount: number): number {
  const bonus = unit.stance === 'guard' ? amount + 1 : amount;
  unit.block += bonus;
  return bonus;
}

/** Port of `EffectResolver.resolve`, scoped to non-grid opcodes. */
export function resolveCard(
  cardDef: CardDef,
  caster: CombatUnitState,
  target: CombatUnitState,
): ResolveResult {
  const casterLog: RuleLogEntry[] = [];
  const targetLog: RuleLogEntry[] = [];
  let anyHit = false;

  for (const effect of cardDef.effects) {
    switch (effect.op) {
      case 'damage': {
        if (caster.noAttackThisTurn) {
          casterLog.push({ op: 'blocked_no_attack' });
          break;
        }
        if (effect.requireSetup && caster.stance !== 'offense') {
          casterLog.push({ op: 'blocked_requires_setup' });
          break;
        }
        const base = damageAmount(effect.value, caster);
        const result = applyDamage(target, base);
        if (result.reacted) {
          targetLog.push({ op: 'reaction', kind: 'parry', energyAfter: target.energy });
        } else {
          targetLog.push({ op: 'damage', amount: result.dealt, blocked: result.blocked, hpAfter: target.hp });
          anyHit = true;
        }
        break;
      }
      case 'block': {
        const bonus = addBlock(caster, effect.value);
        casterLog.push({ op: 'block', amount: bonus, blockAfter: caster.block });
        break;
      }
      case 'stance': {
        caster.stance = effect.value;
        casterLog.push({ op: 'stance', stance: caster.stance });
        break;
      }
      case 'flag': {
        switch (effect.name) {
          case 'no_attack':
            caster.noAttackThisTurn = true;
            break;
          case 'pressure':
            caster.pressureReady = true;
            break;
          case 'next_attack_bonus':
            caster.nextAttackBonus += effect.value ?? 0;
            break;
        }
        casterLog.push({ op: 'flag', name: effect.name });
        break;
      }
      case 'strip_block': {
        target.block = 0;
        targetLog.push({ op: 'strip_block' });
        break;
      }
      case 'vulnerable': {
        target.vulnerableStacks += effect.value ?? 1;
        targetLog.push({ op: 'vulnerable', stacks: target.vulnerableStacks });
        break;
      }
      case 'prepare_reaction': {
        caster.preparedReaction = effect.kind;
        casterLog.push({ op: 'flag', name: `prepare_${effect.kind}` });
        break;
      }
    }
  }

  return { casterLog, targetLog, anyHit };
}

/** Port of `BattleUnit.start_turn` (minus draw, handled by the session/deck layer). */
export function beginTurn(unit: CombatUnitState): void {
  unit.block = 0;
  unit.noAttackThisTurn = false;
  unit.energy = Math.min(unit.maxEnergy, unit.energy + unit.energyRegen);
}
