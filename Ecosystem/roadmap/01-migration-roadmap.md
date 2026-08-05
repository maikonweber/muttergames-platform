# Plano de migração, integração e roadmap

## Fase 0 — decisão e saneamento (0–4 semanas)

- aprovar product boundaries, asset policy e ADR Solana-only MVP;
- inventariar mint/program IDs, supply, authorities e ambientes atuais;
- corrigir encoding e reconciliar documentos MutterCoin existentes;
- threat model, parecer jurídico inicial e owner por serviço;
- congelar qualquer mainnet/TGE até gates formais.

**Saída:** baseline assinado, registro de riscos e nenhuma autoridade desconhecida.

## Fase 1 — foundation off-chain (5–10 semanas)

- Identity, wallet linking, Catalog, Inventory, ledger e event ingestion;
- SDK Godot read-only em ambos os jogos;
- schemas versionados, outbox, audit log, observabilidade e ambientes isolados;
- catálogo piloto com assets não transferíveis.

**Saída:** mesma conta e inventário nos dois jogos, sem dependência de mainnet.

## Fase 2 — devnet econômica (11–18 semanas)

- refatorar emission controller com budgets/vouchers;
- assets e marketplace fixed-price em devnet;
- wallet embedded, gas sponsorship com limites;
- testes adversariais, reconciliação e simulador econômico.

**Saída:** fluxo end-to-end em devnet, invariantes monitorados.

## Fase 3 — piloto fechado (19–26 semanas)

- Fallen Tactics: card backs/banners; Beat Up: skins/decals;
- campanhas sem valor material ou com caps mínimos;
- pentest, auditoria de contracts, bug bounty privado e load test;
- runbooks de pause/restore e suporte treinado.

**Saída:** go/no-go documentado com métricas e auditoria sem findings críticos.

## Fase 4 — mainnet limitada (27–36 semanas)

- coleções allowlisted, marketplace e rewards com caps conservadores;
- rollout 1% → 10% → 50% → 100%, com rollback de UI/serviços;
- reconciliação diária e revisão semanal de fraude/economia.

## Fase 5 — expansão

Governança consultiva, creators, novas coleções e parceiros. Bridge/EVM só passa a discovery após demanda comprovada, análise build-vs-buy e auditoria específica.

## Migração do projeto atual

1. Preservar `MutterCoinSolana` como histórico e sandbox.
2. Registrar todos os endereços existentes; marcar dev/test/prod.
3. Tratar `mutter_token` atual como protótipo até fechar gaps da spec.
4. Importar documentos antigos para um registro de decisões; esta spec vira baseline 1.0.
5. Mapear saves/user IDs atuais para Mutter ID via tabela de aliases, sem sobrescrever saves.
6. Começar SDK em modo read-only e feature flags; ativar writes por jogo e coorte.

## Go/no-go mainnet

- auditoria externa concluída e findings críticos/altos resolvidos;
- multisig, timelock, backups e recovery testados;
- reconciliação supply/ledger/escrow sem divergência;
- jurídico aprova países e UX; suporte e incident response ativos;
- SLOs atingidos por 30 dias em staging/piloto;
- Product Owner, Tech Lead, Security e Legal assinam.
