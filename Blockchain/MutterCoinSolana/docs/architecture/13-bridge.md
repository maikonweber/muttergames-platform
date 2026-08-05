# 13 — Arquitetura da Bridge

**Versão:** 0.1.0  
**Modelo:** Canonical mint em Solana + wrapped supply nas destinies

---

## 1. Objetivos

- Mover valor `$MUTTER` entre Solana e chains satélite com segurança conservadora
- Preservar invariant de lastro
- UX com tracking de status e tempos estimados

---

## 2. Rotas (priorização)

| Fase | Rotas |
|------|-------|
| P1 | Solana ↔ Ethereum, Base, Arbitrum, Polygon, BNB |
| P2 | Solana ↔ Optimism, Avalanche |
| P3 | Solana ↔ Immutable, Ronin, Sui, Aptos |

---

## 3. Estratégia de Build vs Buy

**Recomendação:** integrar protocolo battle-tested (ex.: Wormhole NTT, LayerZero OFT-like adapter, ou deBridge) **com** wrappers Mutter (limits, pause, telemetry), em vez de validators 100% caseiros no dia 1.

| Opção | Prós | Contras |
|-------|------|---------|
| Partner messaging | Segurança herdada, time-to-market | Dependência externa, fees |
| Relayer set próprio | Controle | Alto risco; custo ops |
| Híbrido (recomendado) | Limits + insurance + partner proofs | Complexidade média |

---

## 4. Fluxos

### 4.1 Solana → EVM (Lock & Mint)

```
User aprova/envia MUTTER → Bridge Vault (Solana)
Program emite Message {nonce, amount, dst_chain, dst_addr}
Attestation/proof (quorum / partner)
EVM Gateway verifica → mint wrapped MUTTER → user
Fee coletada
```

### 4.2 EVM → Solana (Burn & Unlock)

```
User burn wrapped no EVM Gateway
Message attestada
Solana Bridge verifica → unlock do vault → user
```

---

## 5. Componentes

```
┌────────────┐   ┌─────────────┐   ┌──────────────┐
│ Wallet UI  │──►│ Orchestrator│──►│ Source Chain │
└────────────┘   │ (status FSM)│   └──────┬───────┘
                 └──────┬──────┘          │ events
                        │                 ▼
                 ┌──────▼──────┐   ┌──────────────┐
                 │  Watchers   │──►│ Relayer/Oracle│
                 └─────────────┘   └──────┬───────┘
                                          ▼
                                   ┌──────────────┐
                                   │ Destination  │
                                   └──────────────┘
```

---

## 6. Validação & Mensagens

| Campo mensagem | Descrição |
|----------------|-----------|
| `version` | Schema |
| `nonce` | Unicidade |
| `src_chain_id` / `dst_chain_id` | Rota |
| `token_id` | MUTTER canonical mapping |
| `amount` | Inteiro atomic units |
| `sender` / `recipient` | bytes32 normalized |
| `payload_hash` | Integridade |

Replay: store `used_nonces[src][nonce]`.

---

## 7. Custódia

- Vault PDA Solana (token accounts)
- Gateway contracts EVM com roles `MINTER_ROLE` exclusivas
- Hot wallets de relayer **sem** custódia de user funds (só gas)

---

## 8. Limites & Risk Engine

| Controle | Exemplo inicial |
|----------|-----------------|
| Max per tx | US$ 25k equiv |
| Max per address / day | US$ 50k |
| Max per route / day | US$ 500k |
| Large transfer delay | >US$ 10k → +15–60 min |
| Pause | Por rota e global |

Limites sobem gradualmente pós-observabilidade.

---

## 9. Oráculos

- Preço para denominar limites: Pyth/Switchboard
- Não usar oracle de preço para settlement do bridge amount (amount é nominal do token)

---

## 10. Recuperação & Incidentes

| Cenário | Ação |
|---------|------|
| Mensagem stuck | Retry relayer; manual finalize com proof |
| Bug mint | Pause; forensic; compensate via insurance |
| Divergência supply | Pause global bridge; reconcile |
| Chain halt | Queue intents; resume |

Runbooks em `docs/security/` pós-aprovação.

---

## 11. Auditoria Bridge

Obrigatória: contratos + relayer threat model + invariant tests + chaos tests de reorg.

---

## 12. UX States

`quoted → submitted_source → confirmed_source → attesting → submitting_dest → completed | failed | needs_action`
