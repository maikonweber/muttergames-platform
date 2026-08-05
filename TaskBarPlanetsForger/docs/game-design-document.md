# Game Design Document

## Conceito

Idle game desktop de criação planetária em pixel art. Uma pequena estrela, asteroides e planetas orbitam em uma faixa próxima à barra de tarefas; um clique abre a visão detalhada.

## Loop principal

`Poeira cósmica → asteroides → fusão → planeta → atmosfera/água → vida → civilização → exploração → sistema completo → supernova → Essência Cósmica → bônus permanente`.

## Sistemas

| Sistema | Decisão de design |
|---|---|
| Recursos | Matéria, Energia, Água, Biomassa e Conhecimento; cada um tem fontes e sumidouros claros. |
| Planetas | Rochoso, oceânico, desértico, congelado, gasoso, vulcânico, vivo e máquina. MVP: rochoso, oceânico e vulcânico. |
| Eventos | Meteoros, vulcões, glaciação, guerra, avanço tecnológico e visita alienígena; nunca impedem a progressão básica. |
| Prestígio | Supernova encerra um sistema completo e converte realização em Essência Cósmica. |

## Progressão e falha

Não há game over permanente. Extinções e colapsos reduzem eficiência ou alteram rotas; planetas destruídos retornam parte da matéria. A primeira hora deve criar um planeta, iniciar vida e apresentar um evento; números são [HIPÓTESE].

## Interface

**Compacta:** recursos essenciais, corpos em órbita e alerta não bloqueante. **Expandida:** órbitas, construção, árvore tecnológica, relatório offline e configurações. Sempre existe pausa, redução de movimento e modo de baixa atividade.
