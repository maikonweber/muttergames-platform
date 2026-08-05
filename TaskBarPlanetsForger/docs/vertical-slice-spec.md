# Especificação do vertical slice

## Objetivo

Demonstrar o ciclo completo de criar, ler, evoluir e reiniciar um sistema solar em uma experiência visualmente coerente, confiável e curta.

## Fatias funcionais

| ID | Entregável | Estado | Critério de aceite |
|---|---|---|---|
| VS-01A | Cartões de recurso | Concluído | Mostram saldo, capacidade e taxa/s. |
| VS-01B | Órbitas e inspetor | Concluído | `Ver` seleciona planeta e mostra tipo, estágio, temperatura, Atmosfera e Água. |
| VS-01C | Mapa orbital | Concluído | Representa estrela, três órbitas e seleção sem substituir a UI acessível. |
| VS-01D | Miniaturas | Concluído | Rochoso, Oceânico e Vulcânico são determinísticos por `visual_seed`. |
| VS-02A | Ações explicáveis | Concluído | Toda ação informa custo, requisito e falta de recurso. |
| VS-02B | Confirmação de supernova | Concluído | O prestígio requer confirmação deliberada antes de reiniciar o sistema. |
| VS-03A | Feed de eventos | Pendente | Últimos eventos persistem e podem ser lidos após retorno offline. |
| VS-04A | Recuperação de save | Pendente | Corrupção oferece backup sem sobrescrever a evidência. |

## Contrato do inspetor

Entrada: `Planet.id` selecionado. Saída: órbita, raridade, tipo, estágio, temperatura, habitabilidade, Atmosfera e Água. Caso nenhum planeta exista, o inspetor é ocultado. Caso o planeta selecionado seja removido por prestígio, o inspetor seleciona o primeiro planeta remanescente ou é ocultado.

## Fora desta fatia

Conexão MutterGames, cloud save, marketplace, itens pagos e novos sistemas continuam fora do vertical slice e do MVP.
