# Roadmap de produção

## Premissas

- Engine: Godot 4.x com GDScript.
- Plataforma: Android, interface em retrato e toque como entrada primária.
- Escopo-alvo: 4 modelos, 20 desafios, modo livre, moedas, desbloqueios e save local.
- A estimativa abaixo usa semanas de produção; ajuste a duração conforme a equipe disponível.

| Fase | Semanas | Entrega | Critério de saída |
| --- | ---: | --- | --- |
| M0 — Preparação | 1 | Projeto Godot, convenções, modelo piloto e dados fictícios | Cena abre em Android e o repositório tem estrutura estável. |
| M1 — Protótipo de toque | 2–3 | Rosto piloto, batom, sombra, apagador, desfazer/refazer e antes/depois | Aplicação e remoção são agradáveis em aparelho real, sem pintura fora da máscara. |
| M2 — Vertical slice | 2–3 | Um desafio completo, pontuação explicável, resultado, moedas e save | Uma pessoa entende e conclui uma sessão sem instrução externa. |
| M3 — Sistemas do MVP | 3–4 | Todas as categorias de maquiagem, modo livre, coleção/loja e tutorial | Fluxo principal completo, offline e recuperável após reinício. |
| M4 — Conteúdo e polimento | 3–5 | 4 modelos, 20 desafios, catálogo inicial, áudio e acessibilidade | Conteúdo validado, metas de desempenho atendidas e sem bloqueadores críticos. |
| M5 — Preparação de lançamento | 2 | Métricas com consentimento, anúncios opcionais, privacidade, loja e testes finais | Build candidata à publicação aprovada em dispositivos reais. |

## Marcos de decisão

1. **Fim de M1 — validar o gesto.** Pare a expansão de conteúdo se batom e sombra não parecem naturais, responsivos e fáceis de desfazer.
2. **Fim de M2 — validar a sessão.** Teste se o objetivo, a pontuação e a recompensa são compreendidos sem mediação.
3. **Fim de M4 — validar retenção e desempenho.** Só então inclua anúncios recompensados e prepare a publicação.

## Ordem de desbloqueio de conteúdo

1. Batom e sombra: são o menor conjunto para validar a sensação de transformação.
2. Base e blush: estabelecem intensidade e cobertura suave.
3. Delineador e máscara: exigem guia magnética e maior tolerância a erro.
4. Cabelo, acessórios, fundos e efeitos: ampliam expressão sem alterar o núcleo de pintura.

## Riscos que devem ser testados cedo

| Risco | Teste preventivo | Dono primário |
| --- | --- | --- |
| Aplicação artificial | Comparar 3 técnicas de mistura em um único rosto. | Arte + programação |
| Toque frustrante | Testar tolerância, guia e desfazer com 5 pessoas. | Design + programação |
| Baixo desempenho | Medir FPS e memória com camadas empilhadas em aparelho básico. | Programação |
| Conteúdo caro | Produzir o segundo rosto com o mesmo pipeline do primeiro. | Arte |
| Monetização prejudicial | Manter progressão gratuita completa no vertical slice. | Produto |
