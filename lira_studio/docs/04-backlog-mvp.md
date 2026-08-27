# Backlog priorizado do MVP

Legenda: **P0** bloqueia o primeiro teste; **P1** entra no MVP; **P2** entra somente se houver capacidade após o núcleo.

| ID | Pri. | Item | Dependência | Critério de aceite |
| --- | --- | --- | --- | --- |
| LIR-001 | P0 | Configurar projeto Godot em retrato | — | Abre em Android com área segura respeitada. |
| LIR-002 | P0 | Importar modelo piloto e máscaras | LIR-001 | Rosto e regiões de lábios/olhos estão alinhados. |
| LIR-003 | P0 | Canvas de toque com máscara | LIR-002 | Pintura não aparece fora da região válida. |
| LIR-004 | P0 | Batom com 3 cores | LIR-003 | Cor, intensidade e limpeza respondem ao toque. |
| LIR-005 | P0 | Sombra com 3 cores | LIR-003 | Cada pálpebra recebe aplicação independente. |
| LIR-006 | P0 | Desfazer, refazer e antes/depois | LIR-004, LIR-005 | Estado visual retorna corretamente em 10 ações consecutivas. |
| LIR-007 | P0 | Teste de sensação em Android | LIR-006 | Problemas de gesto e desempenho são registrados e priorizados. |
| LIR-008 | P1 | Sistema de dados de cosméticos | LIR-001 | Itens são carregados por Resource/ID, sem lógica por nome de arquivo. |
| LIR-009 | P1 | Base e blush | LIR-003, LIR-008 | Cobertura e intensidade funcionam com máscaras próprias. |
| LIR-010 | P1 | Delineador e máscara de cílios | LIR-003, LIR-008 | Guia/tolerância evitam falha frustrante. |
| LIR-011 | P1 | Desafio e objetivos | LIR-008 | Tema e requisitos aparecem antes da sessão. |
| LIR-012 | P1 | Pontuação transparente | LIR-011 | Resultado mostra objetivos cumpridos e recompensa. |
| LIR-013 | P1 | Save local versionado | LIR-012 | Moedas, inventário e configurações sobrevivem ao reinício. |
| LIR-014 | P1 | Modo livre e seleção de modelo | LIR-008, LIR-013 | Inventário do jogador é respeitado e não há pontuação. |
| LIR-015 | P1 | Coleção e desbloqueios | LIR-013 | Itens bloqueados exibem requisito e podem ser liberados. |
| LIR-016 | P1 | 4 modelos e 20 desafios | LIR-011 | Todo conteúdo usa IDs válidos e passa pela sessão completa. |
| LIR-017 | P1 | Tutorial, áudio e ajustes | LIR-014 | Jogador completa a primeira sessão sem ajuda externa. |
| LIR-018 | P1 | Captura antes/depois | LIR-006 | Imagem é salva/compartilhada somente com permissão adequada. |
| LIR-019 | P1 | Testes em dispositivos reais | LIR-016, LIR-017 | Sem bloqueadores críticos; desempenho medido. |
| LIR-020 | P2 | Anúncio recompensado opcional | LIR-019 | Recompensa é clara e o jogo continua completo sem anúncio. |
| LIR-021 | P2 | Telemetria com consentimento | LIR-019 | Eventos mínimos e política de privacidade aprovados. |
