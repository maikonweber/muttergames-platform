# 14 — Wallet Mutter

**Versão:** 0.1.0

---

## 1. Visão

Wallet first-party do ecossistema, otimizada para jogos: onboarding simples para casuais e poder total para avançados.

---

## 2. Modalidades de Conta

| Modo | Descrição | Público |
|------|-----------|---------|
| **Embedded / Custodial** | Chave em HSM/MPC; login social | Casual |
| **Self-custody** | Seed BIP39 no device | Avançado |
| **Hardware** | Ledger | High security |
| **External connect** | Phantom, Solflare, WalletConnect | Já tem wallet |

Migração custodial → self-custody deve ser guiada (export encrypted / show seed com warnings).

---

## 3. Features por Fase

### P0
- Create/import Solana wallet
- Balances SOL / MUTTER / tokens
- Send/receive
- NFT gallery
- Connect to Mutter Store & games (deep link)
- Transaction history (indexer)
- Biometria local / PIN

### P1
- Swap (aggregator)
- Bridge UI
- Staking UI
- Ledger
- WalletConnect
- Address book
- Push notifications de txs

### P2
- Multichain portfolio (EVM views)
- DAO voting
- Guild treasury connect
- Fiat on-ramp partner

---

## 4. Segurança do App

| Controle | Detalhe |
|----------|---------|
| Key storage | Secure Enclave / Keystore / MPC shares |
| Phishing | Domain allowlist para deep links |
| Tx simulation | Preview de balance changes |
| Blind signing | Evitar; mostrar ix summary |
| Session keys | Scoped para games (limites) |
| 2FA | Para export / high-value bridge |
| Remote logout | Custodial |

---

## 5. Integração In-Game

```
Game abre deep link / SDK auth session
  → Wallet aprova session com scopes
      (sign_game_events, list_inventory, max_spend)
  → Temporary session key (opcional)
  → Game opera sem prompt a cada micro-ação (dentro dos limites)
```

---

## 6. Suporte a Wallets Externas

| Wallet | Prioridade |
|--------|------------|
| Phantom | P0 |
| Solflare | P0 |
| Backpack | P1 |
| Ledger | P1 |
| MetaMask (EVM via bridge hub) | P1 (spoke) |
| WalletConnect v2 | P1 |

---

## 7. Telas Principais

1. Home (saldo + atalhos)
2. Swap
3. Bridge
4. Stake
5. Marketplace shortcut
6. NFTs
7. Activity
8. Settings / Security

---

## 8. Compliance

- Sem PII on-chain
- Backup warnings (seed)
- ToS específicos custodial
- LGPD para conta social

---

## 9. SLIs

- Crash-free sessions ≥ 99.5%
- Cold start < 2.5s
- Successful signature rate ≥ 98%
