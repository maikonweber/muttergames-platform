# PRJ-03 — Launcher Windows

**Pasta:** `apps/launcher`  
**Stack:** .NET 8 (`net8.0-windows`), WinForms  
**Status:** MVP  
**Owner:** Eng desktop / Produto

## Resumo

Cliente que consulta o catálogo da API, baixa ZIP com SHA-256, instala em `%LOCALAPPDATA%\MutterGames\Games` e abre o executável. Protocolo `muttergames://`.

## Spec detalhada

Fonte canônica de requisitos: [`../tools/03-launcher-spec.md`](../tools/03-launcher-spec.md).

## Docs locais

- [`apps/launcher/README.md`](../../apps/launcher/README.md)
- Build: `pnpm build:launcher` → `outputs/launcher/win-x64`

## Dependências

| Depende de | Uso |
|---|---|
| PRJ-02 API | Catálogo e metadados de release |
| PRJ-01 Web | Deep links de instalação |
| Jogos Godot exportados | Conteúdo do ZIP |
