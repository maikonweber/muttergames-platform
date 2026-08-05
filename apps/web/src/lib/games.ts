export type FeaturedGame = {
  id: string;
  name: string;
  badge: string;
  description: string;
  accent?: 'red';
};

/** Catálogo de marketing — espelha os mundos em desenvolvimento no monorepo. */
export const featuredGames: FeaturedGame[] = [
  {
    id: 'fallen-tactics',
    name: 'Fallen Tactics',
    badge: 'Estratégia',
    description:
      'Roguelike tático em grid: comande heróis, cada um com o próprio deck, e monte builds únicas a cada run.',
  },
  {
    id: 'forge-of-champions',
    name: 'Forge of Champions',
    badge: 'TCG',
    description:
      'Monte seu campeão em cinco slots — arma, armadura, elmo, artefato e técnica — e dispute duelos competitivos de 8 a 12 minutos.',
  },
  {
    id: 'taskbar-planets-forger',
    name: 'Taskbar Planets Forger',
    badge: 'Idle',
    description:
      'Companion na barra de tarefas do Windows: poeira cósmica vira planetas, vida e prestígio em supernova.',
  },
  {
    id: 'beat-up',
    name: 'Beat Up',
    badge: 'Direção',
    accent: 'red',
    description:
      'Dirija por uma cidade isométrica, aceite entregas e acumule MutterCoins no ritmo 2.5D.',
  },
];
