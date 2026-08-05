# Assets & Animações — Project Fallen Tactics

**Status:** Design de produção de arte  
**Última atualização:** 2026-08-01  
**Estado atual no código:** **P0 engine placeholders** (silhuetas, outline, floating dmg, tiles com padrão) — **nenhum asset final P1**  
**Produção P1:** `[P1_PRODUCTION_CHECKLIST.md](P1_PRODUCTION_CHECKLIST.md)` · `[P1_production_sheet.csv](P1_production_sheet.csv)`  
**Relacionados:** `[GAME_OVERVIEW.md](GAME_OVERVIEW.md)` · `[ROADMAP_3V3_WORLD.md](ROADMAP_3V3_WORLD.md)` · `[PORTABILITY.md](PORTABILITY.md)` · `[STATE_PROMPT.md](STATE_PROMPT.md)`

---

## 1. Objetivo deste documento

Definir **quais assets e animações o jogo precisa**, em que **prioridade**, com **specs técnicas** e **critérios de leitura tática**.

Serve para:

- Direção de arte / artistas freela  
- Agentes de geração de imagem (Imagine, etc.)  
- Programação (import, AnimationPlayer, spritesheets)  
- Estimativa de escopo por fase (VS → 3v3 → zona)

---



## 2. Direção de arte (não negociar)


| Princípio | Regra                                                                     |
| --------- | ------------------------------------------------------------------------- |
| Estilo    | **Estilizado**, não hiper-realista                                        |
| Leitura   | Silhueta legível a ~64–96 px no grid                                      |
| Combate   | O jogador identifica **classe, time e facing** em < 0,5 s                 |
| Animações | **Curtas** (0,15–0,45 s), sem travar o ritmo do turno                     |
| UI        | Limpa, alto contraste, sem ruído sobre o grid                             |
| Tom       | Fantasia sombria “fallen” — ruínas, aço, brasões gastos, não cartoon fofo |




### Referências de sensação (não copiar IP)

- Tactics clássico (leitura de tile + unidade)  
- Deckbuilders modernos (cartas com ícone + keyword clara)  
- Into the Breach / FFT: priorizar **clareza** sobre flôr



### Perspectiva (decisão de pipeline) — **TRAVADA: Isométrico 2:1**

| Opção | Status |
| ----- | ------ |
| Top-down ortogonal / 3/4 | **Descartado para arte final** (protótipo código ainda ortogonal) |
| **Isométrico 2:1** | **Escolhido** — diamante de chão largura:altura = 2:1 |

**Default de produção:** combate e zona em **isométrico 2:1**.

| Spec iso | Valor |
| -------- | ----- |
| Razão do tile | **2:1** (ex. diamante **128×64** ou **64×32**) |
| Grid lógico | Continua Vector2i(x,y); **render** em projeção iso |
| Facings de unidade | **4 dirs iso:** se, sw, 
w, 
e |
| Props altos | Wall/elevated com face vertical + topo iso |
| UI / cartas | Continuam **ortogonais** (não iso) |
| Custo | Maior que top-down — **proibido** misturar assets ortogonais no set de mundo |

**Dívida de engine:** VS atual usa grid ortogonal em TacticalGrid. Arte iso exige migração para TileMap isométrico Godot ou projeção manual. Detalhes em [ASSET_INSTRUCTIONS.md](ASSET_INSTRUCTIONS.md) § A2.

---

## 3. Specs técnicas globais

### 3.1 Unidades (combat / zone)

| Spec | Valor recomendado |
| ---- | ----------------- |
| Frame size | **96×96** ou **128×128** (personagem + sombra no diamante) |
| PPV no tile | Pés no **centro do diamante**; corpo ~1 tile de altura visual |
| Direções | **4 iso:** se, sw, 
w, 
e (mínimo P1: se+sw; ideal 4) |
| Formato | PNG com alpha; spritesheet ou atlas Godot |
| Pivot | Base dos pés no **centro do diamante** do tile |
| Outline | Contorno 1–2 px escuro **ou** silhueta forte (borda de time na engine) |
| Sombra | Elipse **achatada 2:1** sob os pés |

### 3.2 Tiles de terreno

| Spec | Valor |
| ---- | ----- |
| Forma | **Diamante 2:1** (não quadrado ortogonal) |
| Combat tile | **128×64** px recomendado (ou **64×32** pixel min) |
| Zone tile | Mesma razão 2:1 (ex. 128×64) |
| Variantes | 2–4 por tipo; arestas do diamante tileáveis |
| Layers | Ground · Props (Y-sort) · Overlay (highlight losango) |
| Elevated / wall | Extrusão vertical documentada (ex. +16 / +32 px) |

### 3.3 Cartas (UI)



| Spec                     | Valor                                                                       |
| ------------------------ | --------------------------------------------------------------------------- |
| Tamanho UI               | **140×200** lógicos (escala com resolução)                                  |
| Arte da carta            | Ícone **128×128** + frame reutilizável por tipo                             |
| Texto                    | Fora da textura (fonte dinâmica) — **nunca** bake de números finais na arte |
| Tipos com cor de moldura | ATK / DEF / MOV / CTL / BUF / DEB / ESP                                     |




### 3.4 VFX


| Spec    | Valor                                                          |
| ------- | -------------------------------------------------------------- |
| Formato | Spritesheet ou partículas Godot                                |
| Duração | 0,2–0,5 s                                                      |
| Cor     | Alta saturação pontual (dano vermelho, cura verde, block azul) |
| Regra   | VFX **não** esconde a silhueta da unidade por mais de 0,15 s   |




### 3.5 Nomenclatura de arquivos

```text
assets/
  units/{id}/
    {id}_{anim}_{dir}_{frame}.png
    # ou sheet: {id}_{anim}_{dir}.png
  tiles/combat/{tile_type}_{variant}.png   # diamante 128x64
  tiles/zone/{tile_type}_{variant}.png
  cards/icons/{card_id}.png                # UI continua ortogonal
  cards/frames/{frame_type}.png
  ui/{element}_{state}.png                 # UI ortogonal
  vfx/{vfx_id}_sheet.png
  portraits/{unit_id}.png
  foes/{id}/...
```

Exemplo: `units/espadachim/espadachim_idle_se_00.png`  
Dirs **iso:** `se` `sw` `nw` `ne`  
(Mapa lógico engine: E→se, S→sw, W→nw, N→ne — ver ASSET_INSTRUCTIONS)

---



## 4. Prioridade de produção (fases)

Alinha com a roadmap de gameplay.


| Fase                 | Conteúdo de arte                                                    | Meta                          |
| -------------------- | ------------------------------------------------------------------- | ----------------------------- |
| **A0 Placeholder++** | Cores, ícones simples, tiles flat                                   | Jogável e legível             |
| **A1 VS polido**     | 1 herói + 3 inimigos + 1 boss + tiles combat + set mínimo de cartas | Vertical Slice “apresentável” |
| **A2 3v3**           | +2 heróis, +inimigos 3v3, portraits, UI party                       | Combate de time               |
| **A3 Zona**          | Tiles de zona, token de party, patrulhas, ícones de POI             | Mapa vivo                     |
| **A4 Conteúdo**      | Classes extras, biomas, VFX por elemento                            | Escala                        |


**Regra de ouro:** não produzir 10 classes animadas antes de **A1** estar completo e legível.

---



## 5. Unidades — assets necessários



### 5.1 Lista VS (Fase A1) — **must have**


| ID               | Tipo    | Silhueta / leitura             | Cores-chave                |
| ---------------- | ------- | ------------------------------ | -------------------------- |
| `espadachim`     | Herói   | Lâmina, postura de duelo       | Azul aço `#4aa3ff`         |
| `goblin`         | Inimigo | Pequeno, agachado, flanqueador | Verde `#7cba5a`            |
| `orc`            | Inimigo | Largo, ombros, rusher          | Laranja-ferrugem `#c45c26` |
| `arqueiro`       | Inimigo | Arco, perfil alto              | Ouro sujo `#c9a227`        |
| `capitao`        | Boss    | Armadura + capa/elmo distinto  | Vermelho `#b33a3a`         |
| `goblin_reforco` | Reuso   | Pode recolor do goblin         | Verde mais escuro          |




### 5.2 Lista 3v3 (Fase A2)


| ID                      | Tipo             | Nota                                   |
| ----------------------- | ---------------- | -------------------------------------- |
| `guardiao`              | Herói tank       | Escudo grande, silhueta quadrada       |
| `patrulheiro` ou `mago` | Herói utilitário | Escolher 1 para o first 3v3            |
| `elite_pack_*`          | Inimigos         | 2–3 designs novos ou recolors com prop |




### 5.3 Zone (Fase A3)


| Asset         | Descrição                                                                 |
| ------------- | ------------------------------------------------------------------------- |
| `party_token` | 1 ícone de grupo no mapa (blob ou 3 mini-cabeças)                         |
| Patrulhas     | Versões **menores** iso (ou ícones diamante simplificados) |
| POI markers   | Ruína, altar, camp, mercador, portal (32×32 / 48×48)                      |




### 5.4 Classes futuras (só depois A2 estável)

Uma sheet completa por classe: Guardião, Assassino, Mago, Druida, Engenheiro, Necromante, Paladino, Bardo…  
**Não iniciar** até o pipeline de animação do Espadachim estar validado.

---



## 6. Animações por unidade (combat)



### 6.1 Set mínimo por unidade jogável / inimigo (A1)


| Anim                   | Frames (alvo) | Duração            | Loop             | Obrigatório?          |
| ---------------------- | ------------- | ------------------ | ---------------- | --------------------- |
| **idle**               | 4–6           | 0,8–1,2 s loop     | Sim              | **Sim**               |
| **idle_guard** (herói) | 2–4           | loop               | Sim              | Espadachim / tank     |
| **move** / walk        | 4–6           | 0,3–0,5 s por tile | Sim durante path | **Sim**               |
| **attack_melee**       | 4–6           | 0,25–0,4 s         | Não              | **Sim**               |
| **attack_ranged**      | 4–6           | 0,25–0,4 s         | Não              | Arqueiro / ranged     |
| **hit** / hurt         | 2–3           | 0,15–0,25 s        | Não              | **Sim**               |
| **block** / parry      | 3–4           | 0,2–0,3 s          | Não              | Heróis com defesa     |
| **death**              | 4–6           | 0,4–0,6 s          | Não              | **Sim**               |
| **victory** (herói)    | 4             | 0,5 s              | Não              | Nice-to-have          |
| **cast** / skill       | 4–6           | 0,3–0,45 s         | Não              | Magias / especiais    |
| **spawn**              | 3–4           | 0,3 s              | Não              | Reforços / invocações |


**Facing:** cada anim acima × **4 dirs** no set completo.  
**Atalho de produção A1:** idle/move/attack/hit/death em **2 dirs** (E/W) + flip horizontal se a arte permitir; N/S dedicados só no idle/attack.

### 6.2 Espadachim — set expandido (identidade)


| Anim            | Quando toca          | Nota de design              |
| --------------- | -------------------- | --------------------------- |
| idle            | Default              | Neutro (balance)            |
| idle_guard      | Postura Guarda       | Escudo/lâmina alta          |
| idle_offense    | Postura Ofensiva     | Lâmina baixa, agressivo     |
| attack_slash    | Golpe, Corte em Arco | Sweep                       |
| attack_thrust   | Estocada             | Linha                       |
| attack_charge   | Investida            | Dash + slash                |
| parry           | Parry sucesso        | Spark na lâmina             |
| skill_finisher  | Lâmina Final         | Telegráfo curto + hit forte |
| skill_challenge | Desafio              | Gesture + marca VFX         |




### 6.3 Boss Capitão — set


| Anim                               | Nota                           |
| ---------------------------------- | ------------------------------ |
| idle / move / attack / hit / death | Base                           |
| **phase_roar**                     | Transição fase 2/3 (0,5–0,8 s) |
| **push_attack**                    | Empurrão                       |
| **summon**                         | Chama reforço                  |


Boss pode ter **mais frames** e 1 telegráfo visual (flash no tile) antes do golpe pesado.

### 6.4 Timing com o gameplay

```text
Player joga carta
  → 0,05 s windup (opcional)
  → anim attack 0,25–0,4 s
  → VFX hit + número flutuante 0,2 s
  → unit hit flash
  → próximo input liberado (não esperar death de todos)
```

**Regra de engine:** animações são **cosméticas** sobre o state já resolvido (ou lock curto só no ativo).  
Multiplayer / replay: anim pode ser skippável (`settings.anim_speed`).

---



## 7. Tiles & mapa



### 7.1 Combat — set VS (A1)


| Tile             | Variantes                  | Notas visuais                     |
| ---------------- | -------------------------- | --------------------------------- |
| Grass            | 3                          | Base neutra                       |
| Stone            | 2                          | Caminho / pátio                   |
| Elevated         | 2                          | Borda de penhasco / rampa legível |
| Water            | 2 + anim opcional 2 frames | Mais escuro, brilho               |
| Wall             | 2                          | Bloqueia visão/path               |
| Pit              | 1–2                        | Buraco preto + borda perigo       |
| Highlight move   | 1 (engine)                 | Azul 40% alpha                    |
| Highlight attack | 1                          | Vermelho 40%                      |
| Highlight path   | 1                          | Amarelo                           |


**Overlays de engine (não precisam de artista full):** cursor, range, threat, trap.

### 7.2 Zone — set A3


| Tile / prop        | Função                |
| ------------------ | --------------------- |
| Road / path        | Movimento barato      |
| Forest dense       | Bloqueia ou ralentiza |
| River              | Bloqueio / ponte      |
| Ruin floor         | POI                   |
| Camp ground        | Spawn de pack         |
| Fog of war overlay | UI                    |
| Exit portal        | Objetivo              |


Props 1 tile: pedras, fogueira, estandarte, carreta, jaula.

### 7.3 Animações de terreno (prioridade baixa → média)


| Anim          | Frames     | Prioridade                 |
| ------------- | ---------- | -------------------------- |
| Water shimmer | 2–4 loop   | A1 nice / A2               |
| Fire / lava   | 3–4 loop   | Pós-VS elementos           |
| Poison cloud  | 3 loop     | Classe / bioma             |
| Bridge break  | 4 one-shot | Boss / evento              |
| Forest burn   | 4–6        | Interação terreno avançada |


---



## 8. Cartas — assets



### 8.1 Estrutura visual da carta

```text
┌──────────────┐
│  [custo]     │  ← número dinâmico
│              │
│   [ícone]    │  ← arte 128²
│              │
│  NOME        │  ← fonte
│  keywords    │
│  texto rules │
│  [tipo]      │  ← cor da moldura
└──────────────┘
```



### 8.2 Frames (reuso)


| Frame                           | Uso                  |
| ------------------------------- | -------------------- |
| `frame_attack`                  | Vermelho/cobre       |
| `frame_defense`                 | Azul                 |
| `frame_movement`                | Verde                |
| `frame_control`                 | Roxo                 |
| `frame_buff`                    | Dourado claro        |
| `frame_debuff`                  | Verde-doente         |
| `frame_special`                 | Ouro/preto           |
| `frame_rare` / `frame_upgraded` | Borda extra (depois) |




### 8.3 Ícones — VS Espadachim (must)

Uma arte de ícone por **card_id** (pode ser símbolo + arma, não full illustration no MVP):


| card_id                 | Ideia de ícone               |
| ----------------------- | ---------------------------- |
| passo_combate           | Botas / pegada               |
| sprint                  | Rajada / vento               |
| investida               | Capacete + seta              |
| golpe                   | Espada diagonal              |
| corte_arco              | Arco de lâmina               |
| estocada                | Ponta de espada              |
| parry                   | Cruz de lâminas              |
| guarda_alta             | Escudo alto                  |
| finta                   | Máscara / sombra             |
| pressao                 | Mão empurrando               |
| quebra_guarda           | Escudo rachado               |
| giro                    | Redemoinho                   |
| desafio                 | Luva / duelo                 |
| respiracao              | Peito / ar                   |
| lamina_final            | Espada brilho                |
| ofensiva                | Olho vermelho / lâmina baixa |
| quebra extras de reward | Mesma pipeline               |


**A1 mínimo absoluto:** 1 frame genérico + **16 ícones monocromáticos** (mesmo se placeholders estilizados).  
**A2:** ilustrações full opcionais nas rares.

### 8.4 Animações de carta (UI)


| Anim          | Descrição                       | Prioridade |
| ------------- | ------------------------------- | ---------- |
| draw          | Carta sobe do deck para a mão   | A1         |
| play          | Carta sobe ao centro e dissolve | A1         |
| discard       | Carta vai ao descarte           | A1         |
| hover         | Lift 4 px + glow                | A1         |
| unplayable    | Shake ou desaturar              | A1         |
| upgrade flash | Brilho ao mutar (equip)         | A2         |


---



## 9. UI / HUD



### 9.1 Combat HUD — peças


| Elemento             | Asset                      | Estados                             |
| -------------------- | -------------------------- | ----------------------------------- |
| Timeline pip         | Ícone circular             | player / enemy / active             |
| Portrait strip       | 64×64 crop                 | normal / active / dead / low HP     |
| Energy pip           | ⚡ orbe                     | full / empty                        |
| HP bar               | 9-slice                    | ally / enemy / boss                 |
| Block shield icon    | 32×32                      | on/off                              |
| Stance icons         | 32×32                      | balance / guard / offense           |
| End turn button      | 9-slice                    | normal / hover / pressed / disabled |
| Log panel            | 9-slice dark               | —                                   |
| Targeting cursor     | 32–64                      | move / attack / invalid             |
| Floating combat text | fonte + estilo             | dmg / heal / block / miss / crit    |
| Turn banner          | “Seu turno” / nome inimigo | A1                                  |




### 9.2 Zone HUD — peças (A3)


| Elemento             | Nota                    |
| -------------------- | ----------------------- |
| Minimap              | Opcional no MVP de zona |
| Activity panel       | Ícone + 2 botões        |
| Contact modal        | Lutar / Fugir           |
| Movement points pips | Como energia            |




### 9.3 Menus (depois do combate legível)

Title · Party select · Reward pick · Level-up pick · Game over · Settings  
Cada um: background, botões 9-slice, ícones de confirmação/cancelar.

### 9.4 Animações de UI


| Anim                            | Duração   | Prioridade |
| ------------------------------- | --------- | ---------- |
| Banner de turno                 | 0,4 s     | A1         |
| HP bar drain                    | 0,2–0,3 s | A1         |
| Energy spend pop                | 0,15 s    | A1         |
| Reward panel slide-in           | 0,3 s     | A1         |
| Screen shake (hit forte / boss) | 0,1–0,2 s | A1         |
| Flash branco de hit             | 0,05 s    | A1         |


---



## 10. VFX de combate (lista)



### 10.1 Core (A1)


| ID                   | Uso                | Frames / tipo    |
| -------------------- | ------------------ | ---------------- |
| `slash_arc`          | Golpes melee       | 4–6 sheet        |
| `thrust_line`        | Estocada           | 3–4              |
| `impact_hit`         | Qualquer dano      | 3–4 + partículas |
| `impact_block`       | Dano absorvido     | 3 + spark azul   |
| `parry_spark`        | Parry              | 4                |
| `dust_move`          | Ao entrar no tile  | 3                |
| `death_poof`         | Morte small        | 5                |
| `status_vulnerable`  | Ícone sobre cabeça | 2 loop           |
| `status_marked_duel` | Marca de Desafio   | 2 loop           |
| `tile_danger`        | Pit / threat       | pulse engine     |




### 10.2 Expandido (A2+)


| ID                                      | Uso                 |
| --------------------------------------- | ------------------- |
| `fire_hit` / `ice_hit` / `poison_cloud` | Elementos           |
| `heal_cross` / `shield_gain`            | Suporte             |
| `push_whoosh`                           | Empurrão            |
| `summon_circle`                         | Invocação / reforço |
| `buff_up` / `debuff_down`               | Setas de status     |
| `crit_flash`                            | Costas / crítico    |




### 10.3 Feedback sem sprite (engine — implementar cedo)

Mesmo sem arte final:

- Tint vermelho no hit  
- Knockback de 2–4 px  
- Número flutuante  
- Highlight de tiles  
- Camera punch no finisher

Isso **já melhora** o VS atual antes dos sheets.

---



## 11. Portraits & marketing


| Asset                | Spec               | Quando                |
| -------------------- | ------------------ | --------------------- |
| Portrait combate     | 128×128 ou 256×256 | A2 (3 heróis)         |
| Portrait carta herói | 256²               | Select de party       |
| Key art              | 1920×1080          | Store / title         |
| Ícone do jogo        | 512² + Godot icon  | Já existe SVG simples |
| Class select splash  | 1 por classe       | Conteúdo full         |


---



## 12. Áudio (parceiro de animação)

Não é sprite, mas **ancora** animação. Lista mínima:


| Evento                   | Tipo   | Prioridade |
| ------------------------ | ------ | ---------- |
| SFX UI click / play card | UI     | A1         |
| SFX slash / hit / block  | Combat | A1         |
| SFX footstep (leve)      | Move   | A2         |
| SFX death                | Combat | A1         |
| SFX boss roar            | Boss   | A1         |
| BGM combat               | Loop   | A2         |
| BGM zone                 | Loop   | A3         |
| SFX reward               | UI     | A1         |


Animações devem ter **event markers** no frame de impacto (para spawnar SFX/VFX).

---



## 13. Quantidade estimada (ordem de grandeza)



### Fase A1 — VS apresentável


| Categoria                      | Qtd aproximada           |
| ------------------------------ | ------------------------ |
| Unidades com set anim mínimo   | 5 (hero + 3 foes + boss) |
| Anims × dirs (com atalho flip) | ~5–7 anims × 2–4 dirs    |
| Tiles combat únicos            | ~12–20 (com variantes)   |
| Ícones de carta                | ~16–20                   |
| Frames de carta                | 6–8                      |
| VFX core                       | 8–10                     |
| UI pieces                      | 15–25                    |
| SFX                            | 12–20                    |




### Fase A2 — 3v3

+2 heróis full set · +2–4 inimigos · portraits · UI party · 10+ ícones novos  

### Fase A3 — Zona

+1 tileset zone · party token · 6–10 POI icons · map enemy icons · 1 painel de atividade  

---



## 14. Pipeline de produção recomendado

```text
1. Diamante 128×64 de referência + silhueta P&B da unidade no centro
2. Paleta travada (max ~12 cores por sprite + outline)
3. Idle SE (+ SW); test pivot no centro do diamante
4. Attack + hit + death (SE)
5. Move loop
6. Dirs NE/NW se necessário
7. VFX no frame de impacto (iso-friendly)
8. Polish (sombra 2:1, dust, Y-sort check)
```



### Checklist de aceite por sprite

- [ ] Legível no diamante 128×64 (ou 64×32) com zoom 1.0  
- [ ] Perspectiva **2:1 consistente** (não ortogonal misturado)  
- [ ] Não confunde com tile de chão  
- [ ] Ally vs enemy distinguível (cor + borda engine)  
- [ ] Facing iso claro (`se/sw/nw/ne`)  
- [ ] Pés no centro do diamante; sombra iso 2:1  
- [ ] Loop de idle sem “pulo” de frame  
- [ ] Attack tem frame de impacto óbvio  
- [ ] Y-sort: topo do sprite não “fura” tiles vizinhos de forma errada  



### Ferramentas sugeridas


| Uso                      | Ferramenta                               |
| ------------------------ | ---------------------------------------- |
| Pixel / low-res stylized | Aseprite, LibreSprite                    |
| Vetorial estilizado      | Affinity / Illustrator → export PNG      |
| Sheets                   | Aseprite export / TexturePacker          |
| Engine                   | Godot AnimatedSprite2D / AnimationPlayer |
| VFX                      | Godot GPUParticles2D + sheets curtos     |


---



## 15. Integração com Godot (contrato para programação)


| Sistema        | Asset esperado                                                    |
| -------------- | ----------------------------------------------------------------- |
| `BattleUnit`   | `AnimatedSprite2D` com animações nomeadas `idle_e`, `attack_e`, … |
| Facing change  | Troca sufixo `_n/_e/_s/_w` ou flip                                |
| `TacticalGrid` | TileMapLayer ou draw com textures                                 |
| Cards UI       | TextureRect ícone + Panel frame                                   |
| VFX            | cena `HitVfx.tscn` spawn em world pos                             |
| Skip anim      | `GameSettings.battle_anim_scale` 0–2                              |


**Convenção de nome de anim no engine:**

```text
{state}_{dir}
idle_se, move_ne, attack_sw, hit_nw, death_se, cast_se, block_se
```

---



## 16. O que NÃO fazer (controle de escopo)


| Evitar | Por quê |
| ------ | ------- |
| Tiles/unidades ortogonais misturados com iso 2:1 | Quebra leitura e pipeline |
| 8 direções × 12 anims × 10 classes no dia 1 | Mata o projeto |
| Cinemáticas longas no meio do turno         | Quebra pacing de deckbuilder |
| Hiper-detalhe em 64px                       | Vira lama; perde silhueta    |
| Texto bakeado em idioma na textura da carta | Quebra i18n                  |
| Animar tudo antes do idle legível           | Prioridade invertida         |
| VFX que cobrem o grid inteiro               | Jogador perde posição        |


---



## 17. Backlog priorizado (checklist de produção)



### P0 — Agora (ainda com placeholders melhorados)

- [ ] Cores de time + outline na engine  
- [ ] Floating damage numbers  
- [ ] Flash de hit + small knockback  
- [ ] Ícones de postura (mesmo geométricos)  
- [ ] Tiles com textura flat distinta (não só flat color se possível)  



### P1 — Set A1 (VS apresentável)

- [ ] Espadachim: idle, move, attack, hit, death (E/W mínimo)  
- [ ] Goblin, Orc, Arqueiro: mesmo set  
- [ ] Capitão: set + phase_roar  
- [ ] Tiles combat set  
- [ ] 16 ícones de carta + frames por tipo  
- [ ] VFX slash/impact/block/death  
- [ ] SFX core  
- [ ] UI buttons + HP/energy  



### P2 — A2 3v3

- [ ] 2 heróis adicionais full set  
- [ ] Portraits  
- [ ] Timeline portraits  
- [ ] Deployment arrows / zones  



### P3 — A3 Zona

- [ ] Tileset zona  
- [ ] Party token  
- [ ] POI icons + 1 painel  
- [ ] Map enemy icons  
- [ ] BGM zona  



### P4 — Conteúdo largo

- [ ] Classes restantes  
- [ ] Biomas (tiles + palette swap)  
- [ ] VFX elementais  
- [ ] Key art / store  

---



## 18. Paleta base sugerida (travar cedo)


| Uso              | Hex (proposta) |
| ---------------- | -------------- |
| UI fundo         | `#1a1420`      |
| UI painel        | `#2a2430`      |
| Texto            | `#e8e4ef`      |
| Ally             | `#4aa3ff`      |
| Enemy            | `#e85d4c`      |
| Move highlight   | `#3d9eff66`    |
| Attack highlight | `#ff5a4a66`    |
| XP / reward gold | `#c9a227`      |
| Grass            | `#2d4a3e`      |
| Stone            | `#4a4a52`      |
| Danger / pit     | `#0d0a10`      |


Cada unidade: 1 cor de identidade + neutros + outline.

---



## 19. Critérios de sucesso (arte)

A arte está “pronta o bastante” quando playtesters:

1. Apontam o **flanqueador** sem ler o nome
2. Sabem quem está de **costas**
3. Entendem o **tipo da carta** pela cor/ícone antes do texto
4. Sentem o **impacto** do golpe (anim + VFX + SFX + número)
5. Não reclamam que “não dá pra ver o chão / a unidade”

---



## 20. Resumo executivo


| Camada   | Mínimo para o jogo “parecer Fallen Tactics” |
| -------- | ------------------------------------------- |
| Unidades | 5 characters, 5 anims, 2–4 dirs             |
| Tiles    | 6 tipos combat + highlights                 |
| Cartas   | Frames por tipo + ícone por card            |
| VFX      | Hit, slash, block, death                    |
| UI       | Mão, timeline, HP, end turn, rewards        |
| Áudio    | Hits + UI + 1 boss sting                    |


**Ordem:** legibilidade no grid → feedback de combate → identidade de classe → volume de conteúdo.

---

*Documento vivo. Quando o primeiro spritesheet real entrar no repo, atualizar a seção “Estado atual” e marcar checkboxes P0/P1.*