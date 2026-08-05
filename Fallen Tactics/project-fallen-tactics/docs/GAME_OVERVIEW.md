# Project Fallen Tactics — Documento do Jogo

**Versão:** 0.1 (Vertical Slice)  
**Engine atual:** Godot 4.7  
**Última atualização:** 2026-08-01  

Documentos relacionados:

- [`STATE_PROMPT.md`](STATE_PROMPT.md) — estado técnico do protótipo  
- [`ROADMAP_3V3_WORLD.md`](ROADMAP_3V3_WORLD.md) — 3v3 + mundo tático  
- [`ASSETS_AND_ANIMATIONS.md`](ASSETS_AND_ANIMATIONS.md) — assets e animações necessárias  
- [`MULTIPLAYER.md`](MULTIPLAYER.md) — multiplayer  
- [`PORTABILITY.md`](PORTABILITY.md) — plataformas e export  
- [`NETWORKING_SERVERS.md`](NETWORKING_SERVERS.md) — WebSocket e UDP  

---

## 1. One-liner

**RPG roguelike tático com deckbuilder**, em que cada herói tem deck próprio, o **posicionamento** e o **terreno** mudam o valor das cartas, e cada run gera combinações irrepetíveis de builds.

---

## 2. High concept

O jogador comanda um **grupo de heróis** em batalhas táticas por turnos.

Cada personagem possui:

- Deck próprio  
- Classe e especialização  
- Equipamentos e relíquias  
- Atributos e progressão **durante a run**  

**Não existe build perfeita.** Existem centenas de combinações.

O jogo **não** é só Slay the Spire com grid, nem só Final Fantasy Tactics com cartas.  
É a fusão de:

| Camada | O que entrega |
|--------|----------------|
| Deckbuilding | Escolhas de mão, energia, sinergia |
| RPG | Classes, progressão, identidade de personagem |
| Tático | Grid, facing, flanco, initiative |
| Terreno | Tiles que alteram movimento, dano e táticas |
| Roguelike | Run única, morte com peso, rejogabilidade |

**Foco principal:** tomada de decisões.

---

## 3. Pilares de design

Toda feature deve passar neste filtro. Se falhar, **não entra**.

| # | Pilar | Teste rápido |
|---|--------|----------------|
| 1 | Decisões interessantes | A carta/escolha tem trade-off? |
| 2 | Posicionamento importa | Mudar de tile muda o plano? |
| 3 | Terreno importa | O mapa “joga” junto? |
| 4 | Equipamentos mudam cartas | Item transforma habilidade, não só +stat? |
| 5 | Cada classe joga diferente | Parece um mini-jogo novo? |
| 6 | Toda run é única | Cartas, mapa, eventos, builds variam? |

Perguntas obrigatórias:

- Isso torna o jogo mais divertido?  
- Aumenta profundidade estratégica?  
- Cria novas decisões?  
- Evita repetição?  
- Incentiva novas builds?  
- Aumenta rejogabilidade?  

---

## 4. Público e referências (não clones)

**Público-alvo (primário):** jogadores de roguelike/deckbuilder que querem mais **espaço e tática**; fãs de tactics que aceitam abstração de cartas.

**Referências de sensação (inspiração, não cópia):**

| Jogo | O que roubar | O que não copiar cegamente |
|------|----------------|----------------------------|
| Slay the Spire | Clareza de cartas, run structure | Combate 1vN sem grid |
| Final Fantasy Tactics / Triangle Strategy | Facing, altura, job fantasy | Combate sem deck |
| Into the Breach | Cada ação importa, legibilidade | Escopo mínimo vs nosso RPG |
| Monster Train / Griftlands | Builds de run, identidade | — |
| Darkest Dungeon | Pressão, composição de party | Estresse como sistema core (opcional) |

---

## 5. Gameplay loop

### Loop de run (visão completa)

```text
Nova Run
  → Escolha da equipe
  → Mapa / Região procedural
  → Exploração / Evento / Atividade
  → Combate tático (decks)
  → Recompensa (carta, equip, XP)
  → Elite / Boss de região
  → Nova região…
  → Boss final
  → Meta progressão (desbloqueios)
```

### Loop de combate (núcleo)

```text
Timeline define quem age
  → Unidade ativa: energia + mão
  → Joga cartas (mover / atacar / controlar / buff…)
  → Posição, facing e terreno resolvem efeitos
  → Fim do turno → CT/initiative recarrega
  → Vitória / derrota / objetivo
```

### Loop de mapa (roadmap 3v3 + zona)

```text
Move o grupo na zona
  → Vê patrulhas e POIs
  → Decide: emboscar / evitar / atividade
  → Engaja combate 3v3 com modificadores de surpresa
  → XP e estado do mapa mudam
```

---

## 6. Combate

### Unidade

| Stat / sistema | Função |
|----------------|--------|
| Vida (HP) | Sobrevivência |
| Energia | Custo de cartas |
| Movimento | Via **cartas** (não move free + full hand) |
| Direção (facing) | Frente / flanco / costas |
| Deck | Identidade de build |
| Equipamentos | Mutam e sinergizam cartas |
| Iniciativa / Timeline | Quando age; cartas podem adiantar/atrasar |
| Postura (Espadachim VS) | Guard / Offense / Balance |

### Tipos de carta

Ataque · Defesa · Movimento · Controle · Invocação · Terreno · Buff · Debuff · Especial  

### Terreno (visão)

Grass, Forest, Stone, Water, Ice, Fire, Poison, Wall, Lava, Bridge, Pit, Elevated…  

Mecânicas: empurrar em penhasco, queimar floresta, congelar rio, criar muro, armadilhas, destruir obstáculos.

### Classes (visão de produto)

| Classe | Fantasy |
|--------|---------|
| Guardião | Tank, controle, escudos, provocar |
| Espadachim | Combos, posturas, duelos |
| Patrulheiro | Armadilhas, alcance, exploração |
| Assassino | Crítico, mobilidade, costas |
| Mago Arcano | Elementos, área, controle |
| Druida | Invocações, transformações, cura |
| Engenheiro | Torres, muros, bombas |
| Necromante | Undead, sacrifício, maldições |
| Paladino | Luz, proteção, suporte |
| Bardo | Timeline, buffs, manipulação de mão |

Cada classe → **3 especializações** que alteram cartas e estilo.

---

## 7. Progressão

### Durante a run

Nível · habilidades · cartas · equipamentos · relíquias · estado do mapa  

### Após a morte (meta)

Desbloqueios: classes, eventos, inimigos, biomas, cartas, cosméticos  

### Relíquias

Mudam **regras**, não só números.  
Exemplos: primeira magia custa 0; ataques empurram; dano recebido gera energia.

---

## 8. Estado atual vs visão

| Área | Agora (VS) | Visão |
|------|------------|--------|
| Heróis em combate | 1 (Espadachim) | Até 3 (3v3) |
| Grid | 8×6 | 12×10+ em combate; zona 24×16+ |
| Mapa | Corredor de 3 encontros | Zona tática + atividades |
| XP | Não | Sim, com level-up por escolha |
| Multiplayer | Não | Ver MULTIPLAYER.md |
| Arte | Placeholders | Estilizada, silhuetas fortes, UI limpa |

---

## 9. Estilo visual e tom

- Arte **estilizada** (não hiper-realista)  
- **Perspectiva: isométrico 2:1** (chão em diamante; UI/cartas ortogonais)  
- Leitura rápida no grid  
- Silhuetas fortes por classe  
- Animações curtas e legíveis  
- UI limpa (mão, timeline, terreno)  
- Tom: tático sombrio com fantasia “fallen” (queda de reinos, ruínas, arenas) — ajustar lore quando houver bible  

**Produção detalhada:** [`ASSETS_AND_ANIMATIONS.md`](ASSETS_AND_ANIMATIONS.md) · [`ASSET_INSTRUCTIONS.md`](ASSET_INSTRUCTIONS.md).

---

## 10. Arquitetura de conteúdo

Orientação a **dados**, não hardcode:

- Cartas, itens, classes, inimigos, mapas, eventos, relíquias configuráveis  
- Efeitos como **opcodes** (`damage`, `move`, `push`, `shift_timeline`…)  
- Encontros e zonas em resources/JSON  

Isso habilita balance, mods futuros e sync multiplayer mais limpo.

---

## 11. Critérios de qualidade

Um sistema entra no jogo se:

1. Cria decisão legível em &lt; 3 segundos de leitura  
2. Interage com **pelo menos dois** de: cartas, posição, terreno, timeline, party  
3. Tem falha interessante (não só “menos ótimo”)  
4. Não duplica outro sistema sem profundidade nova  

---

## 12. Glossário rápido

| Termo | Significado |
|-------|-------------|
| Run | Uma tentativa do começo até vitória ou morte |
| Zona | Mapa de exploração tática |
| Arena | Grid de combate |
| Timeline / CT | Ordem dinâmica de turnos |
| Facing | Direção que a unidade olha |
| Opcode | Efeito atômico resolvido pelo motor |
| POI / Activity | Ponto de interesse / atividade no mapa |
| Meta | Progressão entre runs |

---

*Documento de produto/design. Detalhes de implementação e roadmap de features em docs específicos.*
