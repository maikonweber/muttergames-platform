/**
 * Ported subset of `Fallen Tactics/project-fallen-tactics/scripts/data/card_library.gd`.
 *
 * Only grid/movement-dependent cards (move, charge, timeline, facing, aoe by cell,
 * duel-mark) are left out for now since the game server has no tactical grid yet —
 * PVP is a direct 1v1 duel between two units. Damage numbers, costs and buff/debuff
 * semantics match the Godot client exactly so client and server stay in sync.
 */

export type Stance = 'balance' | 'guard' | 'offense';

export type CardEffect =
  | { op: 'damage'; value: number; requireSetup?: boolean }
  | { op: 'block'; value: number }
  | { op: 'stance'; value: Stance }
  | { op: 'flag'; name: 'no_attack' | 'pressure' | 'next_attack_bonus'; value?: number }
  | { op: 'strip_block' }
  | { op: 'vulnerable'; value?: number }
  | { op: 'prepare_reaction'; kind: 'parry' };

export type CardTargetMode = 'self' | 'enemy' | 'none';

export type CardDef = {
  id: string;
  displayName: string;
  description: string;
  cost: number;
  targetMode: CardTargetMode;
  effects: CardEffect[];
  tags: string[];
};

function card(def: CardDef): CardDef {
  return def;
}

export const CARD_LIBRARY: Record<string, CardDef> = {
  golpe: card({
    id: 'golpe',
    displayName: 'Golpe',
    description: 'Causa 5 de dano. Base do arsenal.',
    cost: 1,
    targetMode: 'enemy',
    effects: [{ op: 'damage', value: 5 }],
    tags: ['attack', 'weapon'],
  }),
  estocada: card({
    id: 'estocada',
    displayName: 'Estocada',
    description: '4 de dano.',
    cost: 1,
    targetMode: 'enemy',
    effects: [{ op: 'damage', value: 4 }],
    tags: ['attack', 'reach'],
  }),
  guarda_alta: card({
    id: 'guarda_alta',
    displayName: 'Guarda Alta',
    description: 'Entra em postura Guarda. +3 Block.',
    cost: 1,
    targetMode: 'self',
    effects: [
      { op: 'block', value: 3 },
      { op: 'stance', value: 'guard' },
    ],
    tags: ['defense', 'stance'],
  }),
  pressao: card({
    id: 'pressao',
    displayName: 'Pressão',
    description: 'Próximo ataque: +2 dano e compre 1 carta se acertar.',
    cost: 1,
    targetMode: 'self',
    effects: [{ op: 'flag', name: 'pressure' }],
    tags: ['buff', 'combo'],
  }),
  quebra_guarda: card({
    id: 'quebra_guarda',
    displayName: 'Quebra-guarda',
    description: 'Remove Block do alvo e aplica Vulnerável (próximo dano +50%).',
    cost: 1,
    targetMode: 'enemy',
    effects: [{ op: 'strip_block' }, { op: 'vulnerable', value: 1 }],
    tags: ['debuff'],
  }),
  ofensiva: card({
    id: 'ofensiva',
    displayName: 'Postura Ofensiva',
    description: 'Entra em Ofensiva. Próximo ataque +2.',
    cost: 0,
    targetMode: 'self',
    effects: [
      { op: 'stance', value: 'offense' },
      { op: 'flag', name: 'next_attack_bonus', value: 2 },
    ],
    tags: ['stance'],
  }),
  parry: card({
    id: 'parry',
    displayName: 'Parry',
    description: 'Reação: nega o próximo golpe recebido e ganha 1 energia.',
    cost: 1,
    targetMode: 'self',
    effects: [{ op: 'prepare_reaction', kind: 'parry' }],
    tags: ['defense', 'reaction'],
  }),
  escudo_forte: card({
    id: 'escudo_forte',
    displayName: 'Escudo Forte',
    description: 'Ganha 5 Block.',
    cost: 1,
    targetMode: 'self',
    effects: [{ op: 'block', value: 5 }],
    tags: ['defense', 'guardian'],
  }),
  golpe_escudo: card({
    id: 'golpe_escudo',
    displayName: 'Golpe de Escudo',
    description: '4 de dano e +2 Block.',
    cost: 1,
    targetMode: 'enemy',
    effects: [
      { op: 'damage', value: 4 },
      { op: 'block', value: 2 },
    ],
    tags: ['attack', 'guardian'],
  }),
  tiro: card({
    id: 'tiro',
    displayName: 'Tiro',
    description: '4 de dano à distância.',
    cost: 1,
    targetMode: 'enemy',
    effects: [{ op: 'damage', value: 4 }],
    tags: ['attack', 'ranged', 'ranger'],
  }),
  tiro_preciso: card({
    id: 'tiro_preciso',
    displayName: 'Tiro Preciso',
    description: '6 de dano à distância.',
    cost: 2,
    targetMode: 'enemy',
    effects: [{ op: 'damage', value: 6 }],
    tags: ['attack', 'ranged', 'ranger'],
  }),
  lamina_final: card({
    id: 'lamina_final',
    displayName: 'Lâmina Final',
    description: '12 de dano. Requer postura Ofensiva.',
    cost: 3,
    targetMode: 'enemy',
    effects: [{ op: 'damage', value: 12, requireSetup: true }],
    tags: ['attack', 'finisher'],
  }),
};

export function getCard(id: string): CardDef | undefined {
  return CARD_LIBRARY[id];
}

/** Default 1v1 PVP deck — combat-relevant subset of the Espadachim/Guardião/Patrulheiro decks. */
export const PVP_STARTER_DECK: string[] = [
  'golpe',
  'golpe',
  'golpe',
  'estocada',
  'estocada',
  'guarda_alta',
  'guarda_alta',
  'pressao',
  'quebra_guarda',
  'ofensiva',
  'parry',
  'escudo_forte',
  'lamina_final',
];

export const PVP_HAND_SIZE = 5;
