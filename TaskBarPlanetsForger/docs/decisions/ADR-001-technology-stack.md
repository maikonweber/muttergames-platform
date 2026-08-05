# ADR-001 — Stack tecnológica

**Status:** [PROPOSTA]. **Contexto:** aplicação desktop compacta e eficiente.

| Opção | Prós | Contras |
|---|---|---|
| Tauri + React | pacote leve, APIs Rust/nativas | validar plugins/janela Windows |
| Electron + React | ecossistema amplo | memória e pacote maiores |
| Godot | renderização de jogo madura | integração de janela/app menos alinhada ao portal TS |

**Decisão proposta:** Tauri + React + TypeScript, PixiJS e camada Rust somente quando necessário. Validar múltiplos monitores, bandeja e posicionamento antes de comprometer a stack.
