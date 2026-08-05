# Beat Up

> A documentação de produto e direção técnica está em [`docs/`](docs/README.md).

Jogo 2D isométrico de direção em cidade procedural, feito em **Godot 4.7**. Você dirige pelas ruas, troca estações de rádio e tenta escapar da polícia enquanto o tráfego e o mapa mudam a cada seed.

## Requisitos

- [Godot 4.7+](https://godotengine.org/download) (Forward Plus)
- Python 3.10+ (opcional — apenas para o microserviço Meshy de geração de assets)

## Como rodar

1. Abra a pasta do projeto no Godot.
2. Execute a cena principal: `scenes/main.tscn` (F5).

### Controles

| Ação | Tecla |
|------|-------|
| Acelerar / frear | W / S (ou setas ↑ ↓) |
| Virar | A / D (ou setas ← →) |
| Próxima estação de rádio | `]` ou `+` |
| Estação anterior | `[` ou `-` |
| Ligar/desligar rádio | M |
| Estação direta | 1–5 |
| Pausar (debug) | P |
| Regenerar cidade (debug) | R |

### Debug (build de desenvolvimento)

| Tecla | Função |
|-------|--------|
| F1 | Mostrar/ocultar overlay de debug |
| F5 | Visualizar colisores de física |
| F6 | Alternar overlay da cidade (bounds / colliders) |
| F2 | Adicionar score (cheat) |
| F3 | Game over (cheat) |
| F4 | Reiniciar jogo |

## Estrutura do projeto

```
beat-up-/
├── scenes/           # Cenas Godot (main, car, city, NPCs, testes)
├── scripts/
│   ├── vehicle/      # CarController, CarMath
│   ├── world/        # Geração procedural da cidade, props, arte
│   ├── ai/           # Polícia e tráfego NPC
│   ├── audio/        # Sistema de rádio in-game
│   └── ui/           # HUD (rádio, wanted)
├── tests/            # Testes unitários e E2E (ver tests/README.md)
├── services/meshy/   # Microserviço Meshy para sprites/assets (ver README local)
├── assets/           # Arte gerada e áudio
└── tools/            # Scripts utilitários (ex.: slice de spritesheet)
```

Os scripts GDScript principais têm cabeçalhos `##` e comentários nas funções públicas / lógica não óbvia (pipeline da cidade, física do carro, IA da polícia, etc.).
## Testes

```powershell
# Headless (CI / terminal)
godot --headless --path . -s res://tests/run_all.gd
```

No editor: abra `scenes/test_runner.tscn` e pressione F6. Detalhes em [`tests/README.md`](tests/README.md).

## Geração de assets (Meshy)

Sprites 2D isométricos podem ser gerados via microserviço em [`services/meshy/`](services/meshy/README.md). A API key fica no servidor — nunca no cliente Godot.

---

## Plano de melhorias

Roadmap priorizado por impacto no gameplay e na base técnica.

### Fase 1 — Core loop jogável (curto prazo)

| # | Melhoria | Descrição | Prioridade |
|---|----------|-----------|------------|
| 1.1 | **Sistema de wanted / heat** | Conectar o ícone de wanted no HUD à lógica real: colisões, velocidade, proximidade da polícia e tempo foragido aumentam o nível de procurado. | Alta |
| 1.2 | **Game over e reinício** | Tela de derrota quando a polícia alcança o jogador; opção de reiniciar com nova seed ou mesma cidade. | Alta |
| 1.3 | **Score e objetivos** | Pontos por tempo livre, distância percorrida, near-misses e fuga bem-sucedida; exibir score no HUD. | Alta |
| 1.4 | **Menu principal** | Tela inicial com jogar, seed customizada, controles e sair — hoje o jogo inicia direto em `PLAYING`. | Média |

### Fase 2 — Mundo e tráfego (médio prazo)

| # | Melhoria | Descrição | Prioridade |
|---|----------|-----------|------------|
| 2.1 | **IA de tráfego mais rica** | NPCs respeitando semáforos, faixas e colisão entre si; reduzir comportamento errático em cruzamentos. | Alta |
| 2.2 | **Densidade por distrito** | Usar `CityNoise` para variar tráfego, polícia e props entre downtown, residencial e industrial. | Média |
| 2.3 | **Props interativos** | Hidrantes, cones e bancos como obstáculos ou cover temporário; feedback visual/sonoro ao colidir. | Média |
| 2.4 | **Minimapa ou bússola** | Indicador simples de direção das viaturas policiais mais próximas. | Baixa |

### Fase 3 — Áudio e polish (médio prazo)

| # | Melhoria | Descrição | Prioridade |
|---|----------|-----------|------------|
| 3.1 | **Trilhas reais no rádio** | Substituir placeholders por `.ogg` em `assets/audio/radio/`; crossfade entre estações. | Alta |
| 3.2 | **SFX de veículo** | Motor, freio, colisão, sirene policial e ambiente urbano. | Alta |
| 3.3 | **Feedback visual** | Partículas de poeira, skid marks, flash ao bater, shake leve na câmera. | Média |
| 3.4 | **Dia/noite ou clima** | Ciclo visual simples ou chuva que altera aderência do carro. | Baixa |

### Fase 4 — Arte e conteúdo (médio/longo prazo)

| # | Melhoria | Descrição | Prioridade |
|---|----------|-----------|------------|
| 4.1 | **Pack completo Meshy 2D** | Gerar e integrar tiles, veículos, props e UI via `services/meshy` (`pack-2d --core`). | Alta |
| 4.2 | **Animações de veículos** | Sprites com luzes, sirene piscando e rotação de rodas. | Média |
| 4.3 | **Variedade de veículos** | Carros do jogador desbloqueáveis com stats diferentes. | Baixa |
| 4.4 | **Pipeline 3D → sprite** | Usar modelos GLB do Meshy como referência ou render offline para sprites isométricos. | Baixa |

### Fase 5 — Engenharia e qualidade (contínuo)

| # | Melhoria | Descrição | Prioridade |
|---|----------|-----------|------------|
| 5.1 | **CI com testes headless** | GitHub Actions rodando `tests/run_all.gd` em cada push/PR. | Alta |
| 5.2 | **Cobertura de IA** | Testes unitários para predição da polícia e spawn do populator. | Média |
| 5.3 | **Configuração centralizada** | Resource `.tres` ou JSON para tuning de carro, cidade e wanted — menos `@export` espalhado. | Média |
| 5.4 | **Performance em cidades grandes** | Pooling de NPCs, culling de props fora da câmera, chunking se o grid crescer. | Média |
| 5.5 | **Input remapping** | Suporte a gamepad e rebinding na UI de opções. | Baixa |

### Ordem sugerida de implementação

```
1.1 Wanted → 1.2 Game over → 1.3 Score → 1.4 Menu
     ↓
2.1 Tráfego → 3.1 Rádio real → 3.2 SFX
     ↓
4.1 Arte Meshy → 5.1 CI → demais itens por demanda
```

---

## Licença

A definir.

## Contribuindo

1. Crie uma branch a partir de `main`.
2. Faça alterações focadas (uma feature ou fix por PR).
3. Rode os testes headless antes de abrir PR.
4. Descreva seed de cidade usada para reproduzir bugs visuais/físicos.
