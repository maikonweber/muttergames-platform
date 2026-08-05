# Portabilidade — Project Fallen Tactics

**Status:** Diretrizes de plataforma  
**Engine atual:** Godot 4.7  
**Última atualização:** 2026-08-01  
**Relacionados:** [`GAME_OVERVIEW.md`](GAME_OVERVIEW.md) · [`MULTIPLAYER.md`](MULTIPLAYER.md) · [`NETWORKING_SERVERS.md`](NETWORKING_SERVERS.md)

---

## 1. Objetivo

Rodar o **mesmo núcleo de jogo** (regras, dados, combates) no maior número útil de plataformas, **sem** fragmentar o design em “versão mobile diferente”.

**Princípio:** *um game design, múltiplos front-ends de input/UI.*

---

## 2. Plataformas-alvo (prioridade)

| Prioridade | Plataforma | Justificativa |
|------------|------------|---------------|
| **P0** | Windows (PC) | Dev atual, playtest, Steam futuro |
| **P0** | Linux | Steam Deck / servidores headless / itch |
| **P1** | macOS | Alcance PC premium |
| **P1** | **Steam Deck** (Linux + gamepad) | Tático + deck encaixa em handheld |
| **P2** | Web (HTML5 / WebAssembly) | Demo, marketing, co-op browser experimental |
| **P2** | Android | Touch + partidas curtas; UI adaptada |
| **P3** | iOS | Conta Apple, input touch; depois de Android estável |
| **P3** | Consoles (Switch / Xbox / PlayStation) | Após publisher/cert; input e TRC |

**Fora do radar inicial:** TV-only, smartwatch, VR.

---

## 3. Stack e portabilidade técnica (Godot)

### O que ajuda

| Prática | Por quê |
|---------|---------|
| Lógica em GDScript/C# **sem** APIs só de Windows | Export limpo |
| Dados em `res://data` (JSON/Resource) | Mesmo content pack |
| Input via **InputMap** + actions (`end_turn`, `confirm`, …) | Remap por device |
| UI em **Control** anchors / containers | Resoluções diferentes |
| Áudio bus centralizado | Mute/plataforma |
| Sem paths absolutos de disco | `user://` para saves |
| Feature flags (`OS.has_feature("web")`) | Ramos de rede/fs |

### Cuidados por plataforma

| Plataforma | Cuidado |
|------------|--------|
| **Web** | Threads limitadas; WebSocket ok; UDP raw **não** (usar WebRTC ou só WS); tamanho do build; autoplay de áudio |
| **Mobile** | Memória; texturas comprimidas; termal; background pause |
| **Steam Deck** | 1280×800; gamepad first; suspend/resume |
| **Console** | Certificação, saves em APIs da plataforma, proibir teclado-only |
| **Servidor dedicated** | Export headless Linux; sem rendering |

---

## 4. Input — matriz de portabilidade

O jogo deve funcionar com **três esquemas**, mapeados às mesmas actions:

### 4.1 Teclado + mouse (PC default)

| Ação | Default sugerido |
|------|------------------|
| Selecionar tile / unidade | Clique esquerdo |
| Cancelar | Esc / botão direito |
| Fim do turno | Espaço |
| Ciclar unidade aliada | Tab |
| Zoom | Scroll |
| Mover câmera | WASD / edges |

### 4.2 Gamepad (Deck / console / PC)

| Ação | Default sugerido |
|------|------------------|
| Mover cursor de grid | Stick / D-pad |
| Confirmar | A (South) |
| Cancelar | B (East) |
| Mão de cartas (ciclo) | LB/RB |
| Jogar carta | A com carta focada |
| Fim do turno | Y ou menu |
| Timeline / info | X / Select |

**Regra:** cursor virtual no grid obrigatório se não houver mouse.

### 4.3 Touch (mobile / hybrid)

| Ação | Gesto |
|------|--------|
| Selecionar tile | Tap |
| Câmera | Drag |
| Zoom | Pinch |
| Carta | Tap na mão → tap no alvo |
| Fim do turno | Botão grande fixo |
| Long-press | Tooltip / range preview |

**Não** exigir hover para informação crítica (mobile não tem hover confiável).

---

## 5. UI adaptativa

| Breakpoint | Layout |
|------------|--------|
| Desktop ≥ 1280×720 | Mão embaixo, log lateral, timeline no topo (atual) |
| Deck 1280×800 | Igual desktop; botões ≥ 32–40 px |
| Tablet | Mão maior; log em drawer |
| Phone portrait | **Combate em landscape lock** recomendado; portrait só menu |
| Phone landscape | Mão 2 fileiras ou carrossel; log ocultável |

### Acessibilidade (portabilidade humana)

- Escala de UI 80–150%  
- Daltonismo: não usar só cor (ícones em flanco/tipo de carta)  
- Remap completo de teclas/gamepad  
- Velocidade de animação 0.5×–2×  
- Modo “texto grande”  

---

## 6. Saves e cloud

| Dado | Onde |
|------|------|
| Progressão meta | `user://save_meta.json` (ou binário) |
| Run em andamento | `user://run_active.json` + version field |
| Settings | `user://settings.cfg` |
| Cloud (Steam/etc.) | Sync da pasta save via API da loja |

**Versionamento:** todo save tem `schema_version` para migrations entre ports.

**Web:** `user://` → IndexedDB no Godot; avisar limite e perda em browser limpo.

---

## 7. Performance budgets (alvos)

| Cenário | Alvo |
|---------|------|
| Combate 3v3 grid 12×10 | 60 FPS desktop mid; 30 FPS mobile mínimo |
| Zona 32×20 + 10 agents | 60 / 30 idem |
| Build Web | &lt; 50–80 MB initial se possível (demo menor) |
| Memória mobile | &lt; 1 GB working set meta |

Otimizações portáveis: object pooling de VFX, less overdraw na UI, pathfinding async, tileset atlas.

---

## 8. Rede e portabilidade

| Plataforma | Transporte preferido |
|------------|----------------------|
| PC / Deck co-op | WebSocket (TCP) ou ENet/UDP Godot |
| Web | **WebSocket** ou WebRTC DataChannel |
| Mobile | WebSocket (baterias/NAT); UDP com cuidado |
| Servidor | Linux + WS e/ou UDP (ver NETWORKING_SERVERS.md) |

**Cross-play:** possível se o protocolo de commands for idêntico e o version handshake bater (`protocol_version` + `content_hash`).

---

## 9. Pipeline de build / CI (alvo)

```text
main branch
  → tests (lógica de combate headless)
  → export Windows
  → export Linux
  → export Web (demo)
  → (depois) Android AAB
  → artefatos em CI
```

Checklist por release:

- [ ] InputMap testado teclado / gamepad  
- [ ] Resolução mínima e 4K  
- [ ] Save/load roundtrip  
- [ ] Áudio sob mute do OS  
- [ ] Web: carrega em Chrome/Firefox  
- [ ] Deck: layout e suspensão  

---

## 10. Localização (i18n)

- Strings via `tr()` / CSV desde cedo  
- Fontes com glyphs PT-BR + EN no mínimo  
- Não embutir texto em texturas de UI críticas  
- Cartas: `display_name_key` + locale  

Portabilidade cultural = parte de portabilidade de produto.

---

## 11. Riscos por plataforma

| Risco | Mitigação |
|-------|-----------|
| Touch piora targeting tático | Snap ao tile; preview de range; “confirm cast” em 2 taps |
| Web sem threads | Combat resolve no main; sem heavy gen em frame |
| Console cert | Input, saves, rating desde o design de UI |
| Anti-cheat multi | Servidor autoritativo (não depende de OS) |
| Mods em console | Desligar mods; PC only |

---

## 12. Roadmap de portabilidade (alinhado ao jogo)

| Fase do jogo | Ports |
|--------------|--------|
| Vertical Slice | Windows (+ Linux se fácil) |
| 3v3 solo divertido | Steam Deck gamepad pass |
| Demo pública | Web + Windows itch/Steam page |
| Early access | Windows/Linux/macOS |
| Co-op online | Mesmos PC ports; mobile co-op depois |
| 1.0 | Avaliar Android; consoles com partner |

---

## 13. Princípios finais

1. **Mesmas regras** em todas as plataformas.  
2. **Input e UI** adaptam; o design tático não é cortado no mobile — no máximo o *escopo de run* (runs mais curtas).  
3. **Web é vitrine**, não o único cliente.  
4. **Headless server** é uma “plataforma” também (Linux).  
5. Não manter forks de regras por OS.  

---

*Atualizar quando o primeiro export Web ou Android for feito de fato.*
