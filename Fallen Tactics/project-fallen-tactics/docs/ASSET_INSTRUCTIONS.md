# Instruções Detalhadas por Asset — Project Fallen Tactics

**Versão:** 1.1  
**Última atualização:** 2026-08-01  
**Perspectiva travada:** **Isométrico 2:1** (mundo/combate). UI e cartas permanecem ortogonais.  
**Para:** artistas, freelas, agentes de geração de imagem, programadores de import  

Documentos irmãos:

- [`ASSETS_AND_ANIMATIONS.md`](ASSETS_AND_ANIMATIONS.md) — visão e prioridade  
- [`P1_PRODUCTION_CHECKLIST.md`](P1_PRODUCTION_CHECKLIST.md) — checklist  
- [`P1_production_sheet.csv`](P1_production_sheet.csv) — tracking  

---

## Como usar este documento

Para **cada asset**:

1. Leia a **seção global** (estilo, specs, proibições).  
2. Abra a ficha do asset (ID `U-ESP-IDLE`, `C-ICO-golpe`, etc.).  
3. Produza seguindo **prompt visual**, **frames**, **export** e **aceite**.  
4. Salve no **path** indicado.  
5. Atualize o CSV: `todo` → `done` → `ingame` (quando plugado no Godot).  

### Status P0 vs P1

| Prioridade | Quem faz | Onde está |
|------------|----------|-----------|
| **P0** | Código (já feito) | Engine — **não precisa de arquivo de arte** |
| **P1** | Arte | Pastas em `assets/` — **instruções abaixo** |

---

# PARTE A — Regras globais (ler antes de qualquer asset)

## A1. Estilo visual obrigatório

| Regra | Detalhe |
|-------|---------|
| Estilo | **Estilizado / painterly-low** ou **pixel clean** — escolha **um** pipeline e mantenha em **todo** o P1 |
| Realismo | **Proibido** foto-realismo, skin pores, raytracing |
| Tom | Fantasia sombria “fallen”: aço gasto, ruínas, pouca saturação no ambiente, acentos fortes nas armas/VFX |
| Silhueta | Tem que ser legível em **preto puro** (teste: preencher de preto e ainda reconhecer a unidade) |
| Contorno | Outline escuro 1–2 px **ou** sombra de valor forte; a engine também desenha borda de time (azul/vermelho) |
| Leitura tática | Em 0,5 s: **quem é**, **aliado/inimigo** (cor), **para onde olha** |
| Cartoon fofo | **Não** (sem olhos grandes, sem chibi) |

### Pipeline recomendado (escolha um)

**Opção A — Pixel art iso (preferida para tactics legível)**  
- Unidade: canvas **96×96** ou **128×128** por frame  
- Tile: diamante **128×64** (ou **64×32**)  
- Paleta limitada (~12–16 cores por sprite + outline)  
- Filter: **Nearest** no Godot  

**Opção B — Painted soft iso**  
- Unidade: canvas **128×128**  
- Tile: diamante **128×64** ou **256×128**  
- Shapes grandes, menos detalhe facial  
- Filter: **Linear** com cuidado para não “derreter” o diamante  

**Não misture** pixel e painted no mesmo set.  
**Não misture** top-down ortogonal com iso no mesmo bioma.

## A2. Perspectiva e câmera — **Isométrico 2:1 (OBRIGATÓRIO)**

### O que é 2:1 neste projeto

- O **chão** é um **losango (diamante)** cuja largura é o **dobro** da altura.  
- Exemplo canônico: tile **128 px de largura × 64 px de altura**.  
- Personagens ficam **em pé** no centro do diamante; não são “deitados” no chão.  

### Fórmulas de projeção (referência engine)

Com tile W=128, H=64:

```text
screen_x = (cell.x - cell.y) * (W/2)
screen_y = (cell.x + cell.y) * (H/2)
```

### Regras de desenho

- Sombra: elipse **achatada 2:1** sob os pés, alinhada ao diamante.  
- Facing: personagem **olha** ao longo de uma das 4 diagonais iso.  
- **Proibido** tiles quadrados ortogonais “vistos de cima” para o chão de combate.  
- **UI, cartas, ícones de carta, menus:** continuam **ortogonais** (não forçar iso no HUD).

### Mapa de facing: lógico → arquivo iso

| Facing lógico (código N/E/S/W) | Código de arquivo | Aparência típica no ecrã |
| ------------------------------ | ----------------- | ------------------------ |
| EAST | `se` | Sudeste (baixo-direita) |
| SOUTH | `sw` | Sudoeste (baixo-esquerda) |
| WEST | `nw` | Noroeste (cima-esquerda) |
| NORTH | `ne` | Nordeste (cima-direita) |

> Ao plugar no Godot: mapear `BattleUnit.Facing` → sufixo `se/sw/nw/ne`.

### Diagrama mental

```text
        N (ne)
         /\
   W    /  \    E
  (nw) /    \  (se)
       \    /
        \  /
         \/
        S (sw)
```

Unidades no **centro** do diamante. Y-sort por `screen_y` dos pés.

### Dívida do protótipo atual

O VS em código ainda usa **grid ortogonal 64×64**. Até migrar:

1. Produzir arte **já em iso 2:1** (não produzir lote ortogonal).  
2. Engine: `TacticalGrid` → TileMap isométrico Godot ou projeção manual.  
3. Placeholders P0 atuais são ortogonais — **temporários**.

## A3. Direções (facing iso)

| Código | Direção iso | Notas |
|--------|-------------|-------|
| `se` | Sudeste | **Produza primeiro** (default do herói) |
| `sw` | Sudoeste | Segundo prioritário |
| `ne` | Nordeste | Costas / aproximação “de cima” no ecrã |
| `nw` | Noroeste | Completa o set de 4 |

**Mínimo P1:** `se` + `sw` em idle/move/attack/hit/death.  
**Ideal P1:** 4 dirs em idle + attack.  
**Flip:** espelhar `se`↔`sw` só se arma/escudo não inverterem o lado errado.

## A4. Canvas, pivot e margem

| Tipo | Canvas | Pivot | Margem |
|------|--------|-------|--------|
| Unidade combat | **128×128** (rec.) ou 96×96 | Pés no centro horizontal, ~55–65% da altura | ≥4 px |
| Tile combat | **128×64** diamante | Centro do diamante | Alpha **fora** do losango |
| Tile combat (pixel min) | **64×32** diamante | Centro | Idem |
| Ícone de carta | **128×128** | Centro | Ortogonal ≥8 px |
| Frame de carta | **280×400** / 140×200 | Centro | Ortogonal |
| VFX sheet | 64×64 ou 128×128 / frame | Centro do impacto | Alpha limpo |
| UI icon | 32×32 / 64×64 | Centro | Ortogonal |
| Highlight tile | **128×64** losango | Centro | Só área do diamante |

**Pivot de unidade:** base dos pés no **centro do tile iso**.

## A5. Formato de export

| Campo | Valor |
|-------|--------|
| Formato | PNG-24 + alpha |
| Compressão | Sem lossy; sem JPEG |
| Nome | minúsculas, underscore, sem espaço, sem acento |
| Folha vs frames | Preferir **spritesheet horizontal** por anim+dir **ou** frames ` _00`, `_01`… |
| FPS alvo anim | idle 6–8 FPS · attack 12–16 FPS · hit 12 FPS · death 10–12 FPS |

### Nomenclatura

```text
{id}_{anim}_{dir}.png          # sheet: frames em linha
{id}_{anim}_{dir}_{frame}.png  # frames soltos: 00, 01, 02…
```

Exemplos:

```text
assets/units/espadachim/espadachim_idle_e.png
assets/units/espadachim/espadachim_attack_slash_e_00.png
assets/tiles/combat/grass_01.png
assets/cards/icons/golpe.png
assets/vfx/slash_arc_sheet.png
```

## A6. Paleta de identidade (unidades)

| Unidade | Cor primária | Secundária | Evitar |
|---------|--------------|------------|--------|
| Espadachim | Azul aço `#4aa3ff` | Cinza metal `#8a93a0` | Verde (confunde com goblin) |
| Goblin | Verde `#7cba5a` | Marrom sujo | Azul aliado |
| Orc | Ferrugem `#c45c26` | Couro escuro | Azul |
| Arqueiro | Ouro sujo `#c9a227` | Verde oliva capa | Vermelho boss |
| Capitão | Vermelho `#b33a3a` | Preto armadura, dourado velho | Azul hero |

**UI fundo ambiente:** `#1a1420` / `#2a2430` — sprites devem contrastar com isso.

## A7. Proibições gerais

- Texto, números ou letras **dentro** do sprite de carta/ícone (custo e nome são da engine).  
- Watermark, logo de IA, assinatura grande.  
- Fundo opaco nos sprites de unidade/VFX/ícone (sempre **alpha**).  
- Tiles **ortogonais** misturados ao set **iso 2:1** (proibido).  
- Animações &gt; 0,6 s em attack (exceto death ≤ 0,6 s e boss roar ≤ 0,8 s).  
- Nudez, gore extremo (jogo tático; sangue **mínimo** / stylized se houver).  

## A8. Teste de aceite (todo asset de unidade)

Antes de marcar `done`:

1. [ ] Unidade sobre diamante 128×64 (ou 64×32) — ainda reconhece?  
2. [ ] Versão silhueta preta — ainda reconhece?  
3. [ ] Colocar sobre tile grass e stone — não some?  
4. [ ] Facing `se` vs `ne` — dá para ver diferença de costas?  
5. [ ] Loop idle — primeiro e último frame encaixam?  
6. [ ] Attack — **frame de impacto** óbvio (arma no alvo)?  
7. [ ] Nome de arquivo correto + alpha limpo (sem halo branco)?  

---

# PARTE B — Unidades (combat)

## B0. Template de animação (aplicar a todas)

### `idle`

| Campo | Instrução |
|-------|-----------|
| Frames | 4–6 |
| Loop | Sim |
| Movimento | Respiração leve (1–2 px ombros/peito); **pés fixos no pivot** |
| Proibido | Andar no lugar, piscar exagerado, idle “dançando” |
| Duração loop | ~0,8–1,2 s |

### `move`

| Campo | Instrução |
|-------|-----------|
| Frames | 4–6 |
| Loop | Sim enquanto atravessa tiles |
| Movimento | Ciclo de passada curto; corpo inclina levemente na direção |
| Contato solo | Pelo menos 1 frame com pé “plantado” |
| Duração | ~0,35–0,5 s por ciclo (engine controla slides entre tiles) |

### `attack` (melee genérico)

| Campo | Instrução |
|-------|-----------|
| Frames | 4–6 |
| Loop | Não |
| Estrutura | 1 anticipation → 2–3 swing → 1 impact pose → 1 recovery curto |
| Impacto | Marcar frame (ex. frame 3) para VFX/SFX |
| Arma | Deve “atravessar” o espaço à frente do personagem |

### `hit`

| Campo | Instrução |
|-------|-----------|
| Frames | 2–3 |
| Pose | Recuo, flash opcional na arte, arma baixa |
| Rápido | 0,15–0,25 s total |

### `death`

| Campo | Instrução |
|-------|-----------|
| Frames | 4–6 |
| Loop | Não; último frame pode ser corpo no chão **ou** dissolve (se VFX death_poof existir, corpo some no fim) |
| Legibilidade | Silhueta ainda clara nos 2 primeiros frames |

### `attack_ranged` (arqueiro)

| Campo | Instrução |
|-------|-----------|
| Frames | 4–6 |
| Estrutura | Preparar arco → full draw → release → recovery |
| Projétil | **Não** desenhar a flecha voando na sheet da unidade (VFX separado depois); no release, corda solta |

---

## B1. Espadachim (`espadachim`) — herói VS

**ID pasta:** `assets/units/espadachim/`  
**Fantasy:** duelista de runas/aço; postura muda o corpo.  
**Corpo:** humano médio, armadura leve de peito, espada de uma mão (lâmina reta), capa curta ou sem capa (evitar capa longa cobrindo silhueta).  
**Rosto:** opcional a 96px; priorizar capacete aberto ou cabelo + mandíbula.  
**Identidade:** silhueta “triângulo de lâmina” — ombros diagonais, espada legível.

### Prompt base (todas as anims)

> Stylized fantasy tactical RPG unit sprite, true isometric 2:1 view (diamond floor, width twice height), swordsman duelist, steel-blue accents (#4aa3ff), light armor, straight one-handed sword, strong silhouette, dark outline, transparent background, game asset, not chibi, not realistic photo, readable at 64 pixels

### Fichas por animação

#### `U-ESP-IDLE` — `espadachim_idle_{dir}  # dir = se|sw|nw|ne`

| | |
|--|--|
| **Arquivo** | `espadachim_idle_se.png` (+ sw/nw/ne) |
| **Frames** | 4–6 |
| **Pose** | Postura **Equilíbrio**: espada baixa à frente ou ao lado da perna, guarda neutra, pés afastados estáveis |
| **Loop** | Respiração sutil |
| **Aceite** | Não parece ofensivo nem full defensa |

#### `U-ESP-IDLE-G` — `espadachim_idle_guard_{dir}  # dir = se|sw|nw|ne`

| | |
|--|--|
| **Arquivo** | `espadachim_idle_guard_se.png` |
| **Frames** | 2–4 |
| **Pose** | **Guarda Alta**: espada ou antebraço elevado cobrindo o tronco, centro de gravidade baixo, peito fechado |
| **Diferença** | Deve ser **óbvia** vs idle neutro em thumbnail |
| **Cor** | Pode puxar highlight azulado frio |

#### `U-ESP-IDLE-O` — `espadachim_idle_offense_{dir}  # dir = se|sw|nw|ne`

| | |
|--|--|
| **Arquivo** | `espadachim_idle_offense_se.png` |
| **Frames** | 2–4 |
| **Pose** | **Ofensiva**: espada recuada pronta para golpe, tronco aberto, peso na perna da frente |
| **Cor** | Acento quente sutil (não vira orc) |

#### `U-ESP-MOVE` — `espadachim_move_{dir}  # dir = se|sw|nw|ne`

| | |
|--|--|
| **Arquivo** | `espadachim_move_se.png` |
| **Frames** | 4–6 |
| **Pose** | Passo de combate (não corrida desesperada); espada controlada |
| **Nota** | Usado por Passo de Combate / reposicionamento |

#### `U-ESP-ATK-S` — `espadachim_attack_slash_{dir}  # dir = se|sw|nw|ne`

| | |
|--|--|
| **Arquivo** | `espadachim_attack_slash_se.png` |
| **Frames** | 4–6 |
| **Uso** | Golpe, Corte em Arco |
| **Motion** | Corte **diagonal ou horizontal** amplo; arco de lâmina legível |
| **Impact frame** | Meio do arco, lâmina à frente do corpo |

#### `U-ESP-ATK-T` — `espadachim_attack_thrust_{dir}  # dir = se|sw|nw|ne`

| | |
|--|--|
| **Arquivo** | `espadachim_attack_thrust_se.png` |
| **Frames** | 4–6 |
| **Uso** | Estocada |
| **Motion** | Linha reta: ombro + ponta da espada no eixo do facing |
| **Diferença** | Silhueta alongada no impacto (não confundir com slash) |

#### `U-ESP-ATK-C` — `espadachim_attack_charge_{dir}  # dir = se|sw|nw|ne`

| | |
|--|--|
| **Arquivo** | `espadachim_attack_charge_se.png` |
| **Frames** | 4–6 |
| **Uso** | Investida |
| **Motion** | Corpo inclinado, joelho à frente, espada pronta; frame final = slash ou shoulder check |
| **Extra** | Motion lines leves ok; sem cobrir o corpo inteiro |

#### `U-ESP-PARRY` — `espadachim_parry_{dir}  # dir = se|sw|nw|ne`

| | |
|--|--|
| **Arquivo** | `espadachim_parry_se.png` |
| **Frames** | 3–4 |
| **Uso** | Reação Parry |
| **Pose** | Lâmina vertical/diagonal bloqueando à frente; ombro fechado |
| **Impact** | Frame com “choque” (pode combinar com VFX parry_spark) |

#### `U-ESP-HIT` — `espadachim_hit_{dir}  # dir = se|sw|nw|ne`

| | |
|--|--|
| **Arquivo** | `espadachim_hit_se.png` |
| **Frames** | 2–3 |
| **Pose** | Recuo, espada desestabilizada, sem morte |

#### `U-ESP-DEATH` — `espadachim_death_se`

| | |
|--|--|
| **Arquivo** | `espadachim_death_se.png` |
| **Frames** | 4–6 |
| **Dirs** | Só `se` ok no P1 |
| **Pose** | Cai de joelhos ou dissolve — **digno**, não cômico |

#### `U-ESP-FIN` — `espadachim_skill_finisher_se`

| | |
|--|--|
| **Arquivo** | `espadachim_skill_finisher_se.png` |
| **Frames** | 4–6 |
| **Uso** | Lâmina Final |
| **Motion** | Anticipation longa (1–2 frames) + golpe poderoso; brilho na lâmina no impact |
| **Leitura** | “Isso é o especial” mesmo sem VFX |

---

## B2. Goblin (`goblin`) — flanker

**Pasta:** `assets/units/goblin/`  
**Fantasy:** pequeno, curvado, adaga ou faca curta, postura de quem contorna.  
**Tamanho:** **~70% da altura** do Espadachim no mesmo canvas (importante para leitura de “fodinha”).  
**Cor:** verde `#7cba5a`, olhos amarelos mínimos.

### Prompt base

> Small goblin skirmisher, hunched posture, short dagger, green skin #7cba5a, dirty leather, stylized tactical RPG sprite true isometric 2:1, strong silhouette, transparent BG, readable at 64px, not cute chibi

### Set mínimo `U-GOB-SET`

| Anim | Arquivo | Frames | Instrução específica |
|------|---------|--------|----------------------|
| idle | `goblin_idle_{dir}` | 4 | Agachado, olha de soslaio, faca pronta |
| move | `goblin_move_{dir}` | 4 | Passos rápidos curtos, quase rastejando |
| attack | `goblin_attack_{dir}` | 4 | Facada baixa / lateral (flanco) |
| hit | `goblin_hit_{dir}` | 2–3 | Recuo exagerado leve |
| death | `goblin_death_e` | 4 | Cai enrolado |

**Aceite de silhueta:** ao lado do orc, deve parecer **claramente menor**.

**Recolor:** `goblin_r` (reforço) pode ser o mesmo sprite com hue shift mais escuro (feito na engine se necessário).

---

## B3. Orc (`orc`) — rusher

**Pasta:** `assets/units/orc/`  
**Fantasy:** largo, ombros enormes, clava ou machado pesado, avanço frontal.  
**Tamanho:** **~110%** da largura do espadachim; altura similar ou um pouco maior.  
**Cor:** ferrugem `#c45c26`.

### Prompt base

> Bulky orc warrior, wide shoulders, heavy axe or club, rust-orange armor accents #c45c26, aggressive forward pose, stylized tactical sprite true isometric 2:1, transparent BG, strong silhouette, not photoreal

### Set `U-ORC-SET`

| Anim | Instrução |
|------|-----------|
| idle | Peso nos calcanhares, arma no ombro ou baixa |
| move | Passo pesado (pouco bounce; “peso”) |
| attack | Overhead ou horizontal **largo** (telegráfo legível) |
| hit | Pouco recuo (tanque) |
| death | Queda pesada para frente/lado |

**Aceite:** em idle, “esse cara avança em linha reta”.

---

## B4. Arqueiro (`arqueiro`)

**Pasta:** `assets/units/arqueiro/`  
**Fantasy:** humanoide magro, arco longo, aljava, capa curta ocre `#c9a227`.  
**Silhueta:** vertical + curva do arco no lado.

### Prompt base

> Lean fantasy archer, longbow, quiver, dirty gold cloak #c9a227, true isometric 2:1 tactical sprite, clear bow silhouette, transparent background, stylized

### Set `U-ARC-SET`

| Anim | Instrução |
|------|-----------|
| idle | Arco baixo ou em guarda parcial |
| move | Passo leve; arco não “atravessa” o corpo de forma confusa |
| attack_ranged | Draw → release (sem flecha em voo) |
| hit | Recuo, arco desestabilizado |
| death | 4 frames |

**Facing:** arco deve ajudar a ler a direção (corda/arco alinhados).

---

## B5. Capitão (`capitao`) — boss

**Pasta:** `assets/units/capitao/`  
**Fantasy:** oficial caído, armadura de placas com capa rasgada, elmo com crista ou ombreiras grandes, espada larga ou alabarda curta.  
**Escala:** **~15–20% maior** que heróis (mesmo canvas, personagem maior).  
**Cor:** vermelho `#b33a3a` + metal escuro + ouro velho.

### Prompt base

> Fallen army captain boss, heavy armor, torn crimson cape #b33a3a, commanding silhouette larger than normal units, stylized tactical true isometric 2:1 sprite, transparent BG, intimidating, not cute

### Set base `U-CAP-SET`

| Anim | Instrução |
|------|-----------|
| idle | Imponente, arma apontada ou no chão como bengala de mando |
| move | Passo de comando (não corre) |
| attack | Golpe de oficial — telegráfo 1 frame a mais que lacaio |
| hit | Resiste; pouco stagger |
| death | Dramático; 5–6 frames ok |

### `U-CAP-ROAR` — `capitao_phase_roar_se`

| | |
|--|--|
| **Frames** | 4–6 |
| **Uso** | Fase 2/3 |
| **Pose** | Braços abertos / grito / capa aberta; flash de autoridade |
| **Duração** | Até 0,8 s |
| **Sem** | Transformação completa de design (mesmo personagem, mais fúria) |

### `U-CAP-PUSH` — `capitao_push_attack_{dir}`

| | |
|--|--|
| **Frames** | 4 |
| **Motion** | Escudo ou ombro / palmada de arma empurrando à frente |
| **Leitura** | “Knockback”, não slash comum |

### `U-CAP-SUM` — `capitao_summon_se`

| | |
|--|--|
| **Frames** | 4 |
| **Pose** | Gesto de chamar (braço erguido, estandarte mental) |
| **VFX** | Círculo de summon é asset VFX separado depois |

---

# PARTE C — Tiles de combate

**Pasta:** `assets/tiles/combat/`  
**Tamanho:** diamante **128×64** px (padrão) ou **64×32** (pixel min)  
**Forma:** losango 2:1; **alpha** fora do diamante  
**Preenchimento:** textura no **interior do diamante**  
**Alinhamento:** isométrico 2:1; **sem** personagem no tile  
**Seamless:** arestas do diamante encaixam no vizinho (teste flor de tiles)  
**Extrusão:** wall/elevated podem usar canvas mais alto (ex. 128×96) com footprint 128×64  

### Prompt base de tiles

> True isometric 2:1 diamond terrain tile 128x64, width twice height, dark fantasy arena floor, seamless edges, transparent outside diamond, no characters, no text, stylized, muted palette, not top-down square

## C1. `T-GRASS` — `grass_01.png` … `grass_03.png`

| | |
|--|--|
| **Qtd** | 3 variantes |
| **Visual** | Grama escura `#2d4a3e` ± variação; tufos sutis |
| **Não** | Verde neon; flores grandes que parecem itens |
| **Uso** | Chão default |
| **Aceite** | Em grid 8×6 não forma “padrão gritante” óbvio |

## C2. `T-STONE` — `stone_01.png`, `stone_02.png`

| | |
|--|--|
| **Visual** | Pedra de arena / lajota cinza `#4a4a52` |
| **Detalhe** | Rachaduras leves, sem parecer parede |
| **Uso** | Caminho sob elevação |

## C3. `T-ELEV` — `elevated_01.png`, `elevated_02.png`

| | |
|--|--|
| **Visual** | Platô / madeira de torre / rocha alta |
| **Leitura de altura** | Borda superior mais clara **ou** pequena sombra interna na base |
| **Cor** | Ocre `#6b5a3a` |
| **Crítico** | Em 1 segundo o jogador entende “isto é alto” |
| **Não** | Parecer só grass recolor |

## C4. `T-WATER` — `water_01.png`, `water_02.png` (+ opcional anim)

| | |
|--|--|
| **Visual** | Água escura `#1a4a6e`, reflexo sutil |
| **Anim opcional** | 2 frames shimmer (`water_01_a`, `water_01_b`) |
| **Não** | Água transparente mostrando “buraco” sem borda |
| **Borda** | Se possível, espuma fraca nas bordas internas |

## C5. `T-WALL` — `wall_01.png`, `wall_02.png`

| | |
|--|--|
| **Visual** | Bloco sólido, pedra escura `#2a2430` |
| **Altura visual** | Parecer **obstáculo** (topo diamante + **face vertical** curta) |
| **Uso** | Bloqueia path e cobertura |
| **Não** | Mesma textura do stone de chão |

## C6. `T-PIT` — `pit_01.png` (e `pit_02` opcional)

| | |
|--|--|
| **Visual** | Buraco preto `#0d0a10` com borda de pedra perigosa |
| **Anel** | Borda avermelhada ou rachada (perigo) |
| **Centro** | Quase preto sólido |
| **Aceite** | Nunca confunde com water |

### Highlights de targeting (opcional arte; engine já faz cor)

Se produzir:

- `highlight_move.png` — azul 40% alpha, **losango 128×64**  
- `highlight_attack.png` — vermelho 40% alpha, losango  
- `highlight_path.png` — amarelo 40% alpha, losango  

---

# PARTE D — Cartas

## D0. Regras de carta

1. **Texto do jogo nunca na textura** (nome, custo, descrição = engine).  
2. Ícone conta a **fantasia da carta** em 1 símbolo.  
3. Frame define o **tipo** por cor.  
4. Fundo do ícone transparente; frame pode ter painel interno semitransparente.

## D1. Frames (molduras)

**Pasta:** `assets/cards/frames/`  
**Tamanho export:** **280×400** px (escala 2× de 140×200) ou 140×200  
**9-slice:** cantos ≥ 32 px limpos; bordas retilíneas para slice  
**Centro:** retângulo vazio ~ 60% para ícone + texto da UI  

| ID | Arquivo | Cor / material | Tipo de carta |
|----|---------|----------------|---------------|
| C-FR-ATK | `frame_attack.png` | Cobre/vermelho `#c45c4a` | Ataque |
| C-FR-DEF | `frame_defense.png` | Azul aço `#4a7ab5` | Defesa |
| C-FR-MOV | `frame_movement.png` | Verde `#3d8f6a` | Movimento |
| C-FR-CTL | `frame_control.png` | Roxo `#7a4a9e` | Controle |
| C-FR-BUF | `frame_buff.png` | Ouro claro `#c9a227` | Buff |
| C-FR-DEB | `frame_debuff.png` | Verde doente `#5a7a3a` | Debuff |
| C-FR-ESP | `frame_special.png` | Preto + ouro `#1a1420`/`#c9a227` | Especial |

### Prompt frame

> UI card frame for dark fantasy deckbuilder, ornate but clean, 280x400, empty center for icon, metal rim, transparent outside, no text, stylized, high contrast edge

### Aceite frame

- [ ] Em 140×200 ainda lê a cor do tipo  
- [ ] Centro vazio suficiente  
- [ ] Cantos iguais (simetria)  

## D2. Ícones de carta (128×128)

**Pasta:** `assets/cards/icons/`  
**Estilo:** símbolo único + 1 arma/objeto; fundo transparente; outline escuro  
**Não** cena completa com 5 personagens  

### Prompt template

> Game card icon 128x128, single clear symbol, dark fantasy, transparent background, centered, bold shapes, readable small, no text, stylized, [DESCRIÇÃO]

| ID | Arquivo | Descrição visual obrigatória |
|----|---------|------------------------------|
| C-ICO-passo_combate | `passo_combate.png` | Bota de combate + 1–2 pegadas; ideia de passo controlado |
| C-ICO-sprint | `sprint.png` | Figura correndo **ou** rajadas de vento + botas; velocidade |
| C-ICO-investida | `investida.png` | Capacete + seta à frente / ombro investindo |
| C-ICO-golpe | `golpe.png` | Espada em corte diagonal com traço de slash |
| C-ICO-corte_arco | `corte_arco.png` | Lâmina com arco/meia-lua de corte (AoE) |
| C-ICO-estocada | `estocada.png` | Ponta de espada em linha + motion line reta |
| C-ICO-parry | `parry.png` | Duas lâminas cruzadas / faísca de deflexão |
| C-ICO-guarda_alta | `guarda_alta.png` | Escudo ou espada erguida acima da cabeça |
| C-ICO-finta | `finta.png` | Máscara / silhueta duplicada / lâmina “fantasma” |
| C-ICO-pressao | `pressao.png` | Mão ou peito empurrando; setas de pressão |
| C-ICO-quebra_guarda | `quebra_guarda.png` | Escudo rachado / quebrado |
| C-ICO-giro | `giro.png` | Redemoinho / corpo girando com traço circular |
| C-ICO-desafio | `desafio.png` | Luva de duelo / brasão / marca em X de desafio |
| C-ICO-respiracao | `respiracao.png` | Peito + vapor/ar; calma (não cura mágica óbvia) |
| C-ICO-lamina_final | `lamina_final.png` | Espada com brilho forte; senso de finisher |
| C-ICO-ofensiva | `ofensiva.png` | Olho afiado + lâmina baixa / aura vermelha contida |

### Aceite ícone

- [ ] Reconhecível a 48×48 na UI  
- [ ] Sem texto  
- [ ] Não parece o ícone de outra carta do set (teste lado a lado)  

---

# PARTE E — VFX

**Pasta:** `assets/vfx/`  
**Regra:** curto, legível, **não** esconder a unidade &gt; 0,15 s  
**Sheet:** frames em linha, mesmo tamanho (ex. 64×64 cada)

### Prompt VFX

> 2D game VFX spritesheet on transparent background, stylized, high contrast, short burst, no text, dark fantasy combat, clean alpha

| ID | Arquivo | Frames | Cor | Instrução |
|----|---------|--------|-----|-----------|
| VFX-slash | `slash_arc_sheet.png` | 4–6 | branco/azul-aço | Arco de corte; cresce e some |
| VFX-thrust | `thrust_line_sheet.png` | 3–4 | branco | Linha/ponta alongada no eixo |
| VFX-hit | `impact_hit_sheet.png` | 3–4 | vermelho/laranja | Estrela de impacto pequena no peito |
| VFX-block | `impact_block_sheet.png` | 3 | azul claro | Escudo/hex spark |
| VFX-parry | `parry_spark_sheet.png` | 4 | amarelo `#ffe08a` | Faíscas metálicas |
| VFX-dust | `dust_move_sheet.png` | 3 | marrom/cinza | Poeira nos pés ao entrar no tile |
| VFX-death | `death_poof_sheet.png` | 5 | cinza/roxo | Dissolução / fumaça (não gore) |
| VFX-vuln | `status_vulnerable_sheet.png` | 2 loop | roxo | Ícone flutuante (ex. marca rachada) |
| VFX-duel | `status_marked_duel_sheet.png` | 2 loop | ouro | Marca de duelo sobre a cabeça |

### Timing sugerido

| VFX | Duração total |
|-----|----------------|
| slash / thrust / hit / block / parry | 0,2–0,35 s |
| dust | 0,2 s |
| death_poof | 0,4–0,5 s |
| status loops | 0,6–1,0 s por ciclo, alpha baixo |

---

# PARTE F — UI / HUD

**Pasta:** `assets/ui/`  
**Estilo:** limpo, cantos levemente ornamentados, **sem** ruído; alto contraste em fundo `#1a1420`.

| ID | Arquivo(s) | Tamanho | Estados | Instrução |
|----|------------|---------|---------|-----------|
| UI-endturn | `btn_end_turn_normal.png` ` _hover` ` _pressed` ` _disabled` | ~280×72 (2×) | 4 | Botão largo; cor destaque ouro/azul; **sem texto** na arte (texto “Fim do Turno” é Label) **ou** com texto só se i18n PT único aceito no MVP — preferir **sem texto** |
| UI-energy | `energy_pip_full.png` `energy_pip_empty.png` | 32×32 | 2 | Orbe/cristal de energia |
| UI-timeline | `timeline_pip_ally.png` ` _enemy` ` _active` | 32×32 | 3 | Círculo; active com brilho |
| UI-stance | `stance_balance.png` `stance_guard.png` `stance_offense.png` | 32×32 | 3 | Símbolos: ◆ / escudo / lâminas |
| UI-cursor | `cursor_move.png` `cursor_attack.png` `cursor_invalid.png` | 64×64 | 3 | Move=azul, attack=vermelho, invalid=cinza X |
| UI-banner | `turn_banner.png` | ~800×120 | 1 | Faixa semi-transparente; área central vazia para texto |
| UI-reward | `reward_panel.png` | 9-slice ~560×320 | 1 | Painel de recompensa de carta |

### Prompt UI

> Dark fantasy game UI element, clean readable, transparent BG where needed, no lorem ipsum text, metal and leather accents, high contrast, stylized

---

# PARTE G — Áudio (instruções para sound design)

**Pasta:** `assets/audio/sfx/`  
**Formato:** WAV 16-bit 44.1/48 kHz **ou** OGG Vorbis  
**Loudness:** normalizar ~ −16 LUFS para SFX curtos; evitar clipping  
**Duração:** 0,05–0,4 s (exceto boss_roar até 0,8 s)

| ID | Arquivo | Instrução sonora |
|----|---------|------------------|
| SFX-click | `ui_click.wav` | Click UI seco, médio-agudo |
| SFX-card | `card_play.wav` | Carta / papel + whoosh curto |
| SFX-slash | `slash_hit.wav` | Corte de lâmina + impacto corpo |
| SFX-block | `block.wav` | Metal abafado / escudo |
| SFX-parry | `parry.wav` | Metal agudo com spark |
| SFX-death | `death.wav` | Body fall + poof baixo |
| SFX-roar | `boss_roar.wav` | Grito/ordem de capitão (humanoide, não monstro genérico) |
| SFX-reward | `reward.wav` | Brilho positivo curto (não “slot machine” longo) |

**Licença:** só assets com licença comercial clara; registrar fonte.

---

# PARTE H — P0 (engine) — referência, não produzir arte

Estes **já existem em código**. Não criar PNG para substituí-los até o P1 real.

| ID | O que o código faz |
|----|---------------------|
| P0-01 | Outline azul/vermelho |
| P0-02 | Silhuetas por `unit_id` |
| P0-03 | Seta de facing |
| P0-04 | Badge de postura |
| P0-05 | Floating damage text |
| P0-06 | Flash + knockback |
| P0-07 | Death fade |
| P0-08 | Padrões de tile desenhados |
| P0-09 | Anel de turno ativo |
| P0-10 | HP bar world |

Quando a arte P1 entrar, o programador **substitui** Polygon2D por `AnimatedSprite2D` mantendo os mesmos nomes de anim.

---

# PARTE I — Ordem de produção recomendada (sequência de trabalho)

Faça nesta ordem para maximizar utilidade no jogo:

1. **Frames de carta** (7) — UI já melhora  
2. **16 ícones de carta** — mão legível  
3. **Espadachim idle_se + attack_slash_se + hit_se** — herói “vivo”  
4. **Goblin + Orc set mínimo SE/SW** — combate VS  
5. **Tiles grass/stone/water/wall/pit/elevated** — arena  
6. **Arqueiro + Capitão set**  
7. **VFX hit + slash + block + death**  
8. **Resto das anims do Espadachim (posturas, finisher)**  
9. **UI buttons / stance / cursors**  
10. **SFX core**  
11. **Dirs NE/NW e polish**  

---

# PARTE J — Brief para geração por IA (template)

Copie e preencha:

```text
Project: Fallen Tactics combat sprite
Style: [pixel art OR stylized painted], dark fantasy, strong silhouette, transparent background, TRUE ISOMETRIC 2:1 (diamond ground, width=2x height), not top-down square, not chibi, not photoreal
Subject: [unit description]
Animation: [idle/move/attack...]
Direction: facing [se/sw/nw/ne] isometric
Frames: [N] in a horizontal spritesheet, equal spacing, consistent pivot at feet
Palette: primary [hex], secondary [hex], dark outline
Constraints: no text, no watermark, readable at 64px, margins 4px, feet planted on same baseline every frame
```

Para **ícone de carta**:

```text
128x128 game card icon, transparent background, single symbol: [description],
dark fantasy, bold shapes, dark outline, no text, no watermark, centered
```

Para **tile**:

```text
128x64 seamless true isometric 2:1 diamond terrain tile, [grass/stone/water/wall/pit/elevated],
dark fantasy arena, transparent outside diamond, no characters, tileable edges, muted colors, [hex base]
```

---

# PARTE K — Entrega e handoff para programação

Para cada lote entregue, incluir:

1. Arquivos PNG nos paths corretos  
2. Lista: `nome → frames → fps sugerido → impact_frame (se attack)`  
3. Nota de pivot (se diferente do padrão pés a 80% altura)  
4. Preview 1 imagem com grid 64 mostrando a unidade no tile  

### Mapa de anim → engine (quando plugar)

```text
idle_se, idle_sw, idle_nw, idle_ne
idle_guard_se, ...
idle_offense_se, ...
move_se, ...
attack_slash_se, ...
attack_thrust_se, ...
attack_charge_se, ...
attack_ranged_se, ...
parry_se, ...
hit_se, ...
death_se
skill_finisher_se
phase_roar_se
push_attack_se
summon_se
```

---

# PARTE L — Critério de lote “VS apresentável” completo

O P1 de arte está **fechado** quando:

- [ ] 5 unidades com set mínimo **no jogo**  
- [ ] 6 tipos de tile **diamante 2:1** no grid  
- [ ] 7 frames + 16 ícones de carta  
- [ ] 5+ VFX core  
- [ ] SFX de hit/block/card/death  
- [ ] Playtest: combate legível **sem ler o log**  

---

*Perspectiva **iso 2:1** travada em 2026-08-01. Atualize se o diamante canónico (128×64 vs 64×32) for redefinido.*
