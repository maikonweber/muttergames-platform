# Servidores PVP — status de implementação

**Atualizado:** 2026-08-04  
**Código:** `apps/fallen-game-server`  
**Doc de arquitetura:** [`NETWORKING_SERVERS.md`](NETWORKING_SERVERS.md)

## Implementado (N1 + N2 regras reais + N5 reconnect + UDP N4)

| Item | Status |
|------|--------|
| HTTP health + rooms | OK (`:4010`) |
| WebSocket session (`/v1/session`) | OK |
| Room codes 6 chars | OK |
| PVP 1v1 autoritativo | OK — regras reais (ver abaixo) |
| `hello` / `welcome` / `command` / `event` / `snapshot` | OK |
| Turn timer | OK |
| UDP ping/pong (`:9001`) | OK |
| JWT opcional (MutterGames) | OK |
| Cliente Godot `NetClient` + `MultiplayerSession` | OK |
| Lobby PVP na Zone UI | OK |
| Arena PVP (`scenes/pvp/pvp_arena.tscn`) | OK — mão real, barras de HP/Energia, avatares com FX, contador de turno |
| Motor de regras (`src/combat/cards.ts` + `rules.ts`) | OK |
| Reconnect com grace period (`resume_token`) | OK |

### Motor de combate no servidor

O stub de "5 de dano fixo" foi substituído por um porte fiel de
`scripts/combat/effect_resolver.gd` + `scripts/combat/unit.gd` (Godot) para
`apps/fallen-game-server/src/combat/`:

- `cards.ts`: biblioteca de cartas (subconjunto de `card_library.gd` sem
  opcodes dependentes de grid — `move`, `charge`, `delay_timeline`,
  `face_toward_caster`, `mark_duel`, `aoe_adjacent` por célula) e o deck
  inicial de PVP (`PVP_STARTER_DECK`).
- `rules.ts`: `resolveCard` (porte de `EffectResolver.resolve`) e
  `applyDamage`/`addBlock` (porte de `BattleUnit.take_damage`/`add_block`),
  cobrindo dano com bônus de postura Ofensiva/Pressão/próximo-ataque, Block,
  Vulnerável (+50% dano), Guarda (+1 Block), Parry (nega o próximo golpe e
  regenera 1 energia), `strip_block`, e o requisito de setup da Lâmina Final.
- `PvpSession` agora mantém deck/mão/descarte por jogador (compra 5 por
  turno, descarta a mão ao fim do turno — igual ao solo), energia com
  regeneração, e envia snapshots **personalizados** por cliente: cada
  jogador só vê a própria mão; o oponente recebe apenas `hand_count`.
- Novos eventos: `block_gained`, `block_stripped`, `stance_changed`,
  `vulnerable_applied`, `reaction_triggered`, `card_blocked`, `hand_drawn`.

Fora do escopo por não haver grid tático no servidor ainda: multiplicadores
de dano por flanco/costas (`facing`), cartas de movimento, `Investida`
(charge), Finta/Duelo/Provocar (dependem de posição), e AoE por célula.
Essas continuam como trabalho futuro quando o grid for portado (ver item
"Ainda não" abaixo).

### Arena Godot rica (item 2 do roadmap)

`scenes/pvp/pvp_arena.tscn` + `scripts/pvp/pvp_arena.gd` deixaram de mostrar
apenas HP em texto e um botão fixo "Jogar Golpe":

- Barras de HP e Energia (self + oponente), atualizadas a cada `snapshot`.
- Mão real como botões dinâmicos (nome, custo, tooltip com descrição via
  `CardLibrary`), desabilitados quando não é seu turno ou falta energia.
- Avatares dos dois lutadores com flash + knockback ao sofrer dano, e
  números flutuantes (`-N`, `+N Block`, `Vulnerável!`, `PARRY!`,
  `Bloqueado!`) reagindo aos eventos do servidor.
- Linha de status (Postura/Block/Vulnerável/Sem-ataque) por jogador.
- Contador regressivo do turno (`deadline_at` do snapshot convertido para
  segundos restantes).

Ainda não há grid/unidades posicionadas — os "avatares" são placeholders
coloridos até o grid tático ser portado para o servidor.

### Reconnect com grace period (item 3 do roadmap)

Antes, uma queda de WebSocket só marcava `connected: false` e emitia
`player_left` — não havia como o mesmo jogador retomar a sessão (`hello`
sempre criava um assento novo, e a partida ficava travada esperando um
jogador que nunca mais voltaria).

- `welcome` agora inclui `resume_token` (segredo por assento, gerado em
  `addPlayer`) e `reconnect_grace_ms` (config `FALLEN_GS_RECONNECT_GRACE_MS`,
  padrão 60s).
- `hello { client_id, resume_token }` reclama o assento existente —
  `RoomManager.resumeClient` + `PvpSession.resume` validam o token e chamam
  `markConnected(true)`, revalidando snapshot/mão automaticamente.
- Ao cair a conexão durante uma partida ativa (`PvpSession.markConnected(false)`),
  um timer de graça é armado; se o jogador não voltar dentro do prazo, a
  partida é encerrada por W.O. (`finishMatch(..., 'disconnect_timeout')`)
  para o oponente que ficou.
- `RoomManager.disconnect()` não apaga mais o registro do cliente
  imediatamente — só remove o socket morto — para permitir a retomada.
- Novos eventos: `player_left` (agora com `grace_ms`) e `player_reconnected`.
- Cliente Godot (`MultiplayerSession`) guarda `resume_token` e, ao detectar
  queda de WS durante uma sessão ativa, tenta reconectar automaticamente a
  cada ~1.5s até o grace period expirar, reenviando `hello` com
  `client_id`/`resume_token` em vez de criar sala nova. A arena mostra o
  status de reconexão no log/HUD.

Validado via testes de fumaça: resume bem-sucedido com token válido,
rejeição de token inválido (`RESUME_TOKEN_INVALID`), e W.O. automático
após o grace period expirar sem retomada.

## Ainda não

- Portar o grid tático (`TacticalGrid`) e cartas de movimento/posição
  (Passo de Combate, Sprint, Investida, Giro, Finta, Desafio, Corte em Arco)
- Multiplicadores de dano por flanco/costas (dependem de facing + grid)
- Persistir `resume_token` em disco no cliente (hoje só sobrevive em memória
  — se o processo do jogo fechar, a retomada não é possível)
- Auth forte (`FALLEN_GS_REQUIRE_AUTH=true` por padrão)
- Matchmaking ELO
- `wss` em produção
- Deck selecionável por classe (hoje há um deck fixo de PVP)
