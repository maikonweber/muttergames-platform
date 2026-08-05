# 05 — Histórias de Usuário

**Versão:** 0.1.0  
**Formato:** Como [persona], quero [ação], para [benefício].  
**Prioridade:** P0/P1/P2/P3 · **Estimativa T-shirt:** S/M/L/XL

---

## Épico A — Conta & Wallet

| ID | História | P | Size |
|----|----------|---|------|
| US-A01 | Como jogador, quero criar conta com Google/Apple e receber wallet automática, para começar sem seed phrase | P0 | M |
| US-A02 | Como jogador avançado, quero conectar Phantom, para usar minha self-custody | P0 | S |
| US-A03 | Como jogador, quero exportar/backup da wallet custodial, para assumir self-custody depois | P1 | M |
| US-A04 | Como jogador, quero ver NFTs e $MUTTER num só lugar, para gerenciar inventário | P0 | M |
| US-A05 | Como jogador, quero assinar com Ledger, para maior segurança | P1 | L |

---

## Épico B — Store de Jogos

| ID | História | P | Size |
|----|----------|---|------|
| US-B01 | Como jogador, quero comprar um jogo com $MUTTER, para obter licença permanente | P0 | L |
| US-B02 | Como jogador, quero comprar DLC, para expandir o jogo que já tenho | P0 | M |
| US-B03 | Como jogador, quero ver avaliações, para decidir a compra | P1 | M |
| US-B04 | Como jogador, quero baixar a última versão com hash verificado, para garantir integridade | P0 | M |
| US-B05 | Como studio, quero publicar meu jogo no portal, para vender globalmente | P0 | XL |
| US-B06 | Como studio, quero receber royalties automaticamente, para monetizar | P0 | L |

---

## Épico C — Marketplace de Assets

| ID | História | P | Size |
|----|----------|---|------|
| US-C01 | Como jogador, quero listar uma skin a preço fixo, para vender | P0 | M |
| US-C02 | Como jogador, quero comprar um personagem NFT, para usar no jogo | P0 | M |
| US-C03 | Como colecionador, quero fazer oferta abaixo do ask, para negociar | P1 | M |
| US-C04 | Como colecionador, quero participar de leilão de terreno, para competir | P1 | L |
| US-C05 | Como creator, quero royalties em cada revenda, para renda passiva | P0 | M |
| US-C06 | Como jogador, quero filtrar itens por jogo e raridade, para achar rápido | P0 | M |

---

## Épico D — Staking & Rewards

| ID | História | P | Size |
|----|----------|---|------|
| US-D01 | Como holder, quero stakear $MUTTER, para ganhar rewards | P0 | L |
| US-D02 | Como holder, quero ver APR estimado, para escolher pool | P0 | S |
| US-D03 | Como jogador, quero claim de season com um clique, para receber airdrop | P1 | M |
| US-D04 | Como holder, quero boost de stake com NFT de guilda, para maior yield | P1 | L |

---

## Épico E — Bridge

| ID | História | P | Size |
|----|----------|---|------|
| US-E01 | Como holder, quero bridge $MUTTER de Solana para Base, para usar em DeFi EVM | P1 | XL |
| US-E02 | Como holder, quero acompanhar status do bridge em tempo real, para ter confiança | P1 | M |
| US-E03 | Como holder, quero limites claros por transação, para reduzir risco | P1 | S |

---

## Épico F — Guildas

| ID | História | P | Size |
|----|----------|---|------|
| US-F01 | Como líder, quero criar guilda, para organizar membros | P1 | M |
| US-F02 | Como membro, quero entrar via convite, para jogar em grupo | P1 | S |
| US-F03 | Como líder, quero tesouraria compartilhada, para financiar wars | P2 | L |

---

## Épico G — DAO

| ID | História | P | Size |
|----|----------|---|------|
| US-G01 | Como voter, quero criar proposta de mudança de fee, para governar o protocolo | P2 | L |
| US-G02 | Como holder, quero delegar meu voto, para participar sem votar tudo | P2 | M |
| US-G03 | Como voter, quero timelock visível, para auditar execuções | P2 | S |

---

## Épico H — Desenvolvedor / SDK

| ID | História | P | Size |
|----|----------|---|------|
| US-H01 | Como dev Unity, quero autenticar jogador via SDK, para vincular wallet | P0 | L |
| US-H02 | Como dev, quero mintar item ao completar quest, para recompensar | P0 | L |
| US-H03 | Como dev, quero sandbox com faucet, para testar sem mainnet | P0 | M |
| US-H04 | Como dev, quero webhooks de compra, para liberar entitlement no meu backend | P1 | M |
| US-H05 | Como dev, quero docs OpenAPI, para integrar rápido | P0 | S |

---

## Épico I — Admin

| ID | História | P | Size |
|----|----------|---|------|
| US-I01 | Como admin, quero pausar o marketplace, para conter exploit | P0 | M |
| US-I02 | Como moderador, quero remover jogo que viola ToS, para proteger usuários | P0 | M |
| US-I03 | Como finance, quero ajustar fee dentro de limites, para calibrar economia | P0 | S |
| US-I04 | Como admin, quero ver audit log, para compliance | P0 | M |

---

## Épico J — Loot & Launchpad

| ID | História | P | Size |
|----|----------|---|------|
| US-J01 | Como jogador, quero abrir loot box com odds públicas, para saber as chances | P2 | L |
| US-J02 | Como staker, quero alocação no launchpad por tier, para investir em novos jogos | P2 | XL |

---

## Critérios de aceite genéricos (Definition of Done)

Para cada história P0/P1:
- [ ] AC testáveis escritos no ticket
- [ ] Testes automatizados (unit + e2e quando UI)
- [ ] Telemetria (evento de produto + erro)
- [ ] Docs de usuário/dev atualizadas
- [ ] Review de segurança se tocar em fundos/assinaturas
