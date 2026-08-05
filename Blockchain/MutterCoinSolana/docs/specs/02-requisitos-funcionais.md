# 02 — Requisitos Funcionais (RF)

**Versão:** 0.1.0  
**Status:** Draft

Legenda de prioridade: **P0** MVP · **P1** V1 · **P2** V2 · **P3** V3+

---

## 1. Token MutterCoin (`$MUTTER`)

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-TOK-001 | Criar mint SPL Token-2022 MutterCoin com metadata on-chain | P0 |
| RF-TOK-002 | Definir supply máximo e autoridade de mint (ou freeze mint) | P0 |
| RF-TOK-003 | Permitir burn de tokens pelo holder | P0 |
| RF-TOK-004 | Transferências padrão SPL entre wallets | P0 |
| RF-TOK-005 | Pausar/despausar transferências (circuit breaker via programa/authority) | P0 |
| RF-TOK-006 | Blacklist de endereços (freeze account / blocklist program) | P1 |
| RF-TOK-007 | Whitelist mode (somente endereços autorizados — fase launch) | P1 |
| RF-TOK-008 | Transfer fee configurável (opcional, governado) | P2 |
| RF-TOK-009 | Emissão programada de rewards (emission schedule) | P0 |
| RF-TOK-010 | Queima periódica de fees de marketplace (deflação) | P1 |
| RF-TOK-011 | Multisig para authorities críticas (mint, pause, upgrade) | P0 |
| RF-TOK-012 | Exibir balances e histórico via indexer/API | P0 |

---

## 2. Contas, Auth e Identidade

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-AUTH-001 | Registro de usuário (email / social / wallet) | P0 |
| RF-AUTH-002 | Login com wallet (Phantom, Solflare, WalletConnect) | P0 |
| RF-AUTH-003 | Login social com wallet embutida (custodial opcional) | P0 |
| RF-AUTH-004 | Vincular múltiplas wallets a um perfil | P1 |
| RF-AUTH-005 | 2FA para ações sensíveis (saque, bridge alto valor) | P1 |
| RF-AUTH-006 | Sessões JWT/OAuth2 para API | P0 |
| RF-AUTH-007 | KYC opcional para launchpad / limites altos | P2 |
| RF-AUTH-008 | Consentimento LGPD e gestão de dados pessoais | P0 |

---

## 3. Wallet Mutter

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-WAL-001 | Criar wallet Solana (seed phrase BIP39) | P0 |
| RF-WAL-002 | Importar seed / private key | P0 |
| RF-WAL-003 | Suporte Ledger (hardware) | P1 |
| RF-WAL-004 | WalletConnect para dApps | P1 |
| RF-WAL-005 | Exibir SOL, $MUTTER, SPL tokens e NFTs | P0 |
| RF-WAL-006 | Enviar / receber tokens e NFTs | P0 |
| RF-WAL-007 | Swap integrado (DEX aggregator) | P1 |
| RF-WAL-008 | Bridge UI multi-chain | P1 |
| RF-WAL-009 | Staking / unstake pela wallet | P1 |
| RF-WAL-010 | Acesso rápido a marketplace e histórico | P0 |
| RF-WAL-011 | Multichain view (EVM balances via bridge addresses) | P2 |
| RF-WAL-012 | Deep-link / SSO in-game | P0 |

---

## 4. NFTs e Coleções

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-NFT-001 | Criar coleção (Metaplex / padrão Mutter) | P0 |
| RF-NFT-002 | Mint NFT (1/1 e semi-fungible / editions) | P0 |
| RF-NFT-003 | Batch mint | P1 |
| RF-NFT-004 | Lazy mint (off-chain signature → mint on buy) | P1 |
| RF-NFT-005 | Metadata on-chain + URI IPFS/Arweave | P0 |
| RF-NFT-006 | Royalties on-chain (creator shares) | P0 |
| RF-NFT-007 | Update metadata (authority controlada) | P1 |
| RF-NFT-008 | Burn NFT | P1 |
| RF-NFT-009 | Transferência e escrow para marketplace | P0 |
| RF-NFT-010 | Categorias: skin, item, character, land, asset, ticket | P0 |
| RF-NFT-011 | Traits / attributes indexáveis | P0 |
| RF-NFT-012 | Soulbound / soul-linked (não transferível) opcional | P2 |

---

## 5. Marketplace (NFTs / Itens / Skins / Characters / Lands / Assets)

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-MKT-001 | Listar asset para venda (fixed price) | P0 |
| RF-MKT-002 | Comprar asset (compra imediata) | P0 |
| RF-MKT-003 | Cancelar listagem | P0 |
| RF-MKT-004 | Fazer oferta (offer) | P1 |
| RF-MKT-005 | Aceitar / rejeitar oferta | P1 |
| RF-MKT-006 | Leilão inglês (ascending) | P1 |
| RF-MKT-007 | Leilão holandês (descending) | P2 |
| RF-MKT-008 | Escrow de NFT e pagamento | P0 |
| RF-MKT-009 | Comissão da plataforma configurável | P0 |
| RF-MKT-010 | Distribuição de royalties aos creators | P0 |
| RF-MKT-011 | Split payment (múltiplos recipients) | P1 |
| RF-MKT-012 | Histórico de preços e vendas | P0 |
| RF-MKT-013 | Filtros: jogo, raridade, preço, traits, coleção | P0 |
| RF-MKT-014 | Favoritos e watchlist | P1 |
| RF-MKT-015 | Pagamento em $MUTTER (primário) e SOL (secundário) | P0 |
| RF-MKT-016 | Bundle de múltiplos assets | P2 |

---

## 6. Marketplace de Games

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-GAME-001 | Publicar jogo (metadata, builds, mídia) | P0 |
| RF-GAME-002 | Vender licença de jogo (one-time) | P0 |
| RF-GAME-003 | Vender DLC / expansion | P0 |
| RF-GAME-004 | Bundles e packs | P1 |
| RF-GAME-005 | Assinaturas (periodicas) | P2 |
| RF-GAME-006 | Licenças time-limited / seats | P2 |
| RF-GAME-007 | Versionamento de builds + changelog | P0 |
| RF-GAME-008 | Hash de integridade do build | P0 |
| RF-GAME-009 | Avaliações e reviews | P1 |
| RF-GAME-010 | Downloads autorizados pós-compra | P0 |
| RF-GAME-011 | Compatibilidade (plataforma/OS/engine) | P0 |
| RF-GAME-012 | Categorias, tags, discovery | P0 |
| RF-GAME-013 | Royalties / revenue share studio | P0 |
| RF-GAME-014 | Refund policy configurável (off-chain rules) | P1 |
| RF-GAME-015 | Storefront por publisher | P1 |

Detalhamento: [12-marketplace-games.md](./12-marketplace-games.md)

---

## 7. Bridge

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-BRG-001 | Lock tokens na origem | P1 |
| RF-BRG-002 | Mint wrapped na destino | P1 |
| RF-BRG-003 | Burn wrapped na destino | P1 |
| RF-BRG-004 | Unlock na origem | P1 |
| RF-BRG-005 | Relayers / validators com quorum | P1 |
| RF-BRG-006 | Proof de mensagem cross-chain | P1 |
| RF-BRG-007 | Limites diários / por tx | P1 |
| RF-BRG-008 | Pause de emergência por rota | P1 |
| RF-BRG-009 | Rotas: Solana↔Ethereum, Base, Arbitrum, Polygon, BNB | P1 |
| RF-BRG-010 | Rotas adicionais: Avalanche, Optimism, Immutable, Ronin, Sui, Aptos | P3 |
| RF-BRG-011 | Status tracking e reprocessamento | P1 |
| RF-BRG-012 | Fee de bridge transparente | P1 |

---

## 8. DAO / Governança

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-DAO-001 | Criar proposta on-chain | P2 |
| RF-DAO-002 | Depositar / vincular poder de voto ($MUTTER / veMUTTER) | P2 |
| RF-DAO-003 | Votar a favor / contra / abster | P2 |
| RF-DAO-004 | Quórum e threshold configuráveis | P2 |
| RF-DAO-005 | Delegação de votos | P2 |
| RF-DAO-006 | Timelock para execução | P2 |
| RF-DAO-007 | Tesouraria controlada por governança | P2 |
| RF-DAO-008 | Categorias: fees, emissions, grants, params | P2 |

---

## 9. Staking

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-STK-001 | Stake $MUTTER em pools | P0 |
| RF-STK-002 | Unstake com / sem lock period | P0 |
| RF-STK-003 | Rewards claimáveis | P0 |
| RF-STK-004 | APR dinâmico por pool | P0 |
| RF-STK-005 | Early unlock penalty | P1 |
| RF-STK-006 | Boost por NFT / tempo / guilda | P1 |
| RF-STK-007 | Multi-pool e auto-compound (opcional) | P2 |
| RF-STK-008 | veMUTTER (vote-escrow) para governança | P2 |

---

## 10. Farming / Liquidity Mining

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-FRM-001 | Depositar LP tokens em farm | P1 |
| RF-FRM-002 | Emitir rewards $MUTTER | P1 |
| RF-FRM-003 | Admin/DAO gerencia pools e weights | P1 |
| RF-FRM-004 | Harvest rewards | P1 |
| RF-FRM-005 | Dual rewards (MUTTER + partner token) | P2 |

---

## 11. Rewards & Seasons

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-RWD-001 | Campanhas de reward por jogo | P0 |
| RF-RWD-002 | Achievements → claim on-chain/off-chain | P1 |
| RF-RWD-003 | Seasons com leaderboard | P1 |
| RF-RWD-004 | Anti-sybil básico (device/wallet heuristics) | P1 |
| RF-RWD-005 | Airdrops merkle / claim portal | P1 |

---

## 12. Guildas

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-GLD-001 | Criar guilda (nome, crest NFT, roles) | P1 |
| RF-GLD-002 | Convidar / aceitar membros | P1 |
| RF-GLD-003 | Tesouraria de guilda (multisig) | P2 |
| RF-GLD-004 | Rewards compartilhados | P2 |
| RF-GLD-005 | Ranking de guildas por season | P1 |

---

## 13. Loot Boxes

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-LOOT-001 | Mint / venda de loot box | P2 |
| RF-LOOT-002 | Abertura com randomização verificável (VRF/oracle) | P2 |
| RF-LOOT-003 | Tabelas de probabilidade publicadas | P2 |
| RF-LOOT-004 | Rewards: NFTs / tokens / items | P2 |
| RF-LOOT-005 | Compliance: disclosure de odds | P2 |

---

## 14. Launchpad

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-LPD-001 | Criar sale (fixed / fair launch) | P2 |
| RF-LPD-002 | Whitelist / tiers por stake | P2 |
| RF-LPD-003 | Vesting de tokens do projeto | P2 |
| RF-LPD-004 | Claim pós-TGE | P2 |
| RF-LPD-005 | KYC gate opcional | P2 |

---

## 15. Vesting & Treasury

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-VES-001 | Vesting linear/cliff para equipe | P0 |
| RF-VES-002 | Vesting investidores / advisors | P0 |
| RF-VES-003 | Tesouraria com spending limits | P0 |
| RF-VES-004 | Streaming de grants | P2 |
| RF-VES-005 | Relatórios públicos de liberação | P1 |

---

## 16. SDK & Developer Portal

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-SDK-001 | SDK Unity | P0 |
| RF-SDK-002 | SDK Unreal | P1 |
| RF-SDK-003 | SDK Godot | P1 |
| RF-SDK-004 | SDK JS/TS (web games) | P0 |
| RF-SDK-005 | SDKs C# / Rust / Go / Python (server) | P1 |
| RF-SDK-006 | Auth wallet in-game | P0 |
| RF-SDK-007 | Mint / transfer / inventory sync | P0 |
| RF-SDK-008 | Purchases marketplace in-game | P1 |
| RF-SDK-009 | Portal: API keys, webhooks, docs, sandbox | P0 |
| RF-SDK-010 | Ambientes: local / devnet / mainnet | P0 |

---

## 17. API Pública

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-API-001 | REST API versionada | P0 |
| RF-API-002 | GraphQL para consultas ricas | P1 |
| RF-API-003 | WebSocket para eventos tempo-real | P1 |
| RF-API-004 | API keys + scopes + rate limit | P0 |
| RF-API-005 | Webhooks assinados (HMAC) | P1 |
| RF-API-006 | OpenAPI / asyncapi docs | P0 |

---

## 18. Painel Administrativo

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-ADM-001 | RBAC (roles: superadmin, mod, finance, support) | P0 |
| RF-ADM-002 | Pausar contratos / rotas bridge | P0 |
| RF-ADM-003 | Gerenciar fees e parâmetros | P0 |
| RF-ADM-004 | Moderação de listagens / jogos | P0 |
| RF-ADM-005 | Gestão de blacklist | P1 |
| RF-ADM-006 | Dashboard métricas (GMV, users, TVL) | P0 |
| RF-ADM-007 | Audit log de ações admin | P0 |
| RF-ADM-008 | Feature flags | P1 |

---

## 19. Indexação, Notificações e Analytics

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-IDX-001 | Indexar txs, mints, trades, stakes | P0 |
| RF-IDX-002 | Notificações email/push/in-app | P1 |
| RF-IDX-003 | Analytics para studios (economy health) | P1 |
| RF-IDX-004 | Explorer interno Mutter | P2 |

---

## 20. Requisitos Transversais de Negócio

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF-X-001 | Multi-idioma UI (PT/EN mínimo) | P1 |
| RF-X-002 | Moeda de display fiat (referência) | P1 |
| RF-X-003 | Termos de uso / política de privacidade | P0 |
| RF-X-004 | Suporte a disputa (off-chain) para games digitais | P1 |
| RF-X-005 | Programa de afiliados / referral | P2 |

---

## Matriz de cobertura por módulo (resumo)

```
Token · Auth · Wallet · NFT · Marketplaces · Games Store
Bridge · DAO · Staking · Farming · Rewards · Guilds
Loot · Launchpad · Vesting · Treasury · SDK · API · Admin · Indexer
```

**Total catalogado nesta versão:** 120+ requisitos funcionais numerados.  
Refinamento detalhado de AC (acceptance criteria) ocorre por épico no backlog pós-aprovação.
