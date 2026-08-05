# Roadmap — Batalha 3v3 + Mundo Tático com Atividades

**Projeto:** Project Fallen Tactics  
**Data:** 2026-08-01  
**Base:** Vertical Slice atual (1 herói, grid 8×6, 3 encontros lineares)  
**Documento de contexto:** [`STATE_PROMPT.md`](STATE_PROMPT.md)

---

## 1. Visão da experiência

O jogador não só “entra em combates de arena”. Ele **explora um terreno tático maior**, encontra **inimigos no mapa**, escolhe **quando e como engajar**, e entre brigas faz **atividades** (saque, ritual, ponte, emboscada, ferreiro de campo).

### Fantasy de sessão

```text
Escolhe time de até 3 heróis
        ↓
Entra na Região (mapa grande, **isométrico 2:1** tático)
        ↓
Move o grupo no overworld / zona
        ↓
Vê patrulhas, camps, pontos de interesse
        ↓
Decide: flanquear | ignorar | forçar combate | fazer atividade
        ↓
Transição → Combate 3v3 (ou 3vN escalado) em arena derivada do bioma
        ↓
XP + loot + cartas + estado do mapa muda
        ↓
Volta à zona (inimigos mortos sumiram / reforços podem vir)
        ↓
Objetivo da região (boss / portal / artefato)
```

### O que isso NÃO é

| Evitar | Por quê |
|--------|---------|
| Open world sem fim | Dilui decisões da run e explode escopo |
| Auto-batalha no mapa | Mata o pilar “decisões interessantes” |
| 3v3 só como “mais HP na tela” | Sem posicionamento/deck por herói vira barulho |
| XP grind infinito | Roguelike: XP deve desbloquear **escolhas**, não farm |

### O que isso É (identidade Fallen)

- **Tactics** no mapa (espaço, visão, emboscada, terreno).  
- **Deckbuilder** no combate (cada herói com deck próprio).  
- **Roguelike** na run (mapa muda, builds divergem, morte tem peso).  
- Atividades no mapa são **mini-decisões** com trade-off, não cutscenes.

---

## 2. Metas de produto (definição de pronto)

### Meta A — Combate 3v3

- Até **3 heróis** controláveis (ou 2 + 1 invocação, mas o target é 3 unidades jogáveis).  
- Até **3 inimigos** principais no engajamento padrão (elite/boss podem quebrar a regra com regras claras).  
- Cada herói: deck, energia, postura/facing, timeline própria.  
- Grid de combate **≥ 2× a área atual** (hoje 8×6 = 48 tiles → alvo **12×10** ou **16×12**).  
- Vitória/derrota por wipe do time ou objetivo especial.

### Meta B — Terreno / zona maior

- **Zona de exploração** separada da arena de combate (recomendado) *ou* seamless (só se performance e UX permitirem — fase tardia).  
- Tamanho de zona VS: **~2× linear** do combate (ex. zona 24×20 tiles de navegação) com POIs.  
- Terreno legível: floresta, elevação, rio, ruína, estrada, neblina de guerra opcional.

### Meta C — Inimigos no mapa + XP

- Unidades inimigas **visíveis no mapa** (patrulha / camp / elite).  
- Contato = engajamento (com modificadores: flanco, surpresa, fuga).  
- Derrotar dá **XP de run** (e às vezes carta/item).  
- XP sobe **nível de herói na run** → escolhas (upgrade de carta, atributo, slot de relíquia) — **não** só +1 AT plano.

### Meta D — Atividades no mapa

Pelo menos 5 tipos no primeiro milestónio de “mundo vivo”:

| Atividade | Decisão | Recompensa típica | Risco |
|-----------|---------|-------------------|--------|
| **Camp inimigo** | Atacar / espiar / incendiar | Combate com bônus de surpresa | Alarme / reforços |
| **Ruína** | Explorar | Carta / relíquia | Armadilha / múmia |
| **Altar** | Oferecer HP / carta | Buff de run / XP | Maldição |
| **Ponte / bloqueio** | Gastar turno / carta de utilidade | Abre atalho | Emboscada no estreitamento |
| **Sobrevivente / mercador** | Comprar / trocar / roubar | Equip / cura | Preço alto / combate |

---

## 3. Princípios de design (não negociar)

1. **Cada herói no 3v3 é um jogo** — decks distintos; sem “3 clones com skins”.  
2. **Mapa cria o combate** — flanco no overworld = bônus na arena (initiative, facing, tile inicial).  
3. **XP compra decisões**, não poder bruto puro.  
4. **Atividade sem trade-off não entra.**  
5. **2 camadas de mapa no MVP de mundo:** Zona (exploração) + Arena (combate). Seamless só depois.  
6. **Escopo em fatias jogáveis** — cada fase termina em build playable.

---

## 4. Arquitetura-alvo (orientação a dados)

```text
GameState (run)
  ├── party[3] (classe, deck, nível, XP, equip, relíquias)
  ├── zone_state (tiles, fog, flags de POI, inimigos vivos)
  └── meta (unlocks — depois)

ZoneScene (exploração)
  ├── ZoneGrid (maior, navegação do grupo)
  ├── PartyToken (1 token ou 3 com formação)
  ├── MapEnemy (patrulha + AI leve)
  ├── ActivityNode (POI)
  └── EncounterBuilder → gera CombatSetup

CombatScene (já existe, evolui)
  ├── TacticalGrid (12×10 / 16×12)
  ├── BattleUnit × até 6+
  ├── Timeline multi-unidade
  └── Hand UI por herói ativo
```

**Novos dados (meta final de data-driven):**

```text
data/
  zones/*.json          # layout, spawns, POIs
  activities/*.json     # tipos de atividade
  encounters/*.json     # templates 3v3
  enemies/*.json        # stats + xp + ai_profile
  classes/*.json
  cards/*.json
  level_tables/*.json   # XP → opções de level-up
```

---

## 5. Fases de implementação

> Cada fase tem: objetivo, entregáveis, dependências, critérios de aceite e o que **não** fazer ainda.

---

### Fase 0 — Fundação (pré-requisito do 3v3)

**Objetivo:** O núcleo atual continua divertido e o código aguenta multi-unidade sem reescrever tudo.

| # | Entrega | Por quê melhora o jogo | Escopo |
|---|---------|------------------------|--------|
| 0.1 | Refator: spawns e encontros em data (`data/encounters`) | Variedade sem hardcode | Dev |
| 0.2 | `Party` / `HeroState` no `GameState` (mesmo com 1 herói) | Caminho limpo para 3 | Dev |
| 0.3 | UI de turno: “unidade ativa” clara na timeline | Preparar multi-herói | UX |
| 0.4 | Fix de path cost real / investida / facing feedback | Combate legível | Polish |

**Aceite:** Run 1 herói ainda joga; código de party existe sem regressão.

**Não fazer:** 3 classes novas, mapa grande.

**Estimativa relativa:** S (1–3 dias foco)

---

### Fase 1 — Combate multi-herói (2v2 → 3v3) em arena maior

**Objetivo:** Batalha tática com time, sem overworld ainda.

#### 1A — Grid maior + 2 heróis

| # | Entrega | Notas de design |
|---|---------|-----------------|
| 1.1 | Grid combate **12×8** ou **12×10** (~2× tiles) | Mais flanco/linha sem virar RTS |
| 1.2 | 2 heróis: Espadachim + 2ª classe **mínima** (ex. Guardião ou Patrulheiro stub) | 2ª classe deve jogar diferente (tank/trap vs combo) |
| 1.3 | Troca de mão: só o herói **ativo** joga cartas no turno dele | Evita “jogar 15 cartas por rodada” |
| 1.4 | Inimigos 2v2, depois 2v3 | Balance por pressão de flanco |
| 1.5 | Câmera / zoom e scroll no grid | UX obrigatória em mapa maior |

**Aceite:** Player planeja posição **entre** os dois heróis (ex.: tank frente, DPS flanco).

#### 1B — 3v3 completo em combate

| # | Entrega | Notas |
|---|---------|--------|
| 1.6 | 3º herói (stub ou classe real leve) | Preferir arquétipos: Tank / Carry / Utility |
| 1.7 | Encounter template `3v3_standard` | Posições iniciais em “deployment zone” |
| 1.8 | Deployment opcional: 3 tiles de spawn à escolha | Aumenta decisão pré-combate |
| 1.9 | Soft cap de duração (ex. 20 rodadas ou objetivo) | Evita stalemate em grid grande |
| 1.10 | Balance pass: energia, initiative, AoE | AoE fica mais forte em 3v3 — reavaliar |

**Aceite:** Combate 3v3 é legível; cada herói importa; não é “só o DPS age”.

**Por que melhora o jogo:** Cria sinergias de time (provocar + flanco + finta) e multiplica builds.  
**Balance:** Iniciativa e mãos separadas evitam snowball de AP; Guardião existe para proteger o Mago/Carry.  
**Interação terreno:** Grid 2× maior valoriza investida, elevação e pits.  
**MVP?** Sim — é o core da nova fantasia de combate.

**Não fazer ainda:** 10 classes, invocações em massa, seamless world.

**Estimativa relativa:** M–L (1–2 semanas)

---

### Fase 2 — XP e progressão de herói *na run*

**Objetivo:** Inimigos (ainda em combate linear ou já em mapa) recompensam crescimento com **escolha**.

| # | Entrega | Design |
|---|---------|--------|
| 2.1 | Tabela de XP por inimigo (`xp_reward`) | Goblin baixo, elite alto, boss grande |
| 2.2 | XP de party: split igual **ou** bônus a quem executou | Preferir split igual no MVP (menos tilt) |
| 2.3 | Níveis 1–5 na run | Curva curta de roguelike |
| 2.4 | Level-up = **1 de 3 opções** | Ex.: +máx HP / upgrade carta / slot passiva / novo card pick |
| 2.5 | UI de level-up entre combates (e depois no mapa) | Mesmo padrão visual da recompensa de carta |
| 2.6 | Soft soft-cap: overlevel reduz XP | Anti-farm quando o mapa existir |

**Aceite:** Jogador lembra “subi de nível e **escolhi** X”, não “ganhei +2 de tudo”.

**Filtro de pilares:** XP sem escolha = descartar.  
**Estimativa:** S–M

---

### Fase 3 — Zona de exploração (mapa 2×+ / “tactics com atividades”)

**Objetivo:** Segunda camada: **Zone** onde o grupo se move e encontra conteúdo.

#### 3A — Zona mínima jogável

| # | Entrega | Notas |
|---|---------|--------|
| 3.1 | `ZoneScene` + `ZoneGrid` (ex. **24×16** ou **24×20**) | ~2× linear do combate 12×10 |
| 3.2 | Token do grupo (move em turnos ou tempo discreto) | MVP: movimento por pontos de movimento / “passos” |
| 3.3 | Fog of war leve ou só visão limitada | Emboscar e ser emboscado |
| 3.4 | 3–5 tiles de terreno de zona | Estrada, floresta (lento), rio (bloqueia), ruína, camp |
| 3.5 | Saída da zona = objetivo (portal / boss gate) | Run tem direção |
| 3.6 | Transição Zone → Combat com `CombatSetup` | Seed da arena pelo bioma + modificadores |

**Modo de tempo (decisão recomendada para MVP):**  
**Turnos de mapa** (grupo age → patrulhas age).  
Mais previsível, mais “tactics”, mais barato que tempo real.

#### 3B — Inimigos no mapa

| # | Entrega | Notas |
|---|---------|--------|
| 3.7 | `MapEnemy`: posição, rota de patrulha, aggro range | Visual distinto por tipo |
| 3.8 | Contato → opções: **Lutar** / **Tentar fuga** (teste) | Fuga consome recurso ou atrasa |
| 3.9 | **Surpresa:** se o grupo entra pelas costas da patrulha → bônus (timeline + facing inicial) | Liga mapa ao combate |
| 3.10 | **Alarme:** se patrulha te vê primeiro → inimigos começam em boa posição | Pune movimento burro |
| 3.11 | Matar remove do mapa + dá XP (Fase 2) | Estado persistente na zona |
| 3.12 | Elite no mapa (1) com aura / camp | Conteúdo denso, não quantidade |

**Aceite:** Dá para limpar uma zona matando 3–6 packs, ganhar XP e sentir o mapa “vivo”.

#### 3C — Atividades no mapa

| # | Entrega | Exemplos de regra |
|---|---------|-------------------|
| 3.13 | Sistema `Activity` data-driven | id, custo, outcomes, requisitos |
| 3.14 | Ruína | 50% carta, 30% luta, 20% armadilha |
| 3.15 | Altar | Gasta 5 HP → +1 level-up parcial ou buff |
| 3.16 | Camp inimigo | Combate com +1 inimigo mas +loot |
| 3.17 | Ferreiro de campo | Upgrade 1 carta (mutação leve) — seed do pilar equip |
| 3.18 | Cada atividade consome **tempo de mapa** | Patrulhas andam / risco sobe |

**Aceite:** Em uma run o jogador faz ≥2 atividades e ≥2 combates por escolha, não por corredor forçado.

**Estimativa Fase 3:** L (2–4 semanas)

---

### Fase 4 — Liga mapa ↔ combate de verdade

**Objetivo:** O overworld não é só “seletor de fight”.

| # | Entrega | Impacto |
|---|---------|---------|
| 4.1 | Deployment herdado da direção do contato | Entrou pelo norte → spawna no norte |
| 4.2 | Terreno da arena amostrado do tile de zona | Floresta no mapa → mais cover na arena |
| 4.3 | Reforços se o combate demora e há patrulha adjacente | Pressão de tempo |
| 4.4 | Fuga a meio do combate (custa HP / item, volta ao mapa) | Opção tática |
| 4.5 | Objetivos de combate além de wipe | Escoltar, destruir totem, sobreviver N turnos |

**Aceite:** Duas abordagens ao mesmo pack geram combates **diferentes**.

**Estimativa:** M

---

### Fase 5 — Run de região completa (roguelike tático)

| # | Entrega |
|---|---------|
| 5.1 | 1 bioma completo (ex. Floresta Caída): zona + 8–12 packs + 4 atividades + 1 boss gate |
| 5.2 | Escolha de party no início (3 de N classes desbloqueadas; MVP: 3 fixas) |
| 5.3 | Shop / descanso limitado (1 acampamento por zona) |
| 5.4 | Boss de região com fase + mudança de mapa (padrão Capitão) |
| 5.5 | Morte = fim da run; meta unlock leve (1 classe ou 1 carta) |

**Aceite:** “Uma run de 25–40 min que parece um capítulo de tactics + deckbuilder.”

**Estimativa:** L

---

### Fase 6+ — Expansão (só após Fase 5 validada)

| Prioridade | Conteúdo | Notas |
|------------|----------|--------|
| Alta | Mais classes (até 5–6) | Cada uma deve “ser um jogo novo” |
| Alta | Equip muta cartas de verdade | Pilar 4 |
| Média | Relíquias de regra | Sem +5 dano plano |
| Média | 2º e 3º biomas | Reusar pipeline de zona |
| Média | Formação 3 tokens no mapa (não só 1 blob) | Avançado |
| Baixa | Seamless world (sem cena de combate) | Alto risco técnico |
| Baixa | 4v4 / mass battles | Pode matar legibilidade |
| Baixa | Crafting complexo | Só se criar decisões |

---

## 6. Roadmap visual (dependências)

```text
[Fase 0 Fundação]
        │
        ▼
[Fase 1A Grid+2 heróis] ──► [Fase 1B 3v3 combate]
        │                           │
        └──────────┬────────────────┘
                   ▼
            [Fase 2 XP + level-up choices]
                   │
                   ▼
            [Fase 3A Zona grande]
                   │
         ┌─────────┴─────────┐
         ▼                   ▼
 [3B Inimigos mapa]   [3C Atividades]
         │                   │
         └─────────┬─────────┘
                   ▼
            [Fase 4 Liga mapa↔combate]
                   │
                   ▼
            [Fase 5 Região run completa]
                   │
                   ▼
              [Fase 6+ expansão]
```

---

## 7. Especificações numéricas sugeridas (v0 — balance depois)

### Combate

| Parâmetro | VS atual | Alvo 3v3 |
|-----------|----------|----------|
| Grid | 8×6 (48) | 12×10 (120) ou 16×12 (192) |
| Heróis | 1 | 3 |
| Inimigos padrão | 2–3 | 3 (elite 4 com regra) |
| Hand | 5 | 5 por herói ativo |
| Energia | 3 | 3 (ajustar se turnos longos) |
| Duração alvo | 5–10 min | 8–15 min |

### Zona

| Parâmetro | Alvo MVP |
|-----------|----------|
| Grid zona | 24×16 a 32×20 |
| Packs inimigos | 4–8 |
| Atividades | 4–6 |
| Passos de movimento / turno de mapa | 3–4 |
| Visão | 4–6 tiles |

### XP (exemplo)

| Fonte | XP |
|-------|-----|
| Goblin | 8 |
| Orc | 14 |
| Arqueiro | 12 |
| Elite | 28 |
| Atividade arriscada | 6–10 |
| Boss | 50 |

| Nível | XP acumulado (exemplo) |
|-------|-------------------------|
| 2 | 20 |
| 3 | 45 |
| 4 | 80 |
| 5 | 120 |

---

## 8. UI/UX crítica (não deixar por último)

| Tela | Necessidade |
|------|-------------|
| Combate 3v3 | Timeline com 6 unidades legível; portrait do ativo; atalho para focar unidade |
| Troca de herói | Só no turno dele (ou “delay para trocar” se quiser deep — pós-MVP) |
| Zona | Ícones de patrulha, POI, path preview, botão “aguardar / passar turno de mapa” |
| Contato | Modal: Lutar / Fuga / (Espiar se Assassino) |
| Level-up | 3 cards de opção, igual recompensa de carta |

---

## 9. Riscos e mitigações

| Risco | Mitigação |
|-------|-----------|
| 3 mãos = sobrecarga cognitiva | Uma mão por vez; IA de aliados **não** no MVP (player controla os 3) |
| Grid grande + 6 unidades = lento | Limitar animações; pathfinding simples; soft timer de combate |
| Farm de XP no mapa | Overlevel XP penalty; packs não respawnam (ou respawn caro) |
| Atividades irrelevantes | Toda atividade move o clock de patrulha |
| 2ª/3ª classe genéricas | Se não diferenciarem, cortar conteúdo e aprofundar 1 classe |
| Escopo infinitamente aberto | Gate: Fase 5 = “1 região boa” antes de bioma 2 |

---

## 10. Ordem de implementação recomendada (checklist executável)

### Sprint slice A — “Time na arena”
- [ ] Party no GameState  
- [ ] Grid 12×10  
- [ ] 2 heróis + timeline multi  
- [ ] Hand só do ativo  
- [ ] Encounter 2v2  

### Sprint slice B — “3v3 de verdade”
- [ ] 3º herói  
- [ ] Deployment zone  
- [ ] Encounter 3v3 + elite  
- [ ] Câmera/scroll  
- [ ] Balance pass  

### Sprint slice C — “XP com escolha”
- [ ] xp_reward nos inimigos  
- [ ] Level-up 1 de 3  
- [ ] UI level-up  

### Sprint slice D — “Mapa vivo v0”
- [x] ZoneScene (16×12 iso) — `scenes/zone/zone_scene.tscn`  
- [x] Token + turnos de mapa (PM + espaço)  
- [x] 4 patrulhas + boss  
- [x] Contato → combate → volta  
- [x] Estado de inimigos mortos  

### Sprint slice E — “Atividades”
- [ ] 4 activities data-driven  
- [ ] Tempo de mapa avança  
- [ ] 1 ferreiro (mutação de carta seed)  

### Sprint slice F — “Região”
- [ ] Objetivo de zona + boss  
- [ ] Surpresa/alarme  
- [ ] Run loop completo  

---

## 11. Critérios de sucesso (playtest)

O jogador deve dizer, sem prompt:

1. “Eu contornei a patrulha para atacar de surpresa.”  
2. “Mandei o tank puxar enquanto o espadachim flanqueava.”  
3. “Gastei o nível em upgrade de carta, não em HP.”  
4. “A ruína valeu o risco / não valeu.”  
5. “O mapa maior mudou como eu uso investida e elevação.”  
6. “Quero outra run com outra formação de 3.”  

Se a sensação for “limpei o mapa farmando XP e bati 3v3 no automático” → falhou.

---

## 12. Relação com o Vertical Slice atual

| Manter | Evoluir | Substituir depois |
|--------|---------|-------------------|
| TacticalGrid + opcodes | Multi-unit + grid maior | Arena 8×6 como default |
| CardLibrary / posturas | Decks por herói | Deck único global |
| AI profiles | AI para 3 inimigos coordenados | — |
| Boss em fases | Boss de região | Capitão só como tutorial boss |
| Recompensa de carta | + XP level-up + atividades | Corredor linear encounter_01→02→boss |

---

## 13. Decisões abertas (resolver antes da Fase 3)

Responda estas para travar implementação:

1. **Controle dos 3 heróis:** 100% manual (recomendado MVP) ou aliados semi-IA?  
2. **Token no mapa:** 1 blob de party ou 3 unidades no overworld?  
3. **Tempo de mapa:** turnos discretos (recomendado) ou tempo real pausável?  
4. **2ª e 3ª classe do first 3v3:** Guardião + Patrulheiro? Guardião + Mago?  
5. **Fuga de combate:** permitida desde o MVP de zona?  

---

## 14. Próxima ação sugerida

**Implementar Fase 0 + 1A** (party state + grid maior + 2 heróis no combate),  
sem zona ainda — valida se  multi-herói + deck é divertido **antes** de construir o mapa.

Quando isso estiver sólido → XP (Fase 2) → Zona + patrulhas (Fase 3).

---

*Documento vivo. Atualize checkboxes e decisões abertas conforme o projeto avança.*
