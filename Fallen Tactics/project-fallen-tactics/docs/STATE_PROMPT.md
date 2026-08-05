# AGENT PROMPT — PROJECT FALLEN TACTICS (ESTADO ATUAL)

> Contexto vivo do protótipo. Atualize este arquivo quando o estado do jogo mudar de forma relevante.
> Use como system/context prompt ao retomar o projeto em qualquer sessão ou agente.

Você é o Game Director / Lead Designer / implementador deste projeto.
Continue a partir do estado real do repositório — não reinvente do zero.

---

## Identidade do jogo

**Nome:** Project Fallen Tactics  
**Gênero:** RPG + Deckbuilder + Tactical (grid) + Roguelike  
**Tese:** Não é clone de Slay the Spire nem de Final Fantasy Tactics.  
Combina deckbuilding + posicionamento + terreno + progressão de run.  
Toda carta deve ser uma **escolha** (posição, timing, postura, controle) — nunca só “+dano”.

### Pilares (filtro obrigatório de features)

1. Decisões interessantes  
2. Posicionamento importa  
3. Terreno importa  
4. Equipamentos mudam cartas (ainda NÃO implementado)  
5. Cada classe joga diferente  
6. Toda run é única  

Se a feature não passar no filtro (diversão, profundidade, builds, rejogabilidade), descarte.

---

## Status do projeto

| Item | Valor |
|------|--------|
| Fase | **Vertical Slice jogável (protótipo)** |
| Engine | **Godot 4.7** (Forward+) |
| Path | `C:\Users\plugify\Documents\project-fallen-tactics` |
| Main scene | `res://scenes/combat/combat_scene.tscn` |
| Godot exe | `C:\Users\plugify\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64.exe` |
| Resolução | 1280×720 |
| Autoload | `GameState` → `scripts/autoload/game_state.gd` |
| Loop | **Um só modo: combate.** Campo **16×10** iso + **FOW** (visão 4 da party). Party 3. Inimigos ocultos até visão. Sem mapa de exploração separado. |
| Pasta `data/cards`, `data/units`, `data/encounters` | Existem, mas **ainda vazias** (dados estão em GDScript) |

### Como rodar

```text
Godot --path "C:\Users\plugify\Documents\project-fallen-tactics"
Godot --path "C:\Users\plugify\Documents\project-fallen-tactics" --editor
```

### Controles atuais

- Clique na carta → seleciona  
- Clique no grid → alvo (tile/inimigo)  
- Espaço / botão → fim do turno  
- Esc → cancela targeting  

---

## O que ESTÁ implementado e jogável

### Loop da run (mínimo)

1. Auto `start_new_run()` se não houver run  
2. **Encounter 01** → vitória → escolha 1 de 3 cartas  
3. **Encounter 02** → vitória → escolha 1 de 3 cartas  
4. **Boss** → vitória = run completa (sem meta progressão real)  
5. Derrota = fim da run (`GameState.run_active = false`)  

Não existe: mapa procedural, eventos, mercador, ferreiro, multi-herói, meta unlocks profundos, inventário de equipamentos.

### Combate

- Grid tático **8×6** em **iso 2:1** (lógica em `Vector2i`; render diamante 128×64 via `IsoMath`)  
- `TacticalGrid` — **não** usar nome `GridMap` (classe nativa Godot)  
- Tiles: GRASS/STONE (texturas), WATER/WALL/PIT/ELEVATED (procedural iso)  
- Arena default com elevação, água, muros, pits  
- Y-sort de unidades; click em diamante; Espadachim com sprite `idle_se/sw`  
- Unidades: HP, energia, regen, block, stance, facing (N/E/S/W), initiative/timeline  
- Modificadores de dano: frente / flanco (+25%) / costas (+50%); Guarda reduz dano frontal; Ofensiva é glass cannon  
- Timeline dinâmica: menor `timeline_value` age; após o turno soma `base_initiative`  
- Cartas podem: `delay_timeline`, `advance_timeline`, preparar reação (parry)  
- Movimento é carta (não “move de graça + 3 ataques”)  
- Deck: draw pile / hand / discard; hand size 5; discard da mão no fim do turno do jogador  
- Energia: max 3, regen 3 no início do turno (herói)  
- Posturas: `balance` | `guard` | `offense`  
- Efeitos via opcodes em `EffectResolver` (data-oriented)  

### Classe VS

- **Só Espadachim** (1 herói por combate)  
- HP 36, energia 3, iniciativa base 8, postura inicial balance  
- Fantasy: ritmo de duelo (postura, ângulo, sequência)  
- Especializações (Berserker / Duelista / Cavaleiro): **designado, não implementado**  

### Deck inicial (`GameState.STARTER_DECK`)

```text
passo_combate ×2, golpe ×3, estocada, parry, guarda_alta,
finta, pressao, giro, sprint
```

### Cartas na `CardLibrary` (17 ids)

| id | Nome | Papel |
|----|------|--------|
| passo_combate | Passo de Combate | Move ≤2 |
| sprint | Sprint | Move ≤4, flag no_attack |
| investida | Investida | Charge linha + dano, bônus elevação |
| golpe | Golpe | 5 dmg melee |
| corte_arco | Corte em Arco | AoE adjacente |
| estocada | Estocada | Reach 2, 4 dmg |
| parry | Parry | Reação: nega golpe frontal +1 energia |
| guarda_alta | Guarda Alta | Block 3 + stance guard |
| finta | Finta | Delay timeline + força facing |
| pressao | Pressão | Próximo atk +2 e draw se acertar |
| quebra_guarda | Quebra-guarda | Strip block + vulnerable |
| giro | Giro | Move 0–1, custo 0 |
| desafio | Desafio | Marca duelo + bônus no alvo |
| respiracao | Respiração | Adianta timeline |
| lamina_final | Lâmina Final | 12 dmg, exige offense ou marca duelo |
| ofensiva | Postura Ofensiva | Stance offense + next_attack_bonus |

**Pool de recompensa:** investida, corte_arco, desafio, lamina_final, ofensiva, quebra_guarda, respiracao  

### Encontros

| ID | Conteúdo |
|----|----------|
| encounter_01 | Goblin (flanker, 14 HP) + Orc (rusher, 22 HP) |
| encounter_02 | 2 Goblins + Arqueiro (ranged, 16 HP, busca elevação) |
| encounter_boss | Capitão (boss, 48 HP) |

### Boss — Capitão

- Fase 2 (≤66% HP): abre pits no mapa + spawna reforço Goblin  
- Fase 3 (≤33% HP): acelera initiative/timeline do boss  
- Pode empurrar o herói; pit próximo = dano extra  

### IA (`AIController`)

| Profile | Comportamento |
|---------|----------------|
| rusher | Avança e melee |
| flanker | Prefere costas do herói |
| ranged | Busca elevação, atira 2–4, kites se perto |
| boss | Fases + push + melee |

### UI mínima

- Hand (botões coloridos por tipo)  
- Timeline textual  
- Log lateral  
- Energia / HP / postura  
- Botão fim de turno  
- Painel de recompensa (3 cartas + skip)  

### Arquitetura de scripts

```text
scripts/
  autoload/game_state.gd      # run state, starter deck, encounter index
  combat/
    combat_manager.gd         # CombatManager — loop principal
    grid_map.gd               # class_name TacticalGrid
    unit.gd                   # class_name BattleUnit
    effect_resolver.gd        # opcodes de cartas
    ai_controller.gd          # IA por personalidade
  data/
    card_def.gd               # CardDef Resource
    card_library.gd           # todas as cartas em Array dict (_raw)
    unit_def.gd               # UnitDef (pouco usado; spawns ainda em dict)
  ui/combat_ui.gd             # HUD
scenes/combat/combat_scene.tscn
```

### Opcodes de efeito existentes

`damage`, `move`, `block`, `stance`, `flag`, `prepare_reaction`,  
`delay_timeline`, `advance_timeline`, `face_toward_caster`, `free_facing`,  
`strip_block`, `vulnerable`, `mark_duel`, `charge`, `aoe_adjacent`

**Flags:** `no_attack`, `pressure`, `next_attack_bonus`, `duel_bonus`, `discard_one` (parcial)

---

## O que NÃO está implementado (visão completa do GDD)

- Time multi-herói  
- 9 outras classes + especializações  
- Equipamentos que mutam cartas (ex.: Golpe → Golpe Flamejante)  
- Relíquias que mudam regras  
- Eventos (mercador, ferreiro, oráculo, etc.)  
- Mapa procedural / biomas / regiões  
- JSON real em `data/` (ainda hardcoded em GDScript)  
- Interrupt/reaction stack completo  
- Terrenos avançados: fogo, gelo, veneno, floresta queimando, lava, bridge  
- Meta progressão (unlocks permanentes)  
- Arte estilizada final / animações  
- Áudio  
- Balance fino / playtest formal  
- Cena de menu / title screen  
- `unit.tscn` referenciado em código mas unidades são criadas em código  

---

## Decisões de design já travadas (não reabrir sem motivo)

1. VS prova o núcleo com **1 herói Espadachim**, não time completo  
2. Movimento = carta  
3. Timeline simplificada (adiantar/atrasar/reação básica) — sem stack complexo  
4. Terreno VS limitado (água, muro, pit, elevação) — resto pós-VS  
5. Boss muda regras/mapa, não é saco de HP  
6. Data-driven via opcodes; evitar `if card_id == "golpe"` no combate  
7. `TacticalGrid` (nunca `class_name GridMap`)  

### Critérios de sucesso do VS

Playtester deve sentir:

1. Mexeu por causa de flanco/costas  
2. Guardou finta para o arqueiro / timeline  
3. Postura mudou o valor das cartas  
4. Boss mudou o mapa e forçou replanejar  
5. Quer mais uma run após morrer  

---

## Dívida técnica / cuidados

- Dados de cartas/encontros ainda em código (`CardLibrary._raw`, spawns no `CombatManager`) — pastas `data/` vazias  
- Visual placeholder; sem feedback de animação de dano/movimento  
- `UNIT_SCENE_PATH` aponta para cena inexistente; spawn é procedural  
- Alguns efeitos/tags (ex. `discard_one`, `free_facing`) estão incompletos  
- Precisa de scan do editor Godot para gerar `.godot/global_script_class_cache.cfg` se classes `class_name` não resolverem  
- Logs temporários na raiz do projeto (`godot_*.log`) podem ser limpos  

---

## Próximos passos sugeridos (prioridade)

### P0 — Polir o núcleo (antes de expandir conteúdo)

1. Feedback visual: highlights melhores, floating damage, facing legível  
2. Balance pass no Espadachim vs 3 encontros  
3. Corrigir edge cases de targeting/movimento/path cost real na investida  

### P1 — Validar pilares faltantes do VS

4. 1 arma que **muta** Golpe → prova “equip muda carta”  
5. 1 relíquia que muda regra (não +stat)  
6. Migrar cartas/encontros para JSON/Resource em `data/`  

### P2 — Expandir run

7. Mapa simples de nós (combate / elite / evento / boss)  
8. 1 evento + 1 recompensa não-carta  
9. Segunda classe só depois do núcleo “viciante”  

### Evitar agora

- 10 classes de uma vez  
- Time de 4 heróis  
- Todos os biomas/terrenos  
- Meta skill tree completa  

---

## Regras do agente neste projeto

Sempre que propor feature:

1. Por que melhora o jogo?  
2. Impacto no balance?  
3. Interação com cartas / classes / terreno?  
4. MVP ou futuro?  
5. Evitar redundância; preferir profundidade a quantidade  

Preservar identidade: decisões > números; posição e terreno co-protagonistas do deck.

---

## Documentação relacionada

| Doc | Assunto |
|-----|---------|
| [`GAME_OVERVIEW.md`](GAME_OVERVIEW.md) | Visão completa do jogo |
| [`ROADMAP_3V3_WORLD.md`](ROADMAP_3V3_WORLD.md) | 3v3 + zona + XP + atividades |
| [`ASSETS_AND_ANIMATIONS.md`](ASSETS_AND_ANIMATIONS.md) | Assets e animações necessárias |
| [`ASSET_INSTRUCTIONS.md`](ASSET_INSTRUCTIONS.md) | Instruções detalhadas de produção por asset |
| [`MULTIPLAYER.md`](MULTIPLAYER.md) | Multiplayer (ainda não implementado) |
| [`PORTABILITY.md`](PORTABILITY.md) | Portabilidade de plataformas |
| [`NETWORKING_SERVERS.md`](NETWORKING_SERVERS.md) | WebSocket / UDP / servidores |
| [`README.md`](README.md) | Índice dos docs |

**Roadmap 3v3:** zona tática + combate 3v3 + XP por escolha. Fases 0→6; não pular para open world.  
**Multiplayer:** solo first; hotseat → co-op WS autoritativo; UDP só complementar.

---

## Histórico de contexto

| Data | Nota |
|------|------|
| 2026-08-01 | Vertical Slice criado em Godot; combate + deck + 3 encontros + boss; este doc gerado como contexto permanente em `docs/`. |
| 2026-08-01 | Roadmap `ROADMAP_3V3_WORLD.md`: 3v3, grid/zona 2×, XP, atividades de mapa. |
| 2026-08-01 | Docs: GAME_OVERVIEW, MULTIPLAYER, PORTABILITY, NETWORKING_SERVERS. |
| 2026-08-01 | Doc `ASSETS_AND_ANIMATIONS.md`: specs, listas de anim, VFX, UI, prioridade A0–A4. |
| 2026-08-01 | P1 sheet (CSV+checklist) + P0 juice no Godot (FX, silhuetas, tiles). |
| 2026-08-01 | **Perspectiva travada: isométrico 2:1** (docs de arte/instruções atualizados). |
| 2026-08-01 | Primeiro lote iso: `grass_01.png` + `espadachim_idle_se.png` + preview de pivot. |
| 2026-08-01 | Lote 2: grass_02, stone_01, idle_sw, attack_slash_se + cena `iso_asset_preview`. |
| 2026-08-01 | **Migração combate → iso 2:1** (grid render/input, camera, sprites herói, y-sort). |
| 2026-08-01 | Tiles full set + 4 inimigos sprite + attack pose + pick_cell diamante. |
| 2026-08-02 | Polish: hit/death Espadachim, VFX slash, câmera segue unidade ativa. |
| 2026-08-02 | Inimigos hit/death; VFX block/parry/death; SFX WAV + autoload AudioBus. |
| 2026-08-02 | **3v3 party**: GameState.party, 3 classes, cards Guardião/Patrulheiro, AI taunt/target, reward→herói. |
| 2026-08-02 | **Zona exploração**: main scene zone, patrulhas, POIs, emboscada, retorno pós-combate. |
| 2026-08-02 | **Fog of war** na zona: visão, memória explorada, persistência em GameState.zone.explored. |
| 2026-08-02 | **Unificado:** main=combate amplo+FOW; zona deixa de ser modo de jogo. |
