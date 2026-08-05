# Economia unificada e token model

## Modelo de três camadas

| Camada | Exemplo | Transferível | Fonte de verdade |
|---|---|---|---|
| Moeda soft por jogo | Gold (Fallen), Street Cred (Beat Up) | Não | ledger backend |
| Entitlements | passe, DLC, unlock, cosmético vinculado | Conforme policy | backend |
| Ativo on-chain | `$MUTTER`, USDC, NFT elegível | Sim | Solana |

Essa separação impede que cada ação de gameplay pague gas e reduz bots/play-to-earn predatório.

## `$MUTTER`

- Padrão pretendido: SPL Token-2022, 9 decimais, cap técnico de 10B conforme código atual.
- Utility candidata: marketplace, descontos transparentes, crafting cosmético, season access e governança futura.
- O cap não aprova a distribuição. Supply/TGE/vesting exigem simulação, jurídico e aprovação formal.
- Mint authority deve migrar de chave única para PDA governada por multisig/timelock e budget controller.

## Rewards

Reward on-chain é exceção: torneios verificados, temporadas, creator programs e campanhas limitadas. Fluxo:

`game result → validação → risk score → budget debit → signed voucher → claim → reconciliation`.

Limites obrigatórios: por jogador/dispositivo/IP/campanha/intervalo, cap global, expiração, nonce único e circuit breaker. Recompensa regular permanece soft/off-chain.

## Sinks sustentáveis

- crafting e upgrade exclusivamente cosméticos;
- taxas de marketplace com divisão versionada;
- passes/eventos e personalização de perfil;
- burn somente quando economicamente aprovado; parte da receita pode ir a operação, creators e tesouraria.

## Marketplace

- MVP: preço fixo, `$MUTTER` ou USDC, settlement atômico.
- Preço e fee em base units; sem ponto flutuante.
- Royalty e fee vêm de configuração imutável da order no momento da listagem, dentro de bounds.
- Assets roubados/contestados podem ser bloqueados na UI e no marketplace controlado, mas não se promete censura universal da chain.

## Guardrails de balanceamento

- Nenhum item comprado altera matchmaking rating ou oferece poder exclusivo.
- Assets cross-game recebem interpretação cosmética/local explícita.
- Mudanças de drop rate ou reward budget são versionadas e observáveis.
- Métricas: emissão líquida, sinks, velocity, concentração Gini, bots, conversão e retenção.

## Tesouraria e governança

Fase 1: multisig 3/5 com separação de funções, timelock para mudanças não emergenciais e relatório público. Fase 2: votação consultiva. DAO executora só após maturidade operacional, distribuição adequada e revisão legal.
