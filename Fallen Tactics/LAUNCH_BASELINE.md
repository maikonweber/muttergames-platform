x'# Fallen Tactics — Baseline de lançamento

**Papel:** primeiro lançamento da MutterGames  
**Fase atual:** pre-alpha / vertical slice  
**Entrada oficial:** `res://scenes/zone/zone_scene.tscn`

## Promessa do primeiro lançamento

Um tactics roguelike isométrico em que uma party de três heróis explora uma zona, escolhe quando enfrentar patrulhas e resolve combates usando cartas, posição, terreno, facing e timeline.

## Escopo da primeira alpha

- Uma zona explorável com patrulhas, POIs, fog of war e retorno após combate.
- Party de três arquétipos já existentes.
- Combate tático legível, três encontros e boss.
- Runs completas com vitória, derrota e reinício confiável.
- Build Windows jogável; Web somente após medir performance e compatibilidade.
- Save local versionado e telemetria opt-in mínima.

## Fora da primeira alpha

- Token, marketplace, NFT negociável ou recompensa financeira.
- Multiplayer online, bridge, DAO e wallet obrigatória.
- Dez classes, mundo aberto, meta-progressão extensa ou arte final completa.

Blockchain entra depois do core loop validado, inicialmente apenas como identidade e cosméticos opcionais.

## Prioridades

### P0 — build confiável

- [ ] Instalar/localizar Godot 4.7 e executar scan headless sem erros.
- [ ] Confirmar que Zone → Combat → Zone funciona três vezes seguidas.
- [ ] Corrigir crash, softlock, array out-of-bounds e perda de estado.
- [ ] Criar smoke test automatizado para carregar todas as cenas e scripts.
- [ ] Iniciar Git no diretório correto e definir política de builds/arte gerada.

### P1 — vertical slice publicável

- [ ] Menu inicial, nova run, continuar, opções e sair.
- [ ] Save versionado, escrita atômica e recuperação de arquivo corrompido.
- [ ] Tutorial curto: movimento por cartas, facing, terreno e timeline.
- [ ] Pass de UX: feedback visual/sonoro, legibilidade e gamepad.
- [ ] Balance/playtest de pelo menos 20 runs com métricas documentadas.

### P2 — integração MutterGames

- [ ] `MutterGamesClient` atrás de feature flag e modo offline-first.
- [ ] Mutter ID opcional, sem bloquear o primeiro acesso.
- [ ] Inventário cosmético somente leitura.
- [ ] Eventos de run enviados pelo servidor/validador, nunca premiados pelo cliente.

## Critérios de aceite da alpha

1. Cinco playtesters concluem ou perdem uma run sem ajuda do desenvolvedor.
2. Zero crash/softlock em 50 runs de smoke/playtest.
3. O jogador identifica posição, terreno e timeline como decisões relevantes.
4. p95 de frame time dentro do alvo da plataforma em cenas de maior carga.
5. Falha de rede não impede iniciar ou concluir uma run solo.
6. Build possui versão, changelog, licença de assets e canal de feedback.

## Riscos abertos

| Risco | Ação imediata |
|---|---|
| Documentação e main scene divergiam | Zona definida como entrada oficial; manter estado real atualizado. |
| Godot não está no caminho documentado | Localizar/reinstalar antes de afirmar build verde. |
| Logs históricos contêm erros | Regerar logs limpos e separar falhas antigas de regressões atuais. |
| Projeto principal não é repositório Git | Versionar antes de mudanças amplas. |
| Dados de gameplay ainda hardcoded | Migrar gradualmente após estabilizar o loop. |

## Próxima milestone

**M0 — Alpha Bootable:** abrir na zona, iniciar combate, vencer/perder, retornar corretamente e encerrar sem erros de script. Nenhuma feature nova entra antes desse gate.
