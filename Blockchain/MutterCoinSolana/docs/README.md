# MutterCoin Ecosystem — Documentação Oficial

**Organização:** MutterCorp  
**Produto:** MutterCoin Ecosystem  
**Status:** Fase de especificação (pré-implementação)  
**Versão docs:** 0.1.0  
**Data:** 2026-08-02

---

## Propósito

Este diretório contém **toda a documentação funcional e técnica** do ecossistema MutterCoin.  
**Nenhum contrato inteligente ou código de produção deve ser implementado** até a aprovação formal destes documentos.

---

## Índice de Entregáveis

| # | Documento | Caminho |
|---|-----------|---------|
| 01 | Visão do Produto | [01-visao-produto.md](./01-visao-produto.md) |
| 02 | Requisitos Funcionais | [specs/02-requisitos-funcionais.md](./specs/02-requisitos-funcionais.md) |
| 03 | Requisitos Não Funcionais | [specs/03-requisitos-nao-funcionais.md](./specs/03-requisitos-nao-funcionais.md) |
| 04 | Casos de Uso | [specs/04-casos-de-uso.md](./specs/04-casos-de-uso.md) |
| 05 | Histórias de Usuário | [specs/05-historias-usuario.md](./specs/05-historias-usuario.md) |
| 06 | Fluxos de Negócio | [specs/06-fluxos-negocio.md](./specs/06-fluxos-negocio.md) |
| 07 | Arquitetura de Software | [architecture/07-arquitetura-software.md](./architecture/07-arquitetura-software.md) |
| 08 | Arquitetura Blockchain | [architecture/08-arquitetura-blockchain.md](./architecture/08-arquitetura-blockchain.md) |
| 09 | Escolha da Blockchain | [architecture/09-escolha-blockchain.md](./architecture/09-escolha-blockchain.md) |
| 10 | Tokenomics | [tokenomics/10-tokenomics.md](./tokenomics/10-tokenomics.md) |
| 11 | Smart Contracts | [architecture/11-smart-contracts.md](./architecture/11-smart-contracts.md) |
| 12 | Marketplace de Games | [specs/12-marketplace-games.md](./specs/12-marketplace-games.md) |
| 13 | Bridge | [architecture/13-bridge.md](./architecture/13-bridge.md) |
| 14 | Wallet | [specs/14-wallet.md](./specs/14-wallet.md) |
| 15 | SDK & Developer Portal | [specs/15-sdk.md](./specs/15-sdk.md) |
| 16 | Backend (Microserviços) | [architecture/16-backend.md](./architecture/16-backend.md) |
| 17 | Modelo de Dados | [architecture/17-modelo-dados.md](./architecture/17-modelo-dados.md) |
| 18 | Arquitetura de Segurança | [security/18-arquitetura-seguranca.md](./security/18-arquitetura-seguranca.md) |
| 19 | Checklist de Segurança | [security/19-checklist-seguranca.md](./security/19-checklist-seguranca.md) |
| 20 | Roadmap Técnico | [roadmap/20-roadmap.md](./roadmap/20-roadmap.md) |
| 21 | Plano de Auditoria | [security/21-plano-auditoria.md](./security/21-plano-auditoria.md) |
| 22 | Estratégia de Testes | [roadmap/22-estrategia-testes.md](./roadmap/22-estrategia-testes.md) |
| 23 | Plano de Implantação | [roadmap/23-plano-implantacao.md](./roadmap/23-plano-implantacao.md) |

---

## Decisão Arquitetural Principal (resumo)

| Camada | Escolha |
|--------|---------|
| Chain primária (GameFi / NFTs / marketplace) | **Solana** |
| Token nativo | **SPL Token-2022** (MutterCoin — `$MUTTER`) |
| Liquidez / DeFi institucional | Ethereum + L2s (via Bridge) |
| EVM satélites | Base, Arbitrum, Polygon, BNB Chain |
| Storage off-chain | IPFS + Arweave (pin permanente) |
| Backend | Microserviços + Indexer + API Gateway |

Justificativa completa: [09-escolha-blockchain.md](./architecture/09-escolha-blockchain.md)

---

## Fluxo de Aprovação

```
Docs (esta pasta)
    → Revisão técnica MutterCorp
    → Revisão tokenomics / legal / compliance
    → Aprovação formal (sign-off)
    → Implementação (contratos → backend → apps)
```

**Gate:** nenhum deploy mainnet sem auditoria externa aprovada (ver plano de auditoria).

---

## Convenções

- Idioma: Português (Brasil); termos técnicos em inglês quando padrão de indústria.
- Diagramas: ASCII / Mermaid nos documentos; exportáveis para Eraser sob demanda.
- Versionamento: SemVer nos documentos (`MAJOR.MINOR.PATCH`).
- Mudanças pós-aprovação exigem ADR (Architecture Decision Record) em `docs/architecture/adrs/`.
