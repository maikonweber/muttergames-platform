# MutterGames Ecosystem — Catálogo de Requisitos

**Versão:** 1.0  
**Data:** 4 de agosto de 2026  
**Escopo:** plataforma, jogos integrados, blockchain, lojas, portais e operação  
**Prioridades:** P0 = obrigatório para MVP; P1 = lançamento/escala; P2 = evolução

## 1. Regras de aceitação

Todo requisito deve possuir owner, evidência de teste e ligação com um épico. “Disponível”, “rápido” e “seguro” não são aceite sem métrica. Requisitos financeiros exigem teste positivo, negativo, replay, concorrência, indisponibilidade e reconciliação.

## 2. Requisitos funcionais — identidade e conta

| ID | Pri. | Requisito | Critério de aceite |
|---|---:|---|---|
| FR-ID-001 | P0 | Criar Mutter ID único | Mesmo usuário retorna o mesmo `player_id` nos jogos integrados |
| FR-ID-002 | P0 | Login por passkey e OIDC | Login, logout, expiração e revogação passam testes E2E |
| FR-ID-003 | P0 | Trocar ticket do jogo por sessão | Ticket é single-use, tem audience e expira |
| FR-ID-004 | P0 | Gerenciar sessões | Usuário visualiza e revoga sessões por dispositivo |
| FR-ID-005 | P0 | Vincular carteira | Challenge inclui nonce, domain, address e expiry |
| FR-ID-006 | P0 | Revogar carteira | Vínculo fica inativo sem apagar auditoria |
| FR-ID-007 | P0 | Recuperar conta | Step-up, notificação e cooldown para ações de alto risco |
| FR-ID-008 | P0 | Registrar consentimentos | Versão, finalidade, data e revogação são auditáveis |
| FR-ID-009 | P0 | Aplicar região e idade | Policy engine bloqueia/transforma fluxos restritos |
| FR-ID-010 | P1 | Exportar dados pessoais | Entrega estruturada, legível e dentro do prazo aplicável |
| FR-ID-011 | P1 | Solicitar exclusão | Dados controláveis seguem workflow de retenção/exclusão |
| FR-ID-012 | P1 | Unificar contas duplicadas | Processo revisado preserva ledger e provenance |

## 3. Requisitos funcionais — jogos e integração

| ID | Pri. | Requisito | Critério de aceite |
|---|---:|---|---|
| FR-GM-001 | P0 | Registrar jogo e ambiente | `game_id`, owners, origins, keys e scopes persistidos |
| FR-GM-002 | P0 | Autenticar workload do jogo | mTLS/JWT validado; chave revogável e rotacionável |
| FR-GM-003 | P0 | Receber evento econômico | Schema, assinatura, timestamp e tamanho validados |
| FR-GM-004 | P0 | Garantir idempotência | Repetição retorna o resultado original sem efeito novo |
| FR-GM-005 | P0 | Tratar eventos fora de ordem | Estado final determinístico e evento inválido isolado |
| FR-GM-006 | P0 | Consultar entitlements | Snapshot por jogador/jogo, assinado e com TTL |
| FR-GM-007 | P0 | Operar sem blockchain | Partidas continuam; escrita chain fica pendente |
| FR-GM-008 | P0 | Enviar webhooks | Assinatura, retry, deduplicação e replay disponíveis |
| FR-GM-009 | P0 | Quarentenar jogo | Suspensão bloqueia novos eventos de valor |
| FR-GM-010 | P1 | Suportar SDK C#/Unity | Login, eventos, inventário e telemetria documentados |
| FR-GM-011 | P1 | Suportar SDK TypeScript | Contract tests contra OpenAPI/event schemas |
| FR-GM-012 | P1 | Suportar Unreal | Paridade funcional definida para versão GA |

## 4. Requisitos funcionais — catálogo, ativos e inventário

| ID | Pri. | Requisito | Critério de aceite |
|---|---:|---|---|
| FR-AS-001 | P0 | Publicar produto/ativo por workflow | Draft, review, approval, publish e retire auditáveis |
| FR-AS-002 | P0 | Manter metadata versionada | Hash, schema e histórico preservados |
| FR-AS-003 | P0 | Agregar inventário | Itens internos e on-chain aparecem sem duplicação |
| FR-AS-004 | P0 | Exibir provenance | Chain, mint, collection e origem verificáveis |
| FR-AS-005 | P0 | Mapear compatibilidade | Ativo traduzido por jogo e versão de mapping |
| FR-AS-006 | P0 | Aplicar fallback | Ativo não compatível não quebra o cliente |
| FR-AS-007 | P0 | Quarentenar ativo/coleção | Uso, listing e compra bloqueados conforme política |
| FR-AS-008 | P0 | Sincronizar mudança de owner | Indexer atualiza projeção e reconciliador confirma |
| FR-AS-009 | P1 | Suportar NFT mutável | Mudança autorizada mantém trilha e hash anterior |
| FR-AS-010 | P1 | Suportar ativo soulbound | Transferência é tecnicamente/politicamente impedida |

## 5. Requisitos funcionais — economia, ledger e rewards

| ID | Pri. | Requisito | Critério de aceite |
|---|---:|---|---|
| FR-EC-001 | P0 | Criar contas contábeis | Owner, moeda e finalidade são únicas e auditáveis |
| FR-EC-002 | P0 | Postar dupla entrada | Débitos igualam créditos em unidade atômica |
| FR-EC-003 | P0 | Reservar saldo | Disponível e reservado nunca permitem double-spend |
| FR-EC-004 | P0 | Compensar transação | Correção cria lançamento vinculado; não edita original |
| FR-EC-005 | P0 | Definir campanha | Budget, período, elegibilidade, caps e owner obrigatórios |
| FR-EC-006 | P0 | Calcular reward | Policy/risk/budget precedem a concessão |
| FR-EC-007 | P0 | Impedir claim duplicado | Chave composta e receipt garantem unicidade |
| FR-EC-008 | P0 | Aplicar janela antifraude | Claim permanece pendente até liberar ou rejeitar |
| FR-EC-009 | P0 | Produzir chain intent | Intent contém hash, nonce, expiry e programa allowlisted |
| FR-EC-010 | P0 | Reconciliar ledger/chain | Valores, accounts, signature, slot e finality conferidos |
| FR-EC-011 | P0 | Fechar posição diária | Diferenças possuem owner, ticket e prazo |
| FR-EC-012 | P1 | Calcular faucets/sinks | Dashboard por jogo, coorte, campanha e moeda |
| FR-EC-013 | P1 | Pausar emissão/campanha | Pausa granular não derruba gameplay |
| FR-EC-014 | P1 | Publicar supply | Circulante e vaults seguem metodologia documentada |

## 6. Requisitos funcionais — carteira e blockchain

| ID | Pri. | Requisito | Critério de aceite |
|---|---:|---|---|
| FR-CH-001 | P0 | Criar/ligar embedded wallet | Custódia e recuperação explicadas ao usuário |
| FR-CH-002 | P0 | Conectar carteira externa | Prova de assinatura sem envio de seed |
| FR-CH-003 | P0 | Simular transação | Falha de simulação impede assinatura/submissão |
| FR-CH-004 | P0 | Mostrar transação legível | Valor, moeda, rede, recipient, fee e efeito exibidos |
| FR-CH-005 | P0 | Submeter via relayer | Apenas intent aprovado, válido e dentro dos caps |
| FR-CH-006 | P0 | Rastrear finality | Estado não é final antes do nível configurado |
| FR-CH-007 | P0 | Pausar programa/módulo | Multisig autorizado e evento auditável |
| FR-CH-008 | P0 | Validar authorities | Endereços publicados correspondem ao deployment |
| FR-CH-009 | P0 | Rotacionar signer | Ceremony testada sem perda de disponibilidade |
| FR-CH-010 | P1 | Session keys | Escopo, valor, audience e expiração limitados |
| FR-CH-011 | P1 | Exportar wallet | Fluxo permitido por modelo/região, com step-up |
| FR-CH-012 | P2 | Bridge adapter | Allowlist, caps, circuit breaker e isolamento total |

## 7. Requisitos funcionais — contratos Solana

| ID | Pri. | Requisito | Critério de aceite |
|---|---:|---|---|
| FR-SC-001 | P0 | Registrar coleção | PDA, authority, status e schema validados |
| FR-SC-002 | P0 | Registrar/quarentenar ativo | Evento emitido; política aplicada por consumidores |
| FR-SC-003 | P0 | Criar campanha de rewards | Vault, root, budget, expiry e authority válidos |
| FR-SC-004 | P0 | Realizar claim | Proof, wallet, amount, epoch e receipt verificados |
| FR-SC-005 | P0 | Criar ordem | Seller, owner, mint, preço, nonce e expiry válidos |
| FR-SC-006 | P0 | Preencher ordem | Pagamento e ativo trocados atomicamente |
| FR-SC-007 | P0 | Cancelar/expirar ordem | Somente autorizado; escrow devolvido corretamente |
| FR-SC-008 | P0 | Respeitar fee cap | Programa rejeita fee acima do máximo |
| FR-SC-009 | P0 | Impedir replay | Receipt/nonce torna segunda execução inválida |
| FR-SC-010 | P0 | Atualizar programa | Multisig/timelock e hash verificável |
| FR-SC-011 | P1 | Vesting | Cliff, duração, release e revocation explícitos |
| FR-SC-012 | P2 | Governança executável | Timelock e allowlist limitam instruções |

## 8. Requisitos funcionais — loja e marketplace

| ID | Pri. | Requisito | Critério de aceite |
|---|---:|---|---|
| FR-MK-001 | P0 | Pesquisar catálogo | Filtros, paginação, região e disponibilidade corretos |
| FR-MK-002 | P0 | Exibir produto | Preço total, supply, utilidade e restrições visíveis |
| FR-MK-003 | P0 | Gerar quote | Assinado, imutável, com moeda e expiry |
| FR-MK-004 | P0 | Realizar checkout | Policy, reserva, pagamento e entitlement consistentes |
| FR-MK-005 | P0 | Consultar pedido | Timeline única do off-chain ao on-chain |
| FR-MK-006 | P0 | Emitir recibo | Valores, fees, ativo, order e signature registrados |
| FR-MK-007 | P0 | Criar listing | Ownership, collection, nonce e expiry validados |
| FR-MK-008 | P0 | Comprar listing | Escrow atômico e receipt final |
| FR-MK-009 | P0 | Detectar self/wash trade | Operação bloqueada ou enviada a review |
| FR-MK-010 | P0 | Tratar indisponibilidade | Reserva liberada ou estado pendente reconciliado |
| FR-MK-011 | P1 | Processar fiat | PSP, webhook idempotente e chargeback hold |
| FR-MK-012 | P1 | Tratar refund/disputa | Nova transação e trilha, sem reescrever chain |
| FR-MK-013 | P1 | Distribuir royalties | Política e montantes no receipt/report |

## 9. Requisitos funcionais — portais e administração

| ID | Pri. | Requisito | Critério de aceite |
|---|---:|---|---|
| FR-WB-001 | P0 | Site público | Home, games, ecosystem, status, docs e legal publicados |
| FR-WB-002 | P0 | Portal do jogador | Security, wallets, inventory, orders e privacy |
| FR-WB-003 | P0 | Página de ativo | Provenance, metadata, compatibilidade e riscos |
| FR-WB-004 | P0 | Portal do estúdio | Games, credentials, webhooks, catalog e inspector |
| FR-WB-005 | P0 | Admin separado | RBAC, step-up, reason e immutable audit |
| FR-WB-006 | P0 | Timeline de suporte | Eventos correlacionados sem acesso a secrets |
| FR-WB-007 | P0 | Página de status | Incidentes, componentes e histórico |
| FR-WB-008 | P1 | Treasury transparency | Vaults, authorities, vesting e relatórios |
| FR-WB-009 | P1 | Creator hub | Drops, approvals e royalties |
| FR-WB-010 | P1 | Launchpad | Aplicação, review, sandbox e milestones |

## 10. Requisitos funcionais — risco, suporte e auditoria

| ID | Pri. | Requisito | Critério de aceite |
|---|---:|---|---|
| FR-RS-001 | P0 | Decidir policy | Resultado, versão, razões e TTL registrados |
| FR-RS-002 | P0 | Abrir caso de risco | Evidência, assignee, status e SLA |
| FR-RS-003 | P0 | Aplicar step-up | Ação só continua após desafio válido |
| FR-RS-004 | P0 | Contestar decisão | Apelação e revisão humana disponíveis |
| FR-RS-005 | P0 | Registrar ação admin | Actor, reason, before/after, ticket e trace |
| FR-RS-006 | P0 | Executar kill switch | Módulo para sem derrubar login/gameplay |
| FR-RS-007 | P0 | Notificar incidente | Templates e público definidos por severidade |
| FR-RS-008 | P1 | Legal hold | Registros selecionados preservados sem alteração |

## 11. Requisitos não funcionais — disponibilidade e confiabilidade

| ID | Pri. | Requisito/Meta | Verificação |
|---|---:|---|---|
| NFR-AV-001 | P0 | Identity 99,95% mensal | SLI server-side de requests válidos |
| NFR-AV-002 | P0 | Inventory 99,95% mensal | Success sem respostas semanticamente erradas |
| NFR-AV-003 | P0 | Economy intake 99,95% | Aceite durável, não apenas HTTP 202 |
| NFR-AV-004 | P0 | Store/marketplace 99,9% | Jornada sintética + server metrics |
| NFR-AV-005 | P0 | Gameplay independe da chain | Game-day com RPC bloqueado |
| NFR-AV-006 | P0 | Sem perda de ledger postado | RPO efetivo próximo de zero |
| NFR-AV-007 | P0 | Reconcile 99,9% <5 min | Histograma de lag; 100% diário |
| NFR-AV-008 | P1 | Multi-AZ | Falha de zona testada sem perda |

## 12. Requisitos não funcionais — desempenho e escala

| ID | Pri. | Requisito/Meta | Verificação |
|---|---:|---|---|
| NFR-PF-001 | P0 | Session p95 <250 ms | Teste de carga regional |
| NFR-PF-002 | P0 | Inventory p95 <300 ms | Cache frio/quente separados |
| NFR-PF-003 | P0 | Event intake p95 <500 ms | Persistência durável incluída |
| NFR-PF-004 | P0 | Quote p95 <400 ms | Dependências simuladas e reais |
| NFR-PF-005 | P0 | 5.000 eventos/s burst | Backpressure sem perda |
| NFR-PF-006 | P1 | 1 milhão MAU | Capacity model e load test |
| NFR-PF-007 | P1 | Queue recupera 60 min em <30 min | Teste de backlog |
| NFR-PF-008 | P1 | Web LCP p75 <2,5 s | RUM por dispositivo/região |

## 13. Requisitos não funcionais — segurança

| ID | Pri. | Requisito | Verificação |
|---|---:|---|---|
| NFR-SE-001 | P0 | TLS e encryption at rest | Scanner/config audit |
| NFR-SE-002 | P0 | Secrets apenas em KMS/Vault | Secret scan e runtime audit |
| NFR-SE-003 | P0 | Least privilege/RBAC | Quarterly access review |
| NFR-SE-004 | P0 | Multisig para authorities | On-chain verification |
| NFR-SE-005 | P0 | SAST/SCA/SBOM/signing | CI bloqueia violações |
| NFR-SE-006 | P0 | OWASP ASVS L2 no web/API | Security test report |
| NFR-SE-007 | P0 | Audit externo antes de mainnet | Critical/high fechados |
| NFR-SE-008 | P0 | WAF, rate limit e DDoS | Game-day e load test |
| NFR-SE-009 | P0 | Logs sem credentials/PII sensível | Automated log scan |
| NFR-SE-010 | P1 | Bug bounty | Programa e SLA publicados |

## 14. Requisitos não funcionais — dados, privacidade e compliance

| ID | Pri. | Requisito | Verificação |
|---|---:|---|---|
| NFR-DP-001 | P0 | PII separada e minimizada | Data inventory/DPIA |
| NFR-DP-002 | P0 | Nenhuma PII on-chain | Schema e transaction review |
| NFR-DP-003 | P0 | Retenção por classe | Automated lifecycle tests |
| NFR-DP-004 | P0 | DSAR/export/delete | Runbook e evidence |
| NFR-DP-005 | P0 | Policy por região/idade | Decision table tests |
| NFR-DP-006 | P0 | Audit imutável | Tamper test e restricted access |
| NFR-DP-007 | P1 | Data residency configurável | Deployment/data flow review |
| NFR-DP-008 | P1 | Analytics com consentimento | Event governance audit |

## 15. Requisitos não funcionais — operação e manutenção

| ID | Pri. | Requisito | Verificação |
|---|---:|---|---|
| NFR-OP-001 | P0 | Observabilidade end-to-end | Trace game→API→ledger→chain |
| NFR-OP-002 | P0 | Alertas acionáveis com runbook | Quarterly alert review |
| NFR-OP-003 | P0 | RTO core ≤60 min | DR exercise |
| NFR-OP-004 | P0 | Backup e restore trimestral | Restore evidence |
| NFR-OP-005 | P0 | Deploy canary/rollback | Release rehearsal |
| NFR-OP-006 | P0 | Infraestrutura como código | Drift detection |
| NFR-OP-007 | P0 | Ambientes isolados | Credential/network audit |
| NFR-OP-008 | P1 | Duas majors de SDK por 12 meses | Compatibility matrix |
| NFR-OP-009 | P1 | Depreciação ≥180 dias | Changelog/notification |
| NFR-OP-010 | P1 | Cost budgets por serviço | Monthly FinOps report |

## 16. Requisitos não funcionais — usabilidade e acessibilidade

| ID | Pri. | Requisito | Verificação |
|---|---:|---|---|
| NFR-UX-001 | P0 | WCAG 2.2 AA | Automated + manual audit |
| NFR-UX-002 | P0 | Assinatura human-readable | UX/security acceptance |
| NFR-UX-003 | P0 | Estados pendentes honestos | E2E de falhas/timeout |
| NFR-UX-004 | P0 | i18n pt-BR/en no MVP | Locale tests |
| NFR-UX-005 | P1 | Limites de gasto/parental | Policy and UX tests |
| NFR-UX-006 | P1 | Status e erros compreensíveis | Usability study/support data |

## 17. Matriz de rastreabilidade

| Capability | FRs | NFRs | Épico |
|---|---|---|---|
| Identity | FR-ID-* | AV, PF, SE, DP | E01 |
| Game integration | FR-GM-* | AV, PF, OP | E02 |
| Inventory | FR-AS-* | AV, PF, DP | E03 |
| Economy | FR-EC-* | AV, SE, OP | E04 |
| Chain | FR-CH-* | AV, SE, OP | E05 |
| Contracts | FR-SC-* | SE, OP | E06 |
| Commerce | FR-MK-* | AV, PF, UX | E07 |
| Web | FR-WB-* | PF, SE, UX | E08/E09 |
| Trust | FR-RS-* | SE, DP, OP | E10 |

## 18. Gate de aprovação

P0 deve estar implementado e testado antes do MVP correspondente. Exceção exige risk acceptance com owner, prazo e controle compensatório. Mainnet não permite waiver para ledger balance, duplicate claim, authority/multisig, audit crítico/alto, PII on-chain ou reconciliação.

