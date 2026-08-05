# Requisitos funcionais

| ID | Nome | Prioridade | Descrição e aceite |
|---|---|---|---|
| RF-001 | Iniciar sessão | Must Have | Inicia ou restaura a última partida válida; exibe recuperação se necessário. |
| RF-002 | Janela compacta | Must Have | Exibe sistema e recursos em faixa redimensionável; alterna para expandida por ação explícita. |
| RF-003 | Bandeja e ciclo de vida | Should Have | Fechar pode minimizar para bandeja, configurável pelo jogador. |
| RF-004 | Posicionamento | Must Have | Permite escolher monitor/posição, lembrar escolha e respeitar DPI; não deve capturar foco sem ação do usuário. |
| RF-005 | Recursos | Must Have | Gera, limita, consome e mostra Matéria, Energia, Água, Biomassa e Conhecimento por segundo. |
| RF-006 | Asteroides e fusão | Must Have | Cria asteroides com Matéria e permite fundi-los quando custos/regras forem atendidos. |
| RF-007 | Planeta | Must Have | Cria planeta em órbita vaga com tipo, raridade, temperatura e estágios de evolução. |
| RF-008 | Habitabilidade | Must Have | Atmosfera e Água desbloqueiam Vida; requisitos e impedimentos são explicados na UI. |
| RF-009 | Vida e civilização | Should Have | Vida produz Biomassa; civilização exige marcos e gera Conhecimento/tecnologia. |
| RF-010 | Eventos | Must Have | Sorteia eventos com seed, pré-condições, impacto e escolha opcional do jogador. |
| RF-011 | Idle/offline | Must Have | Registra saída, calcula produção limitada ao retorno e exibe relatório. |
| RF-012 | Prestígio | Must Have | Permite supernova em sistema qualificado, converte em Essência e preserva melhorias permanentes. |
| RF-013 | Save e backup | Must Have | Salva automaticamente de modo atômico, mantém backup e detecta/migra versão. |
| RF-014 | Configurações | Must Have | Controla volume, notificações, taxa de atualização, transparência, acessibilidade e comportamento da janela. |
| RF-015 | Tutorial | Should Have | Guia primeiro asteroide, planeta, vida, evento e prestígio sem bloquear exploração. |
| RF-016 | Pausa e desempenho | Must Have | Pausa simulação manualmente e reduz atividade em segundo plano conforme configuração. |

Dependências: RF-008 depende de RF-005/RF-007; RF-009 de RF-008; RF-012 de RF-007 a RF-010. Regras relacionadas: `RN-001` a `RN-007`.
