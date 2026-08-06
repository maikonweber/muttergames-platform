# Integração — Taskbar Planets Forger

## Posicionamento

Produto **Windows-first, offline por padrão**. Blockchain, marketplace e conta MutterGames **não** entram no MVP do jogo (`TaskBarPlanetsForger/docs/`). A integração com a plataforma é fase posterior, descrita em `muttergames-connection-plan.md` e `muttergames-integration.md`.

## Mapeamento de domínio

| Sistema do jogo | Integração proposta (pós-MVP) |
|---|---|
| Idle / órbitas / forja | 100% local; progresso offline limitado |
| Recursos (Matéria, Energia, Biomassa, …) | Soft currency off-chain; sem tokenização de poder |
| Essência / prestígio | Entitlement ou colecionável cosmético, nunca pay-to-win |
| Seeds / aparência de planetas | Metadados locais; eventual colecionável cosmético com `visual_seed` |
| Janela desktop / bandeja | Fora do escopo da API; cliente nativo |

## Assets iniciais (quando houver catálogo)

- skins de órbita, efeitos de supernova, frames de forja, badges de civilização;
- coleção sugerida `planets_cosmetics_v1`;
- sprites procedurais devem carregar `generator_version` + seed na metadata.

## Eventos futuros (não no MVP do jogo)

`session_started`, `planet_forged`, `civilization_evolved`, `supernova_completed`. Somente após auth Mutter ID e policy de recompensas.

## Ferramentas

- Seed Lab: [`../tools/04-seed-lab-spec.md`](../tools/04-seed-lab-spec.md)
- Pós-processamento de PNG: Creative Tools [`../tools/02-creative-tools-spec.md`](../tools/02-creative-tools-spec.md)
- Distribuição Windows: Launcher [`../tools/03-launcher-spec.md`](../tools/03-launcher-spec.md)

## Adaptação Godot (fase plataforma)

- Autoload cliente somente quando o toggle de conta estiver habilitado.
- Save local permanece fonte de verdade do idle; nuvem é backup/opt-in.
- Nunca aceitar reward on-chain direto do cliente.

## Gates

1. MVP offline estável e telemetria local opcional.  
2. Contrato de auth/publicação MutterGames definido (`docs` do jogo: pendência explícita).  
3. Launcher catalog entry com ZIP + SHA-256.
