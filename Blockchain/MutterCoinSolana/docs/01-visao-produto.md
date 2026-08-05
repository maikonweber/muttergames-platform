# 01 — Documento de Visão do Produto

**Produto:** MutterCoin Ecosystem  
**Organização:** MutterCorp  
**Versão:** 0.1.0  
**Status:** Draft — aguardando aprovação

---

## 1. Visão

Tornar a **MutterCoin (`$MUTTER`)** o **centro financeiro e de ativos digitais** de todos os jogos publicados pela MutterCorp e por estúdios parceiros — unificando pagamentos, NFTs, marketplaces, governança e economia in-game em uma infraestrutura blockchain escalável, segura e amigável a jogadores e desenvolvedores.

---

## 2. Missão

Entregar um ecossistema GameFi completo onde:

1. Jogadores possuem, negociam e transferem ativos com baixa fricção e baixo custo.
2. Desenvolvedores integram economia on-chain via SDK em minutos, não meses.
3. A MutterCorp opera marketplaces, launchpad, bridge e governança com padrões de segurança de nível institucional.
4. O token `$MUTTER` é a unidade de valor, staking, fees, rewards e participação na DAO.

---

## 3. Problema

| Problema | Impacto |
|----------|---------|
| Economias de jogos fechadas (walled gardens) | Jogador não possui ativos reais |
| Gas alto / UX ruim em EVM para games | Abandono e baixa retenção |
| Fragmentação multi-chain | Liquidez e assets espalhados |
| SDKs incompletos para engines | Integração lenta e cara |
| Marketplaces genéricos sem foco GameFi | Baixa descoberta de jogos e itens |
| Bridges inseguros / custódias opacas | Risco sistêmico de perda de fundos |

---

## 4. Solução

Uma plataforma vertical integrada:

```
Jogos MutterCorp + Parceiros
        │
        ▼
   SDK Mutter (Unity / Unreal / Godot / Web)
        │
        ▼
   Wallet + API + Indexer
        │
        ▼
   Marketplaces (Games · NFTs · Itens · Skins · Characters · Lands · Assets)
        │
        ▼
   DeFi GameFi (Staking · Farming · Rewards · Launchpad · DAO)
        │
        ▼
   Solana (L1 primária) ◄──► Bridge ◄──► EVM / outras L1s
```

---

## 5. Personas

| Persona | Necessidade principal |
|---------|----------------------|
| **Jogador casual** | Login simples, comprar skins/itens, jogar sem entender blockchain |
| **Jogador hardcore / trader** | NFTs, leilões, staking, arbitragem entre markets |
| **Guilda / Clã** | Tesouraria compartilhada, rewards de guilda, ranking |
| **Game Studio (MutterCorp)** | Integração nativa, royalties, analytics econômicos |
| **Studio parceiro** | Portal dev, publish games/assets, receive payouts |
| **Investidor / Holder** | Staking, governança, vesting transparente |
| **Admin MutterCorp** | Painel, compliance, pausa de emergência, fees |

---

## 6. Proposta de Valor

### Para jogadores
- True ownership de NFTs e itens
- Marketplace unificado (jogos + assets)
- Wallet própria com onboarding simplificado (social login + custodial opcional → self-custody)
- Baixas taxas (Solana)

### Para desenvolvedores
- SDK multi-engine
- API REST / GraphQL / WebSocket
- Split de royalties automático
- Launchpad para novos títulos

### Para MutterCorp
- `$MUTTER` como medium of exchange do ecossistema
- Fees de marketplace, bridge e launchpad
- Dados econômicos unificados
- Governança progressiva via DAO

---

## 7. Escopo do Produto (módulos)

| Módulo | Descrição |
|--------|-----------|
| MutterCoin Token | SPL Token-2022 com extensões (transfer fee opcional, metadata) |
| Marketplace Games | Venda de jogos, DLCs, bundles, assinaturas, licenças |
| Marketplace NFTs | Coleções ERC-equivalente SPL (Metaplex / Token Metadata) |
| Marketplace Items/Skins/Characters/Lands/Assets | Listagens tipadas por categoria GameFi |
| Bridge | Lock/Mint/Burn/Unlock multi-chain |
| Wallet Mutter | App + extensão + deep-links in-game |
| Launchpad | IDOs / game launches com vesting |
| DAO | Propostas, votação, timelock, tesouraria |
| Staking / Farming / Rewards | Pools, boosts, seasons |
| Guildas | Organizações on-chain/off-chain híbridas |
| Loot Boxes | Probabilidades auditáveis + revelação VRF/oráculo |
| SDK + Dev Portal | Integração e documentação |
| API Pública | Acesso programático com rate limit e keys |
| Admin Panel | Operações, moderação, compliance |

---

## 8. Fora de Escopo (MVP)

- Metaverso 3D completo (planejado V3+)
- Exchange CEX própria
- Stablecoin nativa Mutter
- Fiat on-ramp próprio (usar parceiros: MoonPay, Ramp, etc.)
- L2 custom / appchain própria (avaliar pós-V2)

---

## 9. Métricas de Sucesso (KPIs)

| KPI | Meta 12 meses pós-mainnet |
|-----|---------------------------|
| Wallets ativas mensais (MAU) | ≥ 100.000 |
| Volume marketplace (GMV) | ≥ US$ 5M |
| Jogos publicados | ≥ 10 |
| Studios parceiros | ≥ 25 |
| TVL staking/farming | ≥ US$ 10M |
| Uptime API | ≥ 99.9% |
| Incidentes críticos de segurança | 0 não mitigados |

---

## 10. Princípios de Design

1. **Player-first UX** — blockchain invisível quando possível.
2. **Security by default** — multisig, timelock, pausas, audits.
3. **Composable** — contratos e APIs modulares.
4. **Low friction fees** — Solana como home chain.
5. **Open for builders** — SDK + portal + royalties justos.
6. **Progressive decentralization** — MutterCorp → DAO.

---

## 11. Premissas e Restrições

- Compliance com LGPD para dados pessoais off-chain.
- Sem custódia não declarada: modelos custodial/self-custody explícitos.
- Tokens de equipe/investidores com vesting on-chain.
- Documentação e código versionados; mainnet só após auditoria.

---

## 12. Riscos Estratégicos

| Risco | Mitigação |
|-------|-----------|
| Regulação de game tokens / securities | Legal review contínuo; utility claro |
| Bridge exploit | Design conservador; limiais; audits; insurance fund |
| Baixa adoção de studios | Grants + launchpad + fee rebate |
| Congestionamento Solana | Priority fees; filas off-chain; retry SDK |
| Fragmentação de liquidez | Incentive pools + bridge subsidizado inicial |

---

## 13. Critério de Aprovação deste Documento

- [ ] Product Owner MutterCorp
- [ ] Tech Lead Blockchain
- [ ] Security Lead
- [ ] Legal / Compliance
- [ ] Tokenomics Owner

**Próximo documento:** [Requisitos Funcionais](./specs/02-requisitos-funcionais.md)
