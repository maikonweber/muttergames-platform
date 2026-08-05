# Integração — Fallen Tactics

## Mapeamento de domínio

| Sistema do jogo | Integração proposta |
|---|---|
| Runs e combate | 100% autoritativos/off-chain; hash de resultado para eventos elegíveis. |
| Classes/cartas base | Conteúdo de gameplay, não tokenizado. |
| Equipamentos | Itens de run permanecem locais; variantes cosméticas podem ser assets. |
| Relíquias | Sem NFT com poder. Colecionável/display-only ao completar desafios. |
| Meta-progressão | Entitlements off-chain vinculados ao Mutter ID. |
| Temporadas/torneios | Rewards limitadas após validação antifraude. |

## Assets iniciais

- skins de unidade, card backs, banners, emotes, portraits e troféus soulbound/display-only;
- coleção `fallen_cosmetics_v1`, traits fechados e metadata sem PII;
- compatibilidade cross-game definida por mapping, por exemplo banner → decal de veículo em Beat Up.

## Eventos

`run_started`, `encounter_completed`, `run_completed`, `boss_defeated`, `season_rank_finalized`. Apenas servidor dedicado/validador de resultado pode enviar eventos premiáveis.

## Adaptação Godot

- autoload `MutterGamesClient` para auth, inventory e telemetry;
- cache local somente para UX, nunca para confirmar posse/reward;
- cosmetics resolvidos por `asset_definition_id`, com fallback de asset padrão;
- multiplayer determinístico e anti-cheat devem existir antes de torneios com valor.

## Critérios de aceite

Jogador offline continua jogando; falha da chain não interrompe combate; NFT incompatível não quebra save; reward duplicado é recusado; desconectar wallet não remove progressão.
