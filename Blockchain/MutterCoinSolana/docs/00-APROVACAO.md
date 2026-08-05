# Gate de Aprovação — Fase de Documentação

**Versão docs:** 0.1.0  
**Regra:** nenhum código de produção / deploy mainnet antes do sign-off abaixo.

---

## Documentos obrigatórios

| # | Documento | Status | Aprovador |
|---|-----------|--------|-----------|
| 01 | Visão do Produto | Draft | Product |
| 02 | Requisitos Funcionais | Draft | Product + Tech |
| 03 | Requisitos Não Funcionais | Draft | Tech + Security |
| 04 | Casos de Uso | Draft | Product |
| 05 | Histórias de Usuário | Draft | Product |
| 06 | Fluxos de Negócio | Draft | Product + Tokenomics |
| 07 | Arquitetura de Software | Draft | Tech Lead |
| 08 | Arquitetura Blockchain | Draft | Tech Lead Blockchain |
| 09 | Escolha da Blockchain | Draft | Tech + Security |
| 10 | Tokenomics | Draft | Tokenomics + Legal |
| 11 | Smart Contracts | Draft | Tech Lead Blockchain |
| 12 | Marketplace de Games | Draft | Product |
| 13 | Bridge | Draft | Security + Tech |
| 14 | Wallet | Draft | Product + Security |
| 15 | SDK | Draft | Tech + DevRel |
| 16 | Backend | Draft | Tech Lead |
| 17 | Modelo de Dados | Draft | Tech Lead |
| 18 | Arquitetura de Segurança | Draft | Security Lead |
| 19 | Checklist de Segurança | Draft | Security Lead |
| 20 | Roadmap | Draft | Product + Tech |
| 21 | Plano de Auditoria | Draft | Security |
| 22 | Estratégia de Testes | Draft | QA/Tech |
| 23 | Plano de Implantação | Draft | Tech + Ops |

---

## Decisões-chave a ratificar

1. **Solana = hub canônico**; EVM = spokes  
2. **Max supply 10B** `$MUTTER` e tabela de alocação  
3. **Bridge via protocolo parceiro + controles Mutter** (não validators 100% próprios no dia 1)  
4. **MVP sem bridge/DAO/loot** (ver roadmap)  
5. **Metaplex + cNFT** para NFTs de alto volume  

---

## Sign-off

| Papel | Nome | Data | Assina |
|-------|------|------|--------|
| Product Owner | | | ☐ |
| Tech Lead | | | ☐ |
| Tech Lead Blockchain | | | ☐ |
| Security Lead | | | ☐ |
| Tokenomics Owner | | | ☐ |
| Legal / Compliance | | | ☐ |

Após sign-off: abrir épicos de implementação na ordem do [documento 11](./architecture/11-smart-contracts.md) §16.
