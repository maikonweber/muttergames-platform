# ADR-005 — Godot como motor do jogo

**Status:** Aceito.  
**Data:** 2026-08-04.

## Contexto

O projeto precisa de uma aplicação desktop leve com loop idle, UI compacta e cena 2D. A decisão inicial entre Tauri e Godot ainda estava marcada como proposta.

## Decisão

O MVP será implementado em **Godot 4.7 com GDScript**. A cena usa `Control`; regras e persistência ficam em scripts sem dependência da cena. `GameState` é o ponto de aplicação e entidades como `Planet` e `ResourceInventory` permanecem testáveis isoladamente.

## Consequências

- Menos integração entre motor e interface para o MVP.
- Build e exportação focados em Windows.
- Bandeja, ancoragem real à barra de tarefas, clique através e notificações do Windows podem requerer GDExtension/plugin. Eles serão adaptadores, não requisitos das entidades de domínio.
