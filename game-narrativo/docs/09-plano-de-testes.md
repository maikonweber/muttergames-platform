# Plano de testes

Testar comportamento externo: o que o jogador vê e o que o save contém. Não testar ordem interna de funções.

## Seams

Um seam principal: **`NarrativeManager.advance(choice_id | null)`** + snapshot de `GameState`. Testes falam com esse seam e com `SaveManager.roundtrip`. Eventos aleatórios têm seam próprio: `RandomEventSystem.pick(location_id)`.

## O que torna um teste bom

- Dado um estado e um ID de escolha, o próximo `node_id`, flags e deltas são os esperados.
- Não abre cena Godot salvo em teste de fumaça manual.
- Nomes de teste descrevem a regra (`critical_choice_autosaves`), não o método.

## Suites

### S1 — Grafo EP01

| Caso | Entrada | Esperado |
| --- | --- | --- |
| Caminho crítico | sempre a primeira escolha visível | SC01→…→SC07 sem `next` quebrado |
| Todos os `next` | catálogo de nós | cada id existe |
| Escolha oculta | flag falsa | botão ausente; ≥1 visível |
| Diamante festa | quatro flags `ep01_festa_*` | todos chegam em `EP01_SC06_N001` |
| Aliado | combinações SC06+SC07 | exatamente uma `ep01_ally_*` |

### S2 — Relações

| Caso | Esperado |
| --- | --- |
| Clamp | 100 + 10 = 100; 0 − 10 = 0 |
| Eixos independentes | +afinidade não altera confiança |
| Coragem | máximo 10; escolha difícil +1; compra não existe no API |

### S3 — Evidências

| Caso | Esperado |
| --- | --- |
| Coletar duas vezes | inventário com uma cópia |
| Combo válido | `ev_colar_*` → `hyp_colares_iguais` |
| Combo inválido | tentativa −1; evidências permanecem; jogo continua |

### S4 — Save

| Caso | Esperado |
| --- | --- |
| Roundtrip slice | nó, flags, roupa, coragem, evidências iguais |
| Prefixo de versão | save vN carrega ou migra; não corrompe |
| Crítica | ao entrar em nó `critical`, arquivo no disco mudou |

### S5 — Eventos aleatórios

| Caso | Esperado |
| --- | --- |
| Teto | 1 evento por visita |
| Seed | mesmo `rng_seed+day+location` → mesmo id |
| Denylist | picker descarta evento com efeito crítico (teste com fixture proposital) |
| Cena obrigatória | visita a `loc_festa` no EP01 não roda tabela |

### S6 — Tokens e acessibilidade

| Caso | Esperado |
| --- | --- |
| Nome | `{name}` some do texto renderizado |
| Timer off | escolha de tempo sem falha se desligado |

## Caminho crítico manual (Android)

1. Novo jogo → SC01 até a ameaça.
2. Mostrar a foto; investigar o número.
3. Matar o app; reabrir; estar no mesmo nó.
4. Abrir painel; combinar colares.
5. Contraste alto e texto grande: escolhas ainda clicáveis.

## Regressão mínima a cada PR de conteúdo

Rodar S1 no episódio tocado + S4. Não mergear JSON com `next` órfão.

```text
python game-narrativo/data/validate.py
```

## Métricas do GDD (teste fechado, não CI)

Conclusão EP1 ≥ 65%; EP3 ≥ 35%; D1 ≥ 30%; escolhas relevantes ≥ 70% em pesquisa; interesse de rota ≥ 60%; 0 falhas no fluxo principal.
