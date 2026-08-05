# Segurança, operação e governança

## Threat model prioritário

| Ameaça | Controle principal |
|---|---|
| Cliente forja vitória/score | servidor autoritativo, replay/sinais, antifraude |
| Replay de reward | nonce, expiry, receipt PDA e idempotência |
| Chave operacional comprometida | KMS/HSM, multisig, limites e pause |
| Supply indevido | budget controller, cap e monitor de invariantes |
| Marketplace troca mint/recipient | validação completa de accounts e settlement atômico |
| Account takeover | passkey/MFA, risk step-up, cooldown |
| Indexer/RPC diverge | RPCs independentes, finality e reconciliação |
| Supply-chain attack | lockfiles, SBOM, assinatura e build reproduzível |
| Insider abuse | four-eyes, segregação de funções e audit log imutável |

## Gestão de chaves

- cold multisig para upgrade/tesouraria; hot signer só para ações limitadas.
- secrets em KMS/HSM, rotação e acesso just-in-time.
- ambientes dev/staging/mainnet isolados, com mints e program IDs distintos.
- nenhuma seed/private key em repositório, log, analytics ou cliente Godot.

## Incidentes

SEV1 inclui mint não autorizado, insolvência de escrow, divergência de supply e vazamento de signer. Resposta: pausar operação afetada, preservar cancel/withdraw seguro, revogar credenciais, reconciliar, comunicar e publicar postmortem.

## Governança progressiva

1. Conselho técnico + multisig e changelog público.
2. Timelock e votação consultiva de parâmetros econômicos.
3. Votação on-chain limitada por constitution/bounds.
4. Execução DAO somente após auditoria, distribuição e mecanismos contra captura.

Mudanças emergenciais podem pausar, não confiscar ou expandir supply. Retomada exige aprovação múltipla e relatório.

## Compliance

Legal deve avaliar utility/securities, AML/KYC, sanções, menores, loot boxes, impostos, royalties e consumer protection por região. LGPD: base legal, minimização, DSR, retenção e DPA com fornecedores.
