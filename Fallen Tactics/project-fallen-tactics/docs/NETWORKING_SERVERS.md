# Servidores, WebSocket e UDP — Project Fallen Tactics

**Status:** Arquitetura de referência (não implementado no VS)  
**Última atualização:** 2026-08-01  
**Relacionados:** [`MULTIPLAYER.md`](MULTIPLAYER.md) · [`PORTABILITY.md`](PORTABILITY.md) · [`GAME_OVERVIEW.md`](GAME_OVERVIEW.md)

---

## 1. Objetivo deste documento

Definir **como** o jogo pode falar com servidores de rede:

- Quando usar **WebSocket (TCP)**  
- Quando usar **UDP**  
- Como modelar mensagens para um tático **turn-based + deckbuilder**  
- Esboço de serviços (lobby, game session, relay)  

Não é um tutorial genérico de sockets: está amarrado às necessidades do Fallen Tactics.

---

## 2. Natureza do tráfego do jogo

| Momento | Frequência | Tamanho | Tolerância a lag | Perda de pacote |
|---------|------------|---------|------------------|-----------------|
| Lobby / chat | Baixa | Pequeno | Alta | Ruim (reenvia) |
| Comando de carta / fim de turno | Muito baixa (segundos–minutos) | Pequeno | **Alta** (1–5 s ok) | **Inaceitável** sem retry |
| Snapshot de estado | Baixa | Médio (1–20 KB) | Alta | Precisa reenvio ou full resync |
| Movimento de cursor (se compartilhado) | Média | Minúsculo | Média | Aceitável perder |
| Matchmaking | Baixa | Pequeno | Alta | TCP/WS |
| Heartbeat | Baixa | Minúsculo | — | UDP ou WS ping |
| Realtime action (não é nosso core) | Alta | — | Baixa | UDP |

**Conclusão de design de rede:**

> O núcleo multiplayer do Fallen Tactics é **orientado a eventos confiáveis** (commands), não a stream de 60 Hz.  
> **WebSocket é o transporte default.**  
> **UDP é complementar** (relay, heartbeat, presence, ou futuro canal de baixa latência), não o substituto do canal de regras.

---

## 3. WebSocket (TCP) — canal principal

### 3.1 O que é (no nosso contexto)

- Conexão **persistente**, full-duplex, sobre TCP (geralmente porta 443 via TLS: `wss://`).  
- Mensagens **ordenadas** e **confiáveis** (retransmissão do TCP).  
- Funciona em **browser**, mobile e desktop.  
- Atravessa firewalls/proxies melhor que UDP arbitrário.

### 3.2 Por que é ideal para Fallen Tactics

1. Cada `PlayCard` / `EndTurn` **não pode se perder**.  
2. Ordem importa (não aplicar EndTurn antes de PlayCard).  
3. Co-op turn-based não precisa de 20 ms de RTT.  
4. Portabilidade Web (demo + co-op browser).  
5. TLS (`wss`) simples para auth e privacidade.

### 3.3 Casos de uso no projeto

| Serviço | WebSocket? |
|---------|------------|
| Game session (commands + state) | **Sim — principal** |
| Lobby / room codes | **Sim** |
| Chat de sala | Sim |
| Notificações de “sua vez” | Sim |
| Replay streaming | Sim |
| Upload de telemetria | REST também ok |

### 3.4 Esboço de protocolo (camada de aplicação)

Transporte: WebSocket binary ou texto JSON (JSON no MVP; binary MessagePack depois).

#### Client → Server

```json
{
  "v": 1,
  "type": "command",
  "session_id": "abc",
  "client_id": "p2",
  "seq": 42,
  "cmd": {
    "op": "play_card",
    "unit_id": "hero_espadachim",
    "card_uid": "c_103",
    "target": { "cell": [4, 3] }
  }
}
```

```json
{
  "v": 1,
  "type": "command",
  "seq": 43,
  "cmd": { "op": "end_turn", "unit_id": "hero_espadachim" }
}
```

#### Server → Clients

```json
{
  "v": 1,
  "type": "event",
  "server_seq": 9001,
  "events": [
    { "op": "card_played", "unit_id": "hero_espadachim", "card_id": "golpe", "resolved": true },
    { "op": "damage", "target_id": "goblin_1", "amount": 5, "hp_after": 9 },
    { "op": "timeline", "values": { "hero_espadachim": 12, "goblin_1": 5 } }
  ]
}
```

```json
{
  "v": 1,
  "type": "snapshot",
  "server_seq": 9001,
  "state": { "... estado completo resumido ..." }
}
```

#### Controlo de sessão

| type | Função |
|------|--------|
| `hello` | version, auth token, protocol_version |
| `welcome` | client_id, session config, seed |
| `ping` / `pong` | keepalive |
| `resync_request` | client pede snapshot |
| `error` | comando inválido, não é sua vez, etc. |
| `goodbye` | shutdown graceful |

### 3.5 Regras de servidor WebSocket

1. **Autoritativo:** só o servidor aplica opcodes e RNG (seed interna).  
2. **Seq numbers:** client `seq` para idempotência; server `server_seq` para ordenar UI.  
3. **Validação:** ownership da unidade, custo de energia, range, fase do turno.  
4. **Rate limit:** ex. 10 commands/s (anti-spam; humano real usa bem menos).  
5. **Timeout de turno:** server auto-`end_turn` ou IA se estourar.  
6. **TLS em produção:** sempre `wss://`.  

### 3.6 Stack sugerida (exemplos)

| Camada | Opções |
|--------|--------|
| Game server | Godot headless · Rust (axum/tokio-tungstenite) · Node (uWebSockets) · Go (gorilla/nhooyr) |
| Lobby | Mesmo processo no MVP; serviço separado depois |
| Auth | JWT / session token emitido por HTTPS REST |
| Deploy | Linux VPS · Fly.io · Railway · k8s depois |

**MVP friends:** um processo `fallen-game-server` que:

- Aceita WS  
- Cria sala por código  
- Roda 1 combat/zone state machine por sala  

### 3.7 Limitações do WebSocket

| Limite | Impacto |
|--------|---------|
| Head-of-line blocking (TCP) | Um pacote perdido atrasa os seguintes — ok em turn-based |
| Não é “UDP rápido” | Ruim para action 60 Hz (não é nosso caso) |
| Proxies idle timeout | Precisa ping periódico (20–30 s) |
| Escala horizontal | Precisa sticky sessions ou room affinity |

---

## 4. UDP — canal complementar

### 4.1 O que é (no nosso contexto)

- Datagramas **sem conexão**, **sem garantia** de entrega/ordem.  
- Menor overhead; pode ser mais baixo latency.  
- NAT traversal é mais difícil (STUN/TURN, ou relay).  
- **Browsers não expõem UDP genérico** (só via WebRTC).

### 4.2 Quando UDP faz sentido no Fallen Tactics

| Caso | Usar UDP? | Nota |
|------|-----------|------|
| `PlayCard` / resolução de combate | **Não** (default) | Precisa confiabilidade → WS ou UDP+ack próprio |
| Heartbeat / latency probe | Opcional | WS ping já resolve no MVP |
| Cursor de co-op (“olha este tile”) | Sim, se quiser | Perda ok; unreliabe |
| Voice | Não reinventar; Discord/WebRTC | — |
| Action combat futuro | Sim + sequencing | Fora do core atual |
| Relay de host atrás de NAT | Possível | Ou usar WS relay só |
| Servidor de matchmaking | Não | HTTPS/WS |

### 4.3 Se implementar “UDP confiável” (não reinvente à toa)

Precisaria recriar no app:

- Sequence numbers  
- ACK / NACK  
- Retransmit  
- Ordenação opcional  
- Congestion control  

Isso é essencialmente **reimplementar TCP/QUIC**.  
Para turn-based: **não vale a pena** no MVP.

Bibliotecas se um dia precisar:

- **ENet** (Godot high-level multiplayer usa conceitos similares)  
- **QUIC** (confiável sobre UDP, moderno)  
- **WebRTC DataChannel** (browser; reliable ordered mode ≈ TCP)  

### 4.4 Esboço de pacote UDP (só se necessário)

```text
[ magic u32 ][ version u8 ][ type u8 ][ session_hash u32 ]
[ seq u32 ][ ack u32 ][ payload... ]
```

Types exemplo: `0x01 ping`, `0x02 cursor`, `0x03 unreliable_fx`.

**Nunca** colocar “causei 50 de dano” só em UDP sem validação server-side em canal confiável.

---

## 5. Arquitetura de serviços recomendada

### 5.1 MVP (co-op com amigos)

```text
                 wss://
[Godot Client A] ─────┐
                      ├──► [Game Server (1 processo)]
[Godot Client B] ─────┘         │
                                ├─ RoomManager (códigos)
                                ├─ Session (state + command bus)
                                └─ Optional: HTTP /health /create_room
```

- 1 servidor, muitas salas pequenas  
- Estado em memória; snapshot em disco opcional  
- Sem microserviços  

### 5.2 Produção pequena

```text
[Clients]
    │ wss
    ▼
[Edge / Load Balancer TLS]
    │
    ▼
[Lobby Service] ---- allocates ----► [Game Pods]
    │                                   │
    └── Redis (room → pod affinity)     └── Session state
```

### 5.3 Papéis

| Serviço | Responsabilidade |
|---------|------------------|
| **Lobby** | Criar/entrar sala, auth, version check |
| **Game Server** | Simular regras, validar commands, broadcast events |
| **Relay** (opc.) | Encaminhar WS se host-P2P; ou TURN para WebRTC |
| **Persistence** (opc.) | Meta unlocks, rankings |
| **Telemetry** | Crashes, desync reports |

---

## 6. Godot — opções de implementação

| Abordagem | Uso |
|-----------|-----|
| **WebSocketClient / WebSocketPeer** | Cliente PC/Web falando com server custom |
| **Godot High-Level Multiplayer (ENet/WebRTC)** | Protótipo rápido host-client; menos controle fino de protocolo |
| **HTTPRequest** | Login, create room, fetch config |
| **Headless Godot** | Server de jogo na mesma linguagem (pro) |
| **Server externo (Rust/Go)** | Melhor ops a longo prazo; engine de regras portada ou shared logic |

### Recomendação pragmática

| Fase multiplayer | Rede |
|------------------|------|
| Hotseat | Nenhuma |
| Replay | Arquivo local de commands |
| Co-op friends | **WebSocket** + server (Godot headless ou Rust) |
| Depois | Avaliar se HLAPI Godot economiza tempo |

**Separar** `CombatEngine` da UI desde já facilita server headless.

---

## 7. Segurança

| Ameaça | Mitigação |
|--------|-----------|
| Cliente mente dano | Servidor resolve opcodes |
| Replay de command antigo | seq + idempotency key + expiry |
| Flood | Rate limit + kick |
| MITM | `wss` + cert válido |
| Abuso de room | Auth token; max players; report |
| Version skew | `protocol_version` + `content_hash` no hello |
| Injection em JSON | Schema fixo; rejeitar campos desconhecidos críticos |

---

## 8. Confiabilidade e reconexão

```text
Client reconnect
  → hello + session_token + last_server_seq
  → Server: se sessão viva, envia snapshot
  → Client reconstrói UI
  → Resume commands
```

Políticas:

| Evento | Política MVP |
|--------|--------------|
| Disconnect &lt; 60 s | Reserva slot; pode reconectar |
| Disconnect &gt; 60 s | IA assume ou pausa co-op |
| Server restart | Runs ativas perdem (MVP); depois persist snapshot |

---

## 9. Custos e escala (ordem de grandeza)

Turn-based é **barato**:

- 1000 salas × 2 jogadores × 1 msg a cada 10 s ≈ tráfego irrisório vs action game  
- CPU: validar command + simular efeitos (leve se em data-driven)  
- Gargalo real: **salas ociosas em memória** e **ops**, não banda  

Começar com **1 VPS pequena**; medir antes de k8s.

---

## 10. Comparativo rápido WS vs UDP (para o time)

| Critério | WebSocket | UDP |
|----------|-----------|-----|
| Confiável por padrão | Sim | Não |
| Ordenado | Sim | Não |
| Browser | Sim | Só WebRTC |
| Firewall/NAT | Fácil (443) | Difícil |
| Latência típica | Boa o suficiente p/ turnos | Pode ser menor |
| Complexidade app | Baixa | Alta se “confiável” |
| Uso Fallen (core) | **Commands + state** | Cursor / probe / futuro |
| Uso Fallen (secundário) | Lobby, chat | Opcional |

---

## 11. Plano de implementação de rede (checklist)

### N0 — Preparação (sem servidor)

- [ ] Extrair `Command` + `apply(state) -> events`  
- [ ] Testes unitários de resolve  
- [ ] Gravar replay local (lista de commands + seed)  

### N1 — Servidor WebSocket mínimo

- [ ] `hello` / `welcome`  
- [ ] Sala com código de 6 chars  
- [ ] 2 clients; eco de chat  
- [ ] `end_turn` + state broadcast stub  

### N2 — Combate online

- [ ] `play_card` validado  
- [ ] Snapshot + events  
- [ ] Turn timer  
- [ ] Kick por comando inválido  

### N3 — Zona + co-op mapa

- [ ] `zone_move` / activities  
- [ ] Persistência de session  

### N4 — UDP opcional

- [ ] Medir se há necessidade real  
- [ ] Só cursor/heartbeat se WS não bastar  

### N5 — Produção

- [ ] `wss` + auth  
- [ ] Métricas, logs, health  
- [ ] Reconnect testado  

---

## 12. Exemplos de endpoints (alvo)

| Endpoint | Protocolo | Função |
|----------|-----------|--------|
| `https://api.fallen.example/v1/auth` | HTTPS | Token |
| `https://api.fallen.example/v1/rooms` | HTTPS | POST cria sala |
| `wss://game.fallen.example/v1/session` | WebSocket | Jogo |
| `udp://game.fallen.example:9001` | UDP | Opcional (não MVP) |

---

## 13. Decisões travadas (proposta)

1. **Canal de regras = WebSocket confiável.**  
2. **Servidor autoritativo** (ou host que roda a mesma simulação).  
3. **UDP não é requisito do multiplayer turn-based.**  
4. **Browser** entra via WS/WebRTC reliable, nunca UDP raw.  
5. **Não** construir netcode realtime estilo FPS.  

---

## 14. Glossário de rede

| Termo | Significado |
|-------|-------------|
| WebSocket | Canal TCP full-duplex orientado a mensagens |
| `wss` | WebSocket sobre TLS |
| UDP | Datagrama não confiável |
| Authoritative server | Servidor manda no estado canônico |
| Command | Intenção do jogador a validar |
| Event / Delta | Resultado já resolvido a renderizar |
| Snapshot | Estado completo para resync |
| NAT traversal | Fazer peers se acharem atrás de roteador |
| Relay | Servidor que só encaminha pacotes |
| Head-of-line blocking | TCP segura ordem; um lost atrasa a fila |

---

*Quando o primeiro protótipo online existir, anexar aqui: schema final das mensagens, portas, e diagrama de deploy real.*
