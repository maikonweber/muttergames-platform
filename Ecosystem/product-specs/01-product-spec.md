# Especificação de produto

## Objetivo

Criar uma conta MutterGames única em que o jogador possa acessar os dois jogos, receber conquistas e itens, gerenciar coleções e negociar assets elegíveis, mantendo gameplay rápido e acessível a quem não conhece blockchain.

## Escopo MVP

- Mutter ID, login social/e-mail, sessões e vínculo de wallets.
- Wallet embutida com recuperação e exportação conforme política do provedor.
- Perfil, inventário unificado e catálogo versionado.
- Entitlements off-chain e NFTs cosméticos on-chain.
- Marketplace de preço fixo em `$MUTTER` e USDC; sem leilão no MVP.
- Rewards assinadas pelo servidor, com claim limitado e antifraude.
- Adaptadores Godot para Fallen Tactics e Beat Up.
- Console operacional, trilha de auditoria, pausas e reconciliação.

## Fora do MVP

Bridge, farming, launchpad, DAO executora, loot boxes on-chain, empréstimos, aluguel de NFT, assets gerados por usuário e cash-out direto dentro dos jogos.

## Requisitos funcionais

| ID | Requisito | Aceite resumido |
|---|---|---|
| FR-001 | Criar/autenticar Mutter ID | Conta criada sem exigir seed phrase. |
| FR-002 | Vincular wallet externa | Prova de posse por assinatura e nonce único. |
| FR-003 | Consultar inventário | Retorna entitlements e assets on-chain normalizados. |
| FR-004 | Conceder reward | Somente evento de partida validado e idempotente gera concessão. |
| FR-005 | Claim on-chain | Voucher expira, tem nonce e não pode ser reutilizado. |
| FR-006 | Cunhar asset | Apenas catálogo aprovado e autoridade operacional autorizada. |
| FR-007 | Listar/comprar/cancelar | Escrow atômico, fee/royalty determinísticos e recibo. |
| FR-008 | Importar asset em jogo | Adaptador valida compatibilidade e cria representação local. |
| FR-009 | Exportar asset | Estado incompatível é removido; propriedade permanece verificável. |
| FR-010 | Pausar operações | Operador pausa mint/claim/market sem derrubar gameplay. |
| FR-011 | Excluir conta | PII é apagada/anonimizada; registros financeiros são retidos conforme lei. |
| FR-012 | Auditar economia | Toda mutação tem actor, causa, correlação e antes/depois. |

## Requisitos não funcionais

| ID | Meta inicial |
|---|---|
| NFR-001 Disponibilidade | API de gameplay 99,9%; marketplace 99,5% mensal. |
| NFR-002 Latência | p95 leitura < 300 ms na região primária; escrita < 700 ms sem contar confirmação da chain. |
| NFR-003 Escala | 10 mil sessões concorrentes e 200 eventos/s sustentados no piloto. |
| NFR-004 Consistência | Ledger financeiro forte; projeções de inventário eventualmente consistentes em até 60 s. |
| NFR-005 Recuperação | RPO ≤ 5 min; RTO ≤ 60 min para serviços críticos. |
| NFR-006 Segurança | OWASP ASVS L2 para APIs; secrets em KMS/HSM; SLSA/proveniência no build. |
| NFR-007 Privacidade | LGPD by design, minimização, consentimento e exportação dos dados. |
| NFR-008 Observabilidade | logs, métricas e traces com correlation_id; alerta de invariantes econômicos. |
| NFR-009 Acessibilidade | Fluxos web WCAG 2.2 AA como meta. |
| NFR-010 Portabilidade | Contratos de API versionados e SDK Godot sem chave privilegiada. |

## Jornadas críticas

1. **Primeiro acesso:** login → Mutter ID → wallet embutida silenciosa → jogar.
2. **Reward:** resultado assinado pelo servidor → antifraude → ledger → claim opcional.
3. **Compra:** quote → aprovação → escrow atômico → indexação → inventário atualizado.
4. **Interoperabilidade:** posse verificada → policy do jogo → representação local → telemetria.

## Métricas

- conclusão do onboarding, wallet activation, MAU cross-game;
- taxa de claims, GMV, compradores/vendedores únicos e falhas de liquidação;
- emissão/burn por jogo, concentração de rewards, fraude e chargebacks;
- retenção comparada entre jogadores com e sem recursos blockchain.
