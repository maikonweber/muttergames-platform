# Documentação — Taskbar Planets Forger

> [DECIDIDO] Produto Windows-first, offline por padrão e sem blockchain, marketplace ou conta obrigatória no MVP.

## Índice

- [Visão do produto](product-vision.md)
- [GDD](game-design-document.md)
- [Design System, interface e geração procedural](design-system.md)
- [Ferramenta de seeds e sprites procedurais](procedural-sprite-tool.md)
- [SRS](software-requirements-specification.md)
- [Requisitos funcionais](functional-requirements.md) e [não funcionais](non-functional-requirements.md)
- [Regras de negócio](business-rules.md), [economia](game-economy.md), [progressão](progression-system.md) e [eventos](events-system.md)
- [Arquitetura](technical-architecture.md), [dados](data-model.md), [salvamento](save-system.md) e [janela desktop](desktop-window-behavior.md)
- [Protótipo Godot](../task-bar-planet-forger/README.md)
- [Classes e padrões de projeto](classes-and-design-patterns.md)
- [MVP](mvp-scope.md), [testes](testing-strategy.md), [roadmap](roadmap.md)
- [Conexão MutterGames](muttergames-connection-plan.md), [integração](muttergames-integration.md) e [marketplace](marketplace-plan.md)
- [ADRs](decisions/)

## Hipóteses e pendências

- [DECIDIDO] O MVP usa Godot 4.7; validar integrações nativas Windows durante o protótipo.
- [PENDENTE] Definir contrato público, autenticação e política de publicação da plataforma MutterGames.
- [RISCO] Uma janela sempre visível pode prejudicar foco; o usuário deve controlar posição, opacidade e pausa.

## Rastreabilidade inicial

| Visão | Épico | História | Caso de uso | RF | RN | Teste |
|---|---|---|---|---|---|---|
| Evolução discreta | Idle | US-RES-01 | UC-08 retorno offline | RF-016 | RN-006 | T-INT-04 |
| Criar mundos | Criação | US-CRIA-01 | UC-02 criar planeta | RF-009 | RN-003 | T-UNIT-02 |
| Desktop não intrusivo | Janela | US-DESK-01 | UC-10 alternar modo | RF-004 | RN-010 | T-E2E-03 |

## Convenções

Os valores de economia são [HIPÓTESE]. Requisitos usam `RF`, `RNF` e regras usam `RN`. Mudanças arquiteturais devem ter ADR.
