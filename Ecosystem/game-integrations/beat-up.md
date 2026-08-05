# Integração — Beat Up

## Mapeamento de domínio

| Sistema do jogo | Integração proposta |
|---|---|
| Score/wanted/fuga | Eventos off-chain; elegibilidade validada por seed/build/telemetria. |
| Veículos | Modelos base são unlocks; skins, placas e efeitos podem ser assets. |
| Rádio | Licenças e direitos não são presumidos; collectibles não concedem copyright. |
| Cidade procedural | Seed e versão entram no resultado para reprodução antifraude. |
| Desafios | Leaderboards e campanhas com budgets limitados. |

## Assets iniciais

- paint jobs, decals, placas, neon, horn packs, garage trophies e profile badges;
- coleção `beatup_cosmetics_v1`;
- stats de veículo nunca vêm da metadata on-chain; tuning é config assinada do jogo.

## Eventos

`drive_started`, `objective_completed`, `escape_completed`, `score_submitted`, `challenge_finalized`. `score_submitted` não gera reward sozinho; requer fechamento do desafio pelo backend.

## Antifraude específico

- registrar build version, seed, duração, checkpoints e hash de replay resumido;
- rejeitar versões/debug flags não elegíveis;
- detectar velocidade impossível, teleport, score rate anômalo e repetição coordenada;
- revisão manual para top rewards.

## Adaptação Godot

O mesmo autoload/SDK de Fallen Tactics expõe login e inventário. Carregamento de skin ocorre após validação do catálogo; falha usa visual padrão. API key e assinatura privilegiada ficam fora do cliente.

## Critérios de aceite

Trocar skin não altera física; seed reproduzível sustenta contestação; eventos são idempotentes; modo debug não recebe reward; indisponibilidade blockchain não impede partida.
