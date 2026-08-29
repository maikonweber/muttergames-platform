# Backlog priorizado do MVP

Legenda: **P0** bloqueia o vertical slice; **P1** entra no MVP (EP01–03); **P2** só com capacidade extra.

| ID | Pri. | Item | Dependência | Critério de aceite |
| --- | --- | --- | --- | --- |
| CD-001 | P0 | Projeto Godot 4.x, pastas, autoloads | — | Cena `boot` abre; `GameState` existe. |
| CD-002 | P0 | Schema de nó + loader JSON | CD-001 | `EP01_SC01_N001` carrega sem código por fala. |
| CD-003 | P0 | UI de diálogo (retrato, nome, texto, 2–4 escolhas) | CD-002 | Texto e escolhas renderizam; histórico armazena falas. |
| CD-004 | P0 | Flags e efeitos de escolha | CD-003 | Escolha grava flag e altera o próximo nó. |
| CD-005 | P0 | Afinidade e confiança (0–100, clamp) | CD-004 | Delta aplica; UI de debug mostra valores. |
| CD-006 | P0 | Autosave antes de escolha crítica e troca de cena | CD-004 | Reinício restaura nó, flags e atributos. |
| CD-007 | P0 | Roteiro EP01 cenas 1–3 em JSON | CD-002 | Caminho crítico completo sem falas cortadas. |
| CD-008 | P0 | 1 pista coletável + 1 combinação | CD-007 | Combinação correta forma hipótese; errada não trava. |
| CD-009 | P0 | Acessibilidade mínima | CD-003 | Tamanho de texto, velocidade, contraste. |
| CD-010 | P1 | Mapa com 12 locais | CD-006 | Locais disponíveis segundo episódio e flags. |
| CD-011 | P1 | Eventos aleatórios (1 por visita) | CD-010 | Seed estável; nenhum evento seta flag `critical`. |
| CD-012 | P1 | Celular (mensagens) | CD-004 | Resposta opcional abre cena curta. |
| CD-013 | P1 | Personalização nome/pronomes/visual básico | CD-001 | Nome e pronomes substituem tokens no texto. |
| CD-014 | P1 | Guarda-roupa com tags; 1 cena reage | CD-013 | Progresso não exige peça paga. |
| CD-015 | P1 | EP01 cenas 4–7 + aliado de encerramento | CD-007 | Aliado ganha confiança; rotas românticas permanecem abertas. |
| CD-016 | P1 | EP02 e EP03 completos | CD-015, CD-008 | Gancho de cada episódio dispara; 3 CGs restantes. |
| CD-017 | P1 | 20 retratos-base + 6 expressões dos principais | CD-003 | Expressão do nó troca o sprite. |
| CD-018 | P1 | 12 fundos em camadas | CD-010 | Parallax sutil; fallback de cor se asset faltar. |
| CD-019 | P1 | Recap ao reabrir o jogo | CD-006 | Resumo sem spoiler de rotas não jogadas. |
| CD-020 | P1 | Testes headless de nós, flags e save | CD-006 | Suite verde no CI ou script Godot `--headless`. |
| CD-021 | P1 | Build Android do MVP | CD-016 | Três aparelhos; 0 bloqueadores no fluxo principal. |
| CD-022 | P2 | Analytics com consentimento | CD-021 | Sem texto livre; funil EP1/EP3. |
| CD-023 | P2 | Slot manual além do autosave | CD-006 | Três slots no jogo completo; um no MVP. |
| CD-024 | P2 | Dante como rota (após classificação) | decisão aberta | Fora do MVP. |
| CD-025 | P2 | Loja de cristais / passe | validação da experiência | História completa sem pagamento. |
