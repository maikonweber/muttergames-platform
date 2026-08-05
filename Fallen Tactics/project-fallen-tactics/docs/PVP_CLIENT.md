# Cliente PVP Godot — Fallen Tactics

## Pré-requisitos

1. Servidor rodando: `pnpm dev:fallen-gs` (HTTP/WS `:4010`, UDP `:9001`)
2. Abrir o projeto no **Godot 4.7**

## Autoloads

- `NetClient` — WebSocketPeer + UDP ping
- `MultiplayerSession` — protocolo hello/command/event/snapshot

## Fluxo no jogo

1. Na zona, clique **PVP Online**
2. Informe o nome → **Criar sala PVP** (anote o código de 6 chars no log)
3. No 2º cliente/PC, **Entrar na sala** com o código
4. Ao completar 2 jogadores, abre `scenes/pvp/pvp_arena.tscn`
5. Na sua vez: escolha uma carta da **mão** (barra inferior, com custo em energia) para jogar, ou **Fim do turno** / **Render**
6. **UDP Ping** testa o canal complementar
7. A arena mostra HP/Energia em barras, Block/Postura/Vulnerável, números de dano flutuantes e contador regressivo do turno

## Config

Edite `fallen_net.cfg` (ou `user://fallen_net.cfg`):

```
[net]
ws_url="ws://127.0.0.1:4010/v1/session"
http_base="http://127.0.0.1:4010"
udp_host="127.0.0.1"
udp_port=9001
```

## Notas

- Combate PVP usa o motor de regras real do game server (porte de `EffectResolver`/`BattleUnit`), com deck/mão/energia/block/postura/vulnerável. Cartas dependentes de grid tático (movimento, Investida, Finta) ainda não estão disponíveis em PVP.
- Solo / zona / combate local permanecem intactos.
- JWT opcional: preencha `MultiplayerSession.auth_token` com o access token da API MutterGames.
- Se a conexão cair durante uma partida ativa, o cliente tenta reconectar automaticamente (reenviando o `resume_token` recebido no `welcome`) por até `reconnect_grace_ms` (padrão 60s) antes do servidor declarar W.O. para o oponente. O `resume_token` só vive em memória — fechar o jogo durante a queda impede a retomada.
