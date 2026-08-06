# Spec — MutterGames Game Kit (TOOL-12)

**Versão:** 1.0.0  
**Data:** 2026-08-05  
**Implementação:** `scripts/mutter-gamekit.sh`  
**Guia:** `scripts/creative-tools/gamekit.md`

## 1. Objetivo

Scaffold sem dependências externas (só Bash/`awk`) para dados de jogo, localização, componentes Godot, canvas de loop e release notes.

## 2. Comandos

| Comando | Saída |
|---|---|
| `data <item\|quest\|dialogue\|npc\|resource>` | JSON schema inicial |
| `locale` | CSV de chaves multi-idioma |
| `locale-check` | Valida colunas/textos vazios |
| `component <health\|state-machine\|save-data>` | Stub `.gd` |
| `release-notes` | Markdown editável |
| `loop` | Canvas MD de game loop |

## 3. Requisitos

| ID | Requisito | Aceite |
|---|---|---|
| GK-RF-01 | Schemas JSON válidos e mínimos | Arquivo parseável |
| GK-RF-02 | `locale-check` falha em célula vazia | Exit ≠0 |
| GK-RF-03 | Componentes com `class_name` | Abríveis no Godot 4 |
| GK-RNF-01 | Zero deps de rede/imagem | Roda só com Bash |

## 4. Limites

- CSV simples: sem vírgulas no texto.  
- Schemas são pontos de partida — regras de negócio ficam no jogo.  
- Não substitui Creative Tools nem OpenRouter.

## 5. Aceite

1. `data quest` + `locale` + `locale-check` passam.  
2. `component health` cria script válido.  
3. Guia e `usage` alinhados.
