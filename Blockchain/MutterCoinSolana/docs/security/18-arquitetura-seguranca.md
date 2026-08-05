# 18 — Arquitetura de Segurança

**Versão:** 0.1.0

---

## 1. Princípios

1. Least privilege em authorities e API scopes  
2. Defense in depth (chain + app + ops)  
3. Secure defaults (pause, caps, timelock)  
4. Assume breach (segmentação, detecção)  
5. Zero PII on-chain  

---

## 2. Superfícies de Ataque

```
[Wallets/Users] [Games/SDK] [Admin] [Relayers] [RPC]
        \         |        /       /        /
         \        |       /       /        /
              [API Gateway]
                    |
         [Services] [Indexer]
                    |
              [Solana Programs]──[Bridge]──[EVM Contracts]
```

---

## 3. Controles por Camada

### 3.1 Programs / Contracts
- Multisig Squads / Gnosis Safe
- Timelock para mudanças sensíveis
- Pause guards
- Bounds em fees/emissions
- Reentrancy-equivalent care em CPIs
- Nonces bridge
- Formal review + audit

### 3.2 Backend
- WAF, DDoS, rate limit
- mTLS service mesh (V1)
- Secrets Manager / KMS
- Input validation / allowlists
- SSRF protection em webhooks egress
- Dependency scanning

### 3.3 Wallet / Custodial
- MPC ou HSM
- Policy engine (velocity limits)
- Out-of-band confirm high risk
- Anomaly detection

### 3.4 Operações
- RBAC + 2FA hardware admins
- Break-glass accounts monitored
- Immutable audit logs
- Separação de duties

---

## 4. Gestão de Chaves

| Chave | Storage | Rotação |
|-------|---------|---------|
| Program upgrade authority | Multisig cold | Ceremony |
| Mint/emission authority | PDA + multisig governance | N/A |
| Bridge validators | HSM/KMS per relayer | 90 dias |
| API signing (webhooks) | KMS | 180 dias |
| Custodial user keys | MPC shares | policy-based |

---

## 5. Detecção & Resposta

| SEV | Exemplo | Resposta |
|-----|---------|----------|
| SEV0 | Drain bridge/treasury | Pause global, war room, public status |
| SEV1 | Exploit marketplace fee bypass | Pause módulo, patch, notify |
| SEV2 | Indexer outage | Failover, degrade UI |
| SEV3 | Bug cosmético | Ticket normal |

IR plan: detect → contain → eradicate → recover → lessons learned.

---

## 6. Privacy

- Hash/encrypt emails
- Wallet addresses são pseudônimos (ainda assim: minimizar linkage)
- DSR workflows (export/delete)
- Data processing agreements com vendors

---

## 7. Supply Chain

- Locked dependencies
- Reproducible builds programs (solana verify)
- Signed releases SDK
- SBOM por artefato

---

## 8. Segregação de Ambientes

Prod ≠ staging keys; deny cross-env credentials; separate cloud accounts preferencialmente.
