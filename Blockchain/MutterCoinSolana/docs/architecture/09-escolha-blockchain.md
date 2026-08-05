# 09 — Escolha da Blockchain

**Versão:** 0.1.0  
**Decisão:** **Solana como L1 primária (hub)** + **EVM L2s como spokes de liquidez**

---

## 1. Critérios de Avaliação (pesos)

| Critério | Peso | Por quê |
|----------|------|---------|
| TPS / latência UX games | 20% | Microtransações e mints frequentes |
| Custo por tx | 18% | Viabilidade de items/skins |
| Maturidade GameFi/NFT | 12% | Tooling e adoção |
| Segurança / batalha testada | 15% | Proteção de tesouraria e bridge |
| Ecossistema DeFi / liquidez | 10% | Price discovery e pools |
| Ferramentas / DX | 10% | SDK, explorers, RPCs |
| Bridges / interoperabilidade | 8% | Multichain roadmap |
| Descentralização / client diversity | 7% | Risco sistêmico |

---

## 2. Comparativo (visão 2026 — qualitativo)

| Chain | TPS práticos | Custo | GameFi | NFT | Segurança percebida | DX | Bridge ecosystem | Nota Mutter |
|-------|--------------|-------|--------|-----|---------------------|----|------------------|-------------|
| **Solana** | Muito alto | Muito baixo | Forte | Forte (cNFT) | Alta (pós-melhorias) | Alta | Forte | **Hub** |
| Ethereum | Baixo L1 | Alto L1 | Médio | Referência | Mais alta | Alta | Hub bridges | Liquidez |
| Polygon | Alto | Baixo | Forte histórico | Forte | Média-alta | Alta | Forte | Spoke |
| Arbitrum | Alto | Baixo | Crescente | Forte | Alta | Alta | Forte | Spoke |
| Optimism | Alto | Baixo | Médio | Forte | Alta | Alta | Forte | Spoke |
| Base | Alto | Baixo | Crescente | Forte | Alta (OP stack) | Alta | Forte | Spoke priorizado |
| BNB Chain | Alto | Baixo | Forte volume | Forte | Média | Alta | Forte | Spoke |
| Avalanche | Alto | Baixo | Médio | Médio | Alta | Alta | Médio | Spoke late |
| Immutable | Alto (zk) | Baixo | Excelente games | Forte | Alta | Boa | Focado games | Avaliar parceria |
| Ronin | Alto | Baixo | Excelente (Axie) | Forte | Média* | Média | Mais fechado | Avaliar late |
| Sui | Muito alto | Baixo | Crescente | Forte | Alta | Média-alta | Médio | P3 |
| Aptos | Muito alto | Baixo | Crescente | Médio | Alta | Média-alta | Médio | P3 |

\*Ronin teve histórico de bridge exploit — exige due diligence extra.

---

## 3. Análise objetiva por perfil

### Por que não Ethereum L1 como home de games?
- Gas inviável para mint/trade massivo de items.
- UX lenta para jogadores casuais.
- Mantemos Ethereum como **âncora de liquidez e confiança**.

### Por que não apenas um L2 EVM?
- L2s excelentes, mas para inventário high-throughput + cNFTs, Solana está à frente em custo/escala.
- Fragmentação de sequencers e withdrawal delays complicam bridges e UX.

### Por que não Sui/Aptos como hub agora?
- Ecossistema GameFi/DX/liquidity ainda menos maduro para o go-to-market MutterCorp.
- Custo de recrutar devs e liquidez maior no curto prazo.
- Permanecem no roadmap P3.

### Por que Solana?
1. **Throughput e fees** adequados a marketplaces de items/skins.
2. **Compressed NFTs** para escala de assets in-game.
3. **Wallets consumer** maduras (Phantom etc.) + embedded wallet vendors.
4. **Tooling Anchor**, RPCs, indexers (Yellowstone, etc.).
5. Nome do programa (`MutterCoinSolana`) alinha execução e hiring.
6. Ponte para EVM resolve liquidez institucional.

---

## 4. Arquitetura recomendada

| Papel | Chain |
|-------|-------|
| Canonical token, NFTs, markets, staking, DAO | **Solana** |
| Deep liquidity, custody institutions | **Ethereum** |
| Consumer EVM DeFi / social | **Base** |
| Alt liquidity + users | **Arbitrum, Polygon, BNB** |
| Games-focused partnership | **Immutable** (avaliar) |
| Exploratório | Sui, Aptos, Avalanche, Optimism, Ronin |

---

## 5. Trade-offs aceitos

| Trade-off | Mitigação |
|-----------|-----------|
| Menor “prestígio L1” vs Ethereum | Wrapped MUTTER + pools ETH |
| Outages históricos Solana | Multi-RPC, status UX, filas off-chain |
| Modelo de conta diferente de EVM | SDK abstrai; docs claras |
| Bridge vira superfície de ataque | Caps, audits, partner battle-tested |

---

## 6. Decisão formal

**ADOTADO:** Solana Hub + EVM Spokes  
**Token canônico:** SPL Token-2022 `$MUTTER`  
**NFTs:** Metaplex + cNFT onde fizer sentido  
**Bridge:** preferência por protocolo estabelecido (avaliar Wormhole / LayerZero / NTT-like) com gateway Mutter

**Aprovadores necessários:** Tech Lead · Security · Product · Tokenomics
