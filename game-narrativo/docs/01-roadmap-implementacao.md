# Roadmap de implementação e teste

Engine: Godot 4.x, GDScript. Conteúdo em JSON com IDs estáveis. Plataformas: Android primeiro; PC no editor para QA rápido.

## Fases

| Fase | Semanas | Entrega | Critério de saída |
| --- | ---: | --- | --- |
| M0 — Fundação | 1 | Projeto Godot, autoloads, schema de nó, 1 cena placeholder | Abre no editor; um nó JSON renderiza retrato + texto + 2 escolhas. |
| M1 — Protótipo de diálogo | 2 | Histórico, flags, afinidade/confiança, autosave | Uma escolha altera fala posterior; save restaura o nó. |
| M2 — Vertical slice | 3–4 | 15 min do EP01 (cenas 1–3) com arte-alvo, 1 pista e 1 escolha crítica | Fluxo jogável em Android; ver [definição de pronto](#definicao-de-pronto-do-vertical-slice). |
| M3 — Mapa + eventos | 2 | Mapa de 12 locais, visitas, 1 evento aleatório por visita | Evento nunca bloqueia o caminho crítico. |
| M4 — Investigação | 2 | Painel de pistas, combinação de 2 evidências, hipótese | Combinação correta e errada têm feedback; errada não trava. |
| M5 — MVP episódios 1–3 | 6–8 | Três episódios, celular, guarda-roupa básico, 4 CGs, analytics consentido | Build Android fechado; métricas do GDD mensuráveis. |
| M6 — Teste fechado | 3–4 | Balanceamento, acessibilidade, retenção | 0 falhas no fluxo principal; texto e contraste ajustáveis. |

Estimativa do GDD (produção completa da T1 após o MVP): 4–6 meses. Não entra neste roadmap.

## Marcos de decisão

1. **Fim de M1** — se escolha + flag + save não forem estáveis, não produzir mais texto.
2. **Fim de M2** — validar se romance + mistério prende em 15 minutos.
3. **Fim de M5** — só então discutir passe, loja e Dante como rota.

## Ordem de conteúdo

1. EP01 cenas 1–3 (vertical slice).
2. EP01 cenas 4–7 + escolha de aliado.
3. Locais e eventos de campus.
4. EP02 (laboratório, alianças, foto recente).
5. EP03 (app de Noah, previsão de morte).
6. CGs e guarda-roupa reativo.

## Definição de pronto do vertical slice

Do GDD, seção 19 — todos obrigatórios:

- 15 minutos jogáveis do início ao fim em Android.
- Uma escolha altera diálogo posterior; outra altera confiança.
- Uma pista coletada e combinada corretamente.
- Autosave restaura estado, roupas, atributos e nó.
- Arte e áudio representam qualidade-alvo (placeholders identificados).
- Texto, velocidade e contraste ajustáveis.
- Sem travamentos, falas cortadas ou bloqueios no caminho crítico.
- Build em pelo menos três perfis de aparelho.

## Riscos a testar cedo

| Risco | Teste | Dono |
| --- | --- | --- |
| Ramificação explode | Diamante: 3 rotas locais convergem no mesmo nó marco | Narrativa |
| Personagem raso | Ficha lida em voz alta; 5 falas fora de voz | Roteiro |
| Mistério confuso | Jogador sem contexto combina 2 pistas | Design |
| Evento aleatório quebra trama | Suite: nenhum evento seta flag crítica | Programação |
| Save incompatível | Roundtrip de `GameState` a cada mudança de schema | Programação |
