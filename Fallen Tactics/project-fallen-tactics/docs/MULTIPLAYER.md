# Multiplayer — Project Fallen Tactics

**Status:** Design / não implementado no Vertical Slice  
**Última atualização:** 2026-08-01  
**Relacionados:** [`GAME_OVERVIEW.md`](GAME_OVERVIEW.md) · [`NETWORKING_SERVERS.md`](NETWORKING_SERVERS.md) · [`PORTABILITY.md`](PORTABILITY.md)

---

## 1. Por que multiplayer neste jogo?

| Valor | Como melhora o jogo |
|-------|---------------------|
| **Co-op tático** | Dois jogadores dividem o party 3v3 — coordenação de decks e flancos |
| **Versus assíncrono** | Desafios de build / “ghost runs” sem lag de turno a turno |
| **Draft / arena** | Competitivo de cartas e composição (pós-core) |
| **Compartilhar runs** | Seed de região + replay (social, não necessariamente realtime) |

**O que multiplayer NÃO deve fazer:**

- Transformar o single-player em obrigação online  
- Priorizar netcode antes do núcleo 3v3 + zona ser divertido solo  
- Exigir always-online para progressão básica  

**Regra de produto:** *Single-player é sagrado. Multiplayer é camada.*

---

## 2. Modos propostos (por prioridade)

### P0 — Não fazer ainda

Qualquer online realtime até o combate multi-unidade solo estar sólido.

### P1 — Co-op local (hotseat / same screen)

| Item | Detalhe |
|------|---------|
| O quê | 2 jogadores, mesmo device, turnos do herói de cada um |
| Por quê | Zero netcode; valida “party multiplayer” de UX |
| Escopo | Cada jogador controla 1–2 heróis no 3v3 |
| Balance | Sem desync; só input e UI de “vez do P2” |

**MVP multiplayer real = local first.**

### P2 — Co-op online turn-based (recomendado como 1º online)

| Item | Detalhe |
|------|---------|
| O quê | 2 jogadores cooperam na **mesma run** (zona + combate) |
| Sync | **Lockstep de intenções** ou **servidor autoritativo de estado** |
| Ritmo | Turn-based: latência alta é tolerável (1–5 s ok) |
| Ideal para | WebSocket (ver NETWORKING_SERVERS.md) |

**Fluxo de turno online:**

```text
Servidor (ou host) declara unidade ativa
  → Cliente do dono da unidade envia Command
  → Servidor valida e aplica
  → Broadcast StateDelta / snapshot
  → Clientes renderizam
```

### P3 — Versus 1v1 (draft + combate)

| Item | Detalhe |
|------|---------|
| O quê | Cada lado controla até 3 unidades; decks pré-built ou draft |
| Risco | Balance competitivo é um jogo inteiro |
| Rede | Mesmo pipeline de commands; anti-cheat mais crítico |

### P4 — Features sociais leves

| Feature | Descrição |
|---------|-----------|
| Seed share | Amigos jogam a mesma região solo e comparam |
| Replay | Grava lista de Commands; assiste offline |
| Leaderboard de seeds | Opcional, pós-lançamento |
| Espectador | Consome o mesmo stream de estado |

### Fora de escopo (por enquanto)

- MMO open world  
- 4v4 realtime action  
- Cross-play massivo no day one  
- VoIP integrado (usar Discord etc.)  

---

## 3. Modelo de autoridade (decisão de arquitetura)

### Opção A — Host autoritativo (listen server)

```text
[Player A = Host + Server logic] ←→ [Player B = Client]
```

| Prós | Contras |
|------|---------|
| Barato, sem VPS obrigatório | Host trapaceia / desliga |
| Bom para co-op casual com amigos | NAT / firewall do host |

**Bom para:** early multiplayer, playtest com amigos.

### Opção B — Servidor dedicado autoritativo (recomendado a médio prazo)

```text
[Client A] ──┐
             ├── WebSocket/UDP ──► [Game Server] ──► estado canônico
[Client B] ──┘
```

| Prós | Contras |
|------|---------|
| Anti-cheat real | Custo de infra |
| Reconnect, matchmaking | Ops e escalabilidade |

**Bom para:** versus, ranked, co-op público.

### Opção C — Peer lockstep puro (determinístico)

Todos simulam o mesmo; só trocam inputs.

| Prós | Contras |
|------|---------|
| Pouca banda | RNG e float devem ser determinísticos |
| | Desync = fim de partida; hard de debug |

**Só viável se** o combat engine for 100% determinístico (seed + inteiros, sem random local).

### Decisão recomendada para Fallen Tactics

| Fase | Modelo |
|------|--------|
| Local hotseat | Sem rede |
| Online co-op friends | **Host autoritativo** + WebSocket relay opcional |
| Público / versus | **Servidor dedicado** + commands validados |
| Replay / seed | Log de commands + seed (offline) |

**Não** começar com lockstep puro até o motor ser determinístico de propósito.

---

## 4. O que sincronizar

### Estado canônico (servidor / host)

- Seed da run e da zona  
- Posições e HP/energia/block/stance/facing de unidades  
- Decks: draw/hand/discard (mãos só do dono + tamanho público opcional)  
- Timeline values  
- Flags de mapa (inimigos vivos, POIs usados)  
- Relíquias e equipamentos  

### Mensagens de alto nível (Commands)

```text
PlayCard { unit_id, card_uid, target_cell | target_unit_id, extra? }
EndTurn { unit_id }
SelectLevelUp { option_id }
ZoneMove { path[] }
StartActivity { activity_id, choice_id }
EncounterChoice { fight | flee | spy }
DeployUnit { unit_id, cell }
RequestFleeCombat {}
```

### O que NÃO confiar no cliente

- Dano calculado no client  
- “Eu comprei esta carta lendária” sem validação  
- Posição teleportada  
- RNG local sem seed do servidor  

**Regra:** cliente envia **intenção**; servidor resolve **opcodes**.

---

## 5. Divisão de controle (co-op)

### Modelo recomendado — Party split

| Jogador | Controle |
|---------|----------|
| P1 | Herói A + (opcional) C |
| P2 | Herói B + (opcional) C compartilhado |

Ou:

| Jogador | Controle |
|---------|----------|
| P1 | Espadachim + Guardião |
| P2 | Patrulheiro |

No mapa:

- **Token único de party** no MVP: quem “tem o bastão” move a party no turno de mapa  
- Ou turnos de mapa alternados  

### Fog of war co-op

MVP: **visão compartilhada** (menos frustrante, menos banda).  
Hardcore futuro: visão por herói (só se for feature de design, não default).

---

## 6. Latência, desconexão e fairness

| Problema | Mitigação |
|----------|-----------|
| Lag no turno | Timer generoso (45–90 s) + botão “passar” |
| Desistência | IA assume o herói do ausente (simples) ou pausa |
| Reconnect | Servidor guarda snapshot; client pede full state |
| Host quit (listen) | Migrar host **ou** encerrar run com save local P2 |
| Cheat de carta | Servidor possui o deck real; client só UI |

Turn-based = **não** precisa de prediction complexa de movimento estilo FPS.

---

## 7. Matchmaking e salas (futuro)

```text
[Lobby Service]
  create_room / join_code / quick_match
       │
       ▼
[Game Server alocado]
  session_id, seed, party config
       │
       ▼
[Clients conectam com token]
```

MVP friends: **código de 6 caracteres** (sala), sem matchmaking ELO.

---

## 8. Segurança e economia

- Contas: opcional no co-op friends; obrigatória se ranked/meta online  
- Progressão meta: preferir **desbloqueios cosméticos / cartas** com validação server-side se online  
- Não vender power pay-to-win no competitive  
- Rate limit de commands; validar range/custo/ownership da carta  

---

## 9. Pipeline de implementação multiplayer

| Fase | Entrega | Dependência |
|------|---------|-------------|
| M0 | Separar `Command` + `CombatEngine.resolve(command, state)` pure-ish | Refator solo |
| M1 | Hotseat local 2P | Party 2–3 heróis |
| M2 | Serialização de State + log de commands (replay offline) | M0 |
| M3 | Host co-op via WebSocket (mesma rede / relay) | NETWORKING |
| M4 | Reconnect + IA de abandono | M3 |
| M5 | Servidor dedicado + salas com código | Infra |
| M6 | Versus draft (opcional) | Balance estável |

**Critério para começar M3:** combate 3v3 solo divertido + engine de commands testável sem UI.

---

## 10. Impacto no design de jogo

| Sistema | Ajuste multiplayer |
|---------|---------------------|
| Mãos secretas | Só dono vê cartas; oponente vê contagem |
| Timer de mapa | Impede AFK infinito |
| Atividades | Escolha conjunta ou voto com timeout |
| RNG de recompensa | Seed servidor; mesma roll para todos |
| Chat | Texto opcional; não bloqueia turno |

---

## 11. Métricas de sucesso (quando existir)

- % de runs co-op completadas sem desync  
- Tempo médio de espera por turno  
- Taxa de reconnect bem-sucedido  
- “Queremos jogar de novo” em playtest co-op  

---

## 12. Resumo executivo

1. **Solo first.**  
2. **Hotseat** valida UX multiplayer.  
3. **Online turn-based co-op** com servidor/host autoritativo e WebSocket.  
4. UDP só se houver camada realtime (ex.: presença, voz não, ou sync auxiliar) — ver NETWORKING_SERVERS.md.  
5. Versus e ranked **depois** do co-op casual.  

---

*Não implementar rede antes da Fase 1B/3 da roadmap de gameplay, salvo experimento isolado em branch.*
