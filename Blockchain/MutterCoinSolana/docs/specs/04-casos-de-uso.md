# 04 — Casos de Uso

**Versão:** 0.1.0  
**Status:** Draft

Atores: **Jogador**, **Creator/Studio**, **Guild Leader**, **Admin**, **Relayer**, **DAO Voter**, **Sistema**

---

## UC-01 — Onboarding de Jogador

**Ator:** Jogador  
**Pré-condição:** App/Wallet/Store acessível  
**Fluxo principal:**
1. Jogador escolhe login social ou criar wallet.
2. Sistema cria conta + wallet (custodial ou self-custody).
3. Jogador aceita ToS/LGPD.
4. Sistema exibe home com $MUTTER balance e jogos.

**Pós-condição:** Conta ativa, wallet associada.  
**Alternativos:** Importar seed; conectar Phantom.

---

## UC-02 — Comprar Jogo no Marketplace

**Ator:** Jogador  
**Pré:** Jogo publicado e listado; saldo suficiente  
**Fluxo:**
1. Jogador abre storefront do jogo.
2. Seleciona licença/DLC/bundle.
3. Confirma preço + fees em $MUTTER/SOL.
4. Sistema escrow pagamento → libera entitlement.
5. Jogador baixa build com hash verificado.

**Pós:** Licença registrada; royalties creditados ao studio.

---

## UC-03 — Listar e Vender NFT

**Ator:** Jogador/Creator  
**Fluxo:**
1. Seleciona NFT do inventário.
2. Define preço fixo e duração.
3. Aprova escrow do NFT.
4. Comprador paga; contrato distribui seller + royalty + fee.
5. NFT transferido ao comprador.

---

## UC-04 — Oferta e Aceite

**Ator:** Comprador, Vendedor  
**Fluxo:**
1. Comprador cria offer com depósito/escrow de pagamento.
2. Vendedor recebe notificação.
3. Vendedor aceita → swap atômico.
4. Ou rejeita/expira → fundos liberados.

---

## UC-05 — Leilão

**Ator:** Bidders, Seller  
**Fluxo:**
1. Seller cria auction (reserve, start, end).
2. Bidders fazem lances (outbid refunds).
3. Ao encerrar, maior lance vence.
4. Settlement: NFT → winner; funds → seller/royalties/fee.

---

## UC-06 — Stake $MUTTER

**Ator:** Holder  
**Fluxo:**
1. Escolhe pool e lock period.
2. Deposita $MUTTER.
3. Accrual de rewards.
4. Claim rewards; unstake após unlock (ou penalty).

---

## UC-07 — Bridge Solana → Ethereum

**Ator:** Holder, Relayer  
**Fluxo:**
1. Usuário inicia bridge (amount, destino).
2. Lock/burn em Solana.
3. Relayers observam evento e atingem quorum.
4. Mint/unlock wrapped $MUTTER em Ethereum.
5. Usuário recebe status final na UI.

**Exceções:** Timeout → retry; pause rota; limite excedido.

---

## UC-08 — Publicar Jogo (Studio)

**Ator:** Studio  
**Fluxo:**
1. Studio cria conta no Dev Portal.
2. Submete metadata, builds, pricing, royalties.
3. Admin revisa (moderação).
4. Jogo publicado; aparece na store.
5. Studio acompanha vendas/analytics.

---

## UC-09 — Mint de Coleção in-game

**Ator:** Studio via SDK  
**Fluxo:**
1. Jogo autentica jogador.
2. Evento elegível (quest, purchase).
3. Backend assina mint authorization.
4. SDK/programa minta NFT para wallet do jogador.
5. Inventory sync atualiza UI do jogo.

---

## UC-10 — Criar e Gerir Guilda

**Ator:** Guild Leader, Membros  
**Fluxo:**
1. Leader cria guilda + crest.
2. Convida membros.
3. Define roles.
4. (V2) Tesouraria multisig e split de rewards.

---

## UC-11 — Proposta DAO

**Ator:** DAO Voter  
**Fluxo:**
1. Holder com poder mínimo cria proposta.
2. Período de votação.
3. Se quórum+threshold OK → enfileira timelock.
4. Execução automática/manual pós-timelock.

---

## UC-12 — Abrir Loot Box

**Ator:** Jogador  
**Fluxo:**
1. Jogador possui loot box NFT/ticket.
2. Solicita open → request VRF/oracle.
3. Resultado determinístico a partir do randomness.
4. Reward creditado (NFT/token).
5. Odds e proof disponíveis para auditoria.

---

## UC-13 — Participar de Launchpad

**Ator:** Jogador (tier por stake)  
**Fluxo:**
1. Stake/qualificação de tier.
2. Whitelist/alocação.
3. Contribui na sale.
4. Tokens vestidos; claims periódicos.

---

## UC-14 — Pausa de Emergência

**Ator:** Admin (multisig)  
**Fluxo:**
1. Detecção de incidente SEV1.
2. Multisig executa pause em programa/rota.
3. Comunicação status page.
4. Fix + audit + unpause governado.

---

## UC-15 — Claim de Rewards de Season

**Ator:** Jogador  
**Fluxo:**
1. Season encerra; merkle root publicado.
2. Jogador claim com proof.
3. Contrato verifica e transfere rewards.

---

## Diagrama de contexto (atores)

```
                 ┌────────────┐
                 │  Jogador   │
                 └─────┬──────┘
                       │
     ┌─────────────────┼─────────────────┐
     ▼                 ▼                 ▼
 Wallet/App      Marketplaces         Jogos+SDK
     │                 │                 │
     └────────────┬────┴────────┬────────┘
                  ▼             ▼
            API/Backend    Smart Programs
                  │             │
                  ▼             ▼
             Indexer       Bridge/Relayers
                                │
                                ▼
                           Chains EVM/L1
```
