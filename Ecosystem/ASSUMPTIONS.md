# Premissas, lacunas e decisões pendentes

## Evidências encontradas

- Fallen Tactics é um tactics/deckbuilder roguelike em Godot, com combate em grid, cartas, classes, equipamentos, runs e meta-progressão.
- Beat Up é um jogo Godot de direção isométrica em cidade procedural, com perseguição policial, score, rádio e veículos planejados.
- MutterCoinSolana já define SPL Token-2022, supply máximo proposto de 10 bilhões, documentação de marketplace/wallet/backend e um programa Anchor inicial de emissão.

## Premissas adotadas

| ID | Premissa | Impacto se falsa |
|---|---|---|
| A-01 | Ambos os jogos usarão Godot 4.x e poderão consumir HTTPS/WebSocket. | SDK/adaptadores precisam ser refeitos. |
| A-02 | Solana será a única rede de liquidação do MVP. | Custos e segurança aumentam se multi-chain for exigido no lançamento. |
| A-03 | Gameplay continua funcional sem wallet externa. | Onboarding e retenção mudam materialmente. |
| A-04 | Assets pagos não concedem vantagem competitiva direta. | Exige política de balanceamento e classificação regulatória adicional. |
| A-05 | `$MUTTER` ainda não teve TGE irreversível. | Se já houve emissão, será necessária reconciliação de supply/holders. |
| A-06 | Nenhum dado pessoal será gravado on-chain. | Violação exige redesenho de privacidade, pois dados on-chain não são apagáveis. |
| A-07 | O backend pode manter ledger interno de moedas soft e entitlements. | Sem backend autoritativo, prevenção a fraude fica muito mais difícil. |

## Decisões ainda necessárias

- Nome comercial, ticker final, marca e direitos sobre assets.
- Supply, alocações, TGE e qualquer promessa de retorno: dependem de modelagem econômica e parecer jurídico.
- Provedor de wallet embutida, fiat on-ramp, custódia e países suportados.
- Metaplex Core versus Token-2022 para cada classe de asset, após benchmark de custo e tooling.
- Política etária, KYC/AML, sanções, chargeback, impostos e proteção ao consumidor.
- Royalties por coleção, fee de marketplace e divisão da tesouraria.

## Política para incerteza

Valores econômicos neste pacote são **limites de produto e hipóteses de teste**, não promessa financeira. Toda mudança crítica deve gerar ADR, revisão de segurança e versionamento do catálogo.
