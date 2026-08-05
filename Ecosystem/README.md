# MutterGames Blockchain Ecosystem

**Versão:** 1.0.0-draft  
**Data:** 2026-08-04  
**Status:** especificação integrada para revisão de Produto, Engenharia, Segurança e Jurídico

Este pacote conecta **Fallen Tactics**, **Beat Up** e a infraestrutura **MutterCoin/MutterCorps** sem tornar blockchain obrigatória para jogar. O servidor continua autoritativo sobre gameplay; a chain registra somente propriedade, liquidação e operações econômicas que precisam ser verificáveis.

## Decisões principais

- Solana é a chain canônica do MVP; bridge EVM fica fora do caminho crítico.
- `$MUTTER` é token de utilidade do ecossistema. Cada jogo mantém moedas soft off-chain não transferíveis.
- Login social cria conta e wallet embutida; self-custody é opcional e pode ser vinculada depois.
- NFTs são reservados a cosméticos, colecionáveis e direitos portáveis. Poder competitivo não é comprável.
- Assets só são interoperáveis quando um adaptador de cada jogo declara a interpretação; “mesmo NFT em todos os jogos” não é assumido.
- Nenhuma emissão ou recompensa on-chain é aceita diretamente do cliente do jogo.

## Navegação

| Área | Documento |
|---|---|
| Visão e limites | [product-specs/01-product-spec.md](product-specs/01-product-spec.md) |
| Arquitetura e dados | [architecture/01-system-architecture.md](architecture/01-system-architecture.md) |
| Identidade e wallet | [architecture/02-identity-wallet.md](architecture/02-identity-wallet.md) |
| Economia e token | [economy/01-economy-tokenomics.md](economy/01-economy-tokenomics.md) |
| Contratos | [smart-contracts/01-program-spec.md](smart-contracts/01-program-spec.md) |
| API | [apis/openapi.yaml](apis/openapi.yaml) |
| Integração Fallen Tactics | [game-integrations/fallen-tactics.md](game-integrations/fallen-tactics.md) |
| Integração Beat Up | [game-integrations/beat-up.md](game-integrations/beat-up.md) |
| Segurança | [architecture/03-security-governance.md](architecture/03-security-governance.md) |
| Migração e roadmap | [roadmap/01-migration-roadmap.md](roadmap/01-migration-roadmap.md) |
| Premissas e decisões | [ASSUMPTIONS.md](ASSUMPTIONS.md) |

## Gates obrigatórios

1. Revisão jurídica de token, marketplace, menores, loot boxes e jurisdições.
2. Threat model e auditoria externa antes de mainnet.
3. Teste econômico fechado, com limites de emissão e kill switch.
4. Telemetria, reconciliação e runbook de incidentes antes de ativos transferíveis.

Esta especificação substitui divergências conceituais, mas não apaga os documentos anteriores do projeto MutterCoin; eles devem ser mantidos como histórico e reconciliados por ADR.
