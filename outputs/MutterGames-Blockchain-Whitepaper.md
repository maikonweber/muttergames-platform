# MUTTERGAMES BLOCKCHAIN

## Whitepaper, Arquitetura, Especificação Funcional e Guia de Integração

**Versão 1.0 — Documento de referência executivo e técnico**  
**Data:** 4 de agosto de 2026  
**Status:** proposta para descoberta, simulação econômica, validação jurídica e implementação incremental

> **Tese central.** A MutterGames deve ser uma rede de jogos primeiro, e uma economia blockchain depois: diversão, segurança e retenção sustentam o valor; tokens e NFTs tornam propriedade, portabilidade e participação verificáveis. Nenhuma recompensa financeira é garantida.

---

## Avisos importantes

Este documento é uma especificação de produto e arquitetura, não oferta de valores mobiliários, promessa de rendimento, aconselhamento financeiro, jurídico ou tributário. Parâmetros econômicos são hipóteses de engenharia. Antes de emissão pública: pareceres por jurisdição, testes de classificação do token, KYC/AML quando aplicável, auditorias independentes, termos de uso, política de privacidade e análise de proteção de menores e consumidores.

Decisões marcadas como **proposta** dependem de simulação e governança. O desenho favorece utilidade e consumo no produto; não usa “retorno garantido”, preço-alvo ou comunicação especulativa.

# Sumário executivo

A MutterGames Blockchain é uma camada comum para Fallen Tactics, Beat Up e futuros jogos. Ela oferece identidade única, carteira incorporada, catálogo de ativos, marketplace, recompensas, missões, progressão compartilhada, launchpad e SDK. Solana é a camada de liquidação preferida pela combinação de programas componíveis, tokens SPL, baixo atrito transacional e ecossistema de carteiras. Bridges são uma fase posterior e isolada por risco.

O sistema separa três domínios. **Gameplay autoritativo** permanece em servidores de jogo; **economia operacional** fica num ledger interno de dupla entrada, capaz de reservar, reconciliar e reverter operações; **propriedade e liquidação final** ficam on-chain. Essa separação impede que latência, bots ou congestionamento dominem a experiência, reduz custos e mantém auditabilidade.

A MutterCoin (símbolo provisório **MUT**) tem oferta máxima proposta de 1 bilhão de unidades. A emissão não é uma torneira permanente: recompensas variáveis dependem de jogadores verificados, receita, retenção, sinks, orçamento por temporada e indicadores de inflação. A maior parte da progressão continua não transferível; apenas ativos escolhidos, claros e úteis tornam-se tokens ou NFTs.

## Decisões de arquitetura recomendadas

| Tema | Decisão de referência | Razão |
|---|---|---|
| Rede | Solana mainnet para valor; devnet/local validator para testes | Liquidação rápida e padrões maduros |
| Token | SPL Token; avaliar Token-2022 por extensão e compatibilidade | Evitar complexidade não necessária |
| NFTs | Metaplex Core ou Token Metadata após benchmark | Coleções, plugins e ecossistema |
| Carteira | Embedded wallet com passkey/MPC e exportação; carteira externa opcional | Onboarding sem seed phrase |
| Jogos | Servidor autoritativo; cliente nunca concede valor | Anti-cheat e integridade econômica |
| Contabilidade | Ledger interno de dupla entrada + reconciliação on-chain | Idempotência, auditoria, reversão |
| Bridges | Nenhuma no MVP; adapters e limites só após maturidade | Bridges ampliam superfície de ataque |
| Governança | Conselho de segurança → governança bicameral progressiva | Evitar plutocracia e captura precoce |

# Índice

| Bloco | Conteúdo | Página |
|---|---|---:|
| Fundamentos | Sumário executivo; visão; princípios | 2–5 |
| Plataforma | Arquitetura; identidade e carteira | 6–7 |
| Economia | MutterCoin; NFTs; Play-and-Earn; marketplace | 8–12 |
| Ecossistema de desenvolvedores | Launchpad; APIs/SDK; programas on-chain | 13–15 |
| Operação | Backend; segurança; analytics; governança; monetização; conformidade | 16–21 |
| Especificação | Requisitos funcionais e não funcionais | 22–23 |
| Validação | Cenários; estudos de caso; fluxos; integração | 24–27 |
| Execução | Roadmap; plano; aceite; decisões abertas | 28–31 |
| Referência | Glossário; referências; apêndices | 32–38 |

# 1. Visão do ecossistema

## 1.1 Missão

Construir um ecossistema de jogos conectados em que jogadores carreguem identidade, reputação, conquistas e ativos compatíveis entre experiências, enquanto estúdios integrem economia e distribuição por interfaces previsíveis. Blockchain serve como infraestrutura de propriedade e liquidação, não como substituto do design de jogos.

## 1.2 Proposta de valor

- **Jogadores:** uma conta, recuperação segura, inventário compreensível, recompensas transparentes e liberdade de negociar ativos elegíveis.
- **Estúdios:** SDK, launchpad, aquisição cruzada, economia parametrizável, pagamentos, catálogo e analytics.
- **Criadores:** royalties configuráveis, campanhas, itens aprovados e participação em eventos.
- **MutterGames:** efeito de rede, receita de marketplace, serviços B2B, retenção cruzada e catálogo crescente.

## 1.3 North Star e métricas guardrail

North Star: **jogadores ativos mensais que participam de dois ou mais jogos com retenção D90 saudável**, não volume financeiro. Guardrails: retenção orgânica, percentual de sessões sem erro de carteira, concentração de riqueza, tempo até primeira diversão, fraude por 10 mil transações, valor de sinks/faucets, suporte por carteira, receita líquida por pagador e satisfação de não pagadores.

## 1.4 O que o ecossistema não é

Não é cassino, renda garantida, banco, corretora ou protocolo DeFi geral. Não transforma todo item em NFT, não exige compra para competir, não promete interoperabilidade sem equivalência semântica e não permite que o cliente do jogo assine concessões de valor.

# 2. Princípios de design

1. **Fun-first.** O loop principal deve funcionar sem token.
2. **Web2-first, Web3-optional.** Carteira invisível até ser útil; consentimento explícito em cada exportação ou operação irreversível.
3. **Servidor autoritativo.** Resultados econômicos derivam de eventos validados.
4. **Menos on-chain, melhor on-chain.** Só propriedade, liquidação e compromissos que se beneficiem de verificabilidade.
5. **Sem pay-to-win.** Poder competitivo negociável é limitado, normalizado ou confinado a modos próprios.
6. **Progressão com significado.** Conquistas e reputação “soulbound” preservam mérito.
7. **Economia observável.** Toda fonte tem orçamento, toda saída tem finalidade, toda mudança tem experimento e rollback.
8. **Segurança por padrão.** Privilégio mínimo, multisig, timelock, limites e pausa de emergência.
9. **Portabilidade sem homogeneização.** Interoperabilidade traduz significado; não copia estatísticas cegamente.
10. **Conformidade configurável.** Políticas por país, idade, ativo e transação.

# 3. Arquitetura de referência

## 3.1 Visão em camadas

```text
┌──────────────────────────────── EXPERIÊNCIAS ────────────────────────────────┐
│ Fallen Tactics │ Beat Up │ novos jogos │ Portal │ Marketplace │ Creator Hub │
└───────────────────────────────┬──────────────────────────────────────────────┘
                                │ SDK / API Gateway / Events
┌───────────────────────────────▼──────────────────────────────────────────────┐
│ IDENTIDADE │ CATÁLOGO │ INVENTÁRIO │ MISSÕES │ ECONOMIA │ LAUNCHPAD │ RISCO │
│ Wallet orchestration │ Policy engine │ Ledger dupla entrada │ Notifications │
└──────────────┬─────────────────────┬──────────────────────┬───────────────────┘
               │                     │                      │
        ┌──────▼──────┐       ┌──────▼──────┐       ┌──────▼────────┐
        │ PostgreSQL  │       │ Event Bus   │       │ Data Platform │
        │ Redis/Object│       │ Outbox/Jobs │       │ Lake/Warehouse│
        └──────┬──────┘       └─────────────┘       └───────────────┘
               │ Relayer / Indexer / Reconciliation
┌──────────────▼──────────────── SOLANA ───────────────────────────────────────┐
│ MUT SPL │ Asset Registry │ Marketplace Escrow │ Rewards Vault │ Governance │
│ Treasury multisig │ Metaplex assets │ Oracle/adapters │ future bridge vault │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Figura 1 — Arquitetura lógica.** O plano de controle e gameplay não depende de confirmação on-chain a cada ação.

## 3.2 Limites de confiança

O cliente é hostil. O servidor do jogo valida física, tempo, match e elegibilidade. O serviço econômico confia apenas em eventos assinados por workload identity e esquema versionado. O relayer não pode inventar concessões: consome intenções aprovadas no ledger. Programas on-chain verificam signatários, PDAs, limites, nonce e estado. O indexador é uma visão, nunca fonte única de verdade.

## 3.3 Solana: modelo de execução

Programas Solana são stateless e o estado mutável reside em accounts; PDAs fornecem endereços determinísticos controlados pelo programa. Transações agregam instruções atomicamente, dentro de limites de tamanho e compute. O desenho deve minimizar contas graváveis concorrentes, particionar vaults e evitar “hot accounts”. Taxas são pagas em SOL; a plataforma pode patrocinar taxas sob políticas e rate limits.

## 3.4 Disponibilidade degradada

Se RPC ou rede estiver indisponível, jogos continuam em modo não financeiro. Operações de saque/mint ficam `PENDING_CHAIN`; compras nunca são confirmadas duas vezes. O sistema exibe estado honesto, reprocessa com idempotency key e reconcilia após recuperação. Dois provedores RPC e um nó/indexador independente evitam dependência única.

## 3.5 Bridges futuras

Bridge não integra o núcleo no MVP. Na fase 4, um **Bridge Adapter** separado aplica allowlist de redes/ativos, caps por janela, circuit breaker, rate limit por identidade, monitor de supply e finality, prova de reserva e mensagem canônica. NFT bridged vira representação claramente rotulada; nunca duplica utilidade simultânea. Incidente congela o adapter, não os jogos.

# 4. Identidade, conta e carteira

## 4.1 Mutter ID

`player_id` UUID é a chave interna; wallet address é credencial vinculada, não identidade. Login suporta passkey, e-mail/OTP e provedores aprovados. Um jogador pode ligar várias carteiras após prova de assinatura. Contas de menor, sanções, região e consentimentos são atributos de política separados.

## 4.2 Carteira incorporada

Onboarding recomendado: passkey cria carteira embedded com MPC ou smart account suportada por fornecedor auditado; usuário recebe tela clara de custódia e recuperação. Exportação para autocustódia é possível quando permitido. Operações comuns podem usar session keys com escopo, valor e expiração. Frases-semente nunca trafegam nos servidores MutterGames.

## 4.3 Progressão compartilhada

O **Mutter Level** deriva de XP verificável, diversidade de jogos, temporadas e conduta. Ele desbloqueia cosméticos, acesso e missões, não vantagem automática. Cada jogo define adaptadores de progressão. A reputação é não transferível, com apelação e expiração de sinais negativos.

## 4.4 Privacidade

PII fica off-chain, criptografada e separada de endereços públicos. On-chain publica apenas identificadores pseudônimos e metadados necessários. Exportação e exclusão apagam dados controlados; registros imutáveis públicos não são prometidos como apagáveis. Analytics usa consentimento, minimização, retenção e agregação.

# 5. MutterCoin (MUT)

## 5.1 Função

MUT é token utilitário para itens elegíveis, taxas, criação, staking de participação e governança futura. Soft currencies de cada jogo continuam off-chain e não transferíveis. O preço de conteúdo deve poder ser denominado em moeda local/USDC e convertido no checkout, reduzindo volatilidade percebida.

## 5.2 Oferta e alocação propostas

Oferta máxima: **1.000.000.000 MUT**, 9 casas decimais. Mint authority deve migrar para multisig/timelock; emissão acima do cap é impossível. A distribuição é envelope máximo, não liberação automática.

| Alocação | % | MUT | Liberação de referência |
|---|---:|---:|---|
| Recompensas e crescimento de jogadores | 30% | 300.000.000 | orçamento decrescente em 10 anos, condicionado a KPIs |
| Treasury/ecossistema | 20% | 200.000.000 | governança, runway, liquidez e contingência |
| Estúdios e launchpad | 15% | 150.000.000 | milestones, retenção e clawback |
| Equipe e contribuidores | 15% | 150.000.000 | 12 meses cliff + 36 meses linear |
| Investidores/parceiros | 10% | 100.000.000 | 12 meses cliff + 24–36 meses linear |
| Liquidez e market operations | 7% | 70.000.000 | política pública, limites e relatórios |
| Comunidade/creators | 3% | 30.000.000 | grants e campanhas verificáveis |

**Regra de lançamento:** publicar endereços dos vaults, vesting, autoridades e dashboard de circulating supply. Alocações não usadas retornam ao treasury; não migram silenciosamente.

## 5.3 Emissão

Emissão por temporada `E_t` é o menor entre orçamento aprovado, limite anual e capacidade econômica:

`E_t = min(B_t, Cap_t, α·Revenue_t + β·Sink_t) × Q_t`

`Q_t` varia de 0 a 1 conforme retenção, fraude, concentração e inflação. Proposta de teto bruto: 8% da reserva de rewards no ano 1, reduzindo 15% ao ano até piso governado. Nenhum algoritmo substitui revisão humana e kill switch.

## 5.4 Faucets

- Recompensa por habilidade em competições com anti-sybil.
- Missões patrocinadas, com orçamento do patrocinador.
- Contribuição criativa/moderação verificada.
- Grants de aquisição com limites por coorte.
- Staking de participação, sem promessa de retorno fixo.

Faucets excluem login diário puramente passivo, múltiplas contas e farming sem consumo. Cada faucet tem owner, orçamento, elegibilidade, teto por pessoa/dispositivo, janela e métrica incremental.

## 5.5 Sinks

- Crafting, upgrade e reroll com parte queimada e parte ao treasury.
- Mint/transformação de cosméticos e nomes.
- Entradas em torneios onde permitido, com prêmio prefinanciado.
- Marketplace fee, criação de guilda e serviços de conveniência não competitivos.
- Season passes, creator drops e launchpad commitments.
- Reparo/durabilidade apenas quando divertido, nunca punição arbitrária.

Meta operacional: valor mensal de sinks entre 70% e 110% dos faucets líquidos em maturidade, medido por coorte e não só agregado.

## 5.6 Staking

Staking é participação: voto, acesso antecipado, prioridade limitada em drops e sinal de compromisso. Recompensas vêm de orçamento divulgado ou receita de serviço, nunca de “yield garantido”. Cooldown, caps por identidade, slashing apenas para funções explicitamente responsáveis e ausência de multiplicador pay-to-win.

## 5.7 Treasury

Treasury usa multisig 3/5 inicialmente, segregação de vaults, políticas por finalidade, limites diários, timelock de 48–72 horas para ações não emergenciais e relatório mensal. Reserva operacional diversificada reduz dependência de MUT. Compras/vendas de mercado exigem mandato, disclosure e proibição de manipulação.

## 5.8 Controle de inflação

Painel semanal: emissão líquida, velocity, holding time, Gini, top-1% share, conversão faucet→sink, receita externa, DAU elegível e preço de cesta de itens. Gatilhos: reduzir recompensa marginal, elevar utilidade/sinks não punitivos, pausar campanhas, aumentar verificação e reprecificar conteúdo. Nunca “resolver” inflação removendo saldo legítimo sem base contratual.

# 6. NFTs e ativos digitais

## 6.1 Taxonomia

| Classe | Transferível | Mutável | Uso recomendado |
|---|---|---|---|
| Personagem | opcional | progressão controlada | identidade visual; poder normalizado em PvP |
| Skin | sim | raramente | cosmético cross-game por mapeamento |
| Equipamento | seletivo | durabilidade/nível | modos específicos; caps competitivos |
| Terreno | sim, fase posterior | estado separado | hubs, crafting, eventos; sem renda garantida |
| Colecionável | sim | não | memória, arte, temporadas |
| Conquista | não (soulbound) | revogável por fraude | reputação e prova de mérito |
| Consumível | geralmente não | queimável | tickets, crafting e boosts controlados |

## 6.2 Regra de mint

Um item só vira NFT quando propriedade pública, escassez ou composição entre aplicações gera benefício líquido. Drops devem mostrar supply, probabilidades, utilidade, restrições, royalties, riscos e política de reembolso. Loot boxes e vendas a menores dependem de análise específica.

## 6.3 Metadados canônicos

```json
{
  "name": "Mutter Relic #0042",
  "symbol": "MREL",
  "description": "Cosmético interoperável da Temporada Genesis.",
  "image": "ar://content-addressed-id",
  "animation_url": "ar://optional-asset",
  "external_url": "https://mutter.games/assets/collection/42",
  "attributes": [
    {"trait_type":"class","value":"relic"},
    {"trait_type":"rarity","value":"epic"},
    {"trait_type":"season","value":"genesis"},
    {"trait_type":"origin_game","value":"fallen-tactics"},
    {"trait_type":"schema_version","value":"1.0.0"}
  ],
  "properties": {
    "category":"image",
    "files":[{"uri":"ar://content-addressed-id","type":"image/webp"}],
    "creators":[{"address":"<creator_pubkey>","share":100}],
    "mutter":{"asset_id":"uuid","compatibility":["fallen-tactics:skin.v1","beat-up:banner.v1"],"content_hash":"sha256:...","license":"personal-display-v1"}
  }
}
```

Metadados usam HTTPS/IPFS/Arweave com hash, MIME, dimensões, licença, classificação etária, locale e schema version. Dados de gameplay mutáveis ficam em estado assinado/registry, não reescrevem história do ativo sem trilha.

## 6.4 Interoperabilidade

Interoperabilidade é uma tradução declarativa. Exemplo: uma espada de Fallen Tactics pode virar skin de luva em Beat Up, nunca transferir “+50 ataque”. O **Compatibility Registry** mapeia `(asset_class, source_schema, target_game)` para entitlement local. Jogos podem rejeitar ativo inseguro ou não classificado.

# 7. Play-and-Earn sustentável

## 7.1 Modelo

O nome recomendado é **Play-and-Earn**: jogar é o propósito; ganhar é consequência limitada de habilidade, contribuição ou patrocínio. Recompensas monetizáveis representam parcela pequena do valor total. XP, ranking e itens de mérito permanecem não transferíveis.

## 7.2 Proof of Play

```text
Sessão → telemetria assinada → servidor autoritativo → score de integridade
      → evento econômico → regras de elegibilidade → ledger reservado
      → janela antifraude → claim → lote on-chain → reconciliação
```

Sinais: duração plausível, diversidade de ações, skill rating, dispositivo, grafo de contas, colusão, repetição, latência e histórico. Modelos não banem sozinhos em casos relevantes; produzem evidência e fila de revisão. Jogador recebe motivo suficiente e canal de apelação sem expor controles exploráveis.

## 7.3 Pool de recompensa

Cada temporada possui budget fixo. Distribuição combina participação verificada, habilidade, contribuição e diminishing returns. Nenhuma partida cria MUT sem envelope. Recompensa esperada é exibida como variável, não salário. Países restritos recebem alternativas não monetárias.

# 8. Marketplace

## 8.1 Escopo

Marketplace unifica listagem, oferta, compra, histórico, royalties, filtros, denúncia e custódia/escrow. O preço pode ser MUT, USDC ou moeda local via parceiro. A plataforma não deve operar order book especulativo no MVP.

## 8.2 Fluxo de compra

```text
Comprador seleciona ativo
  ├─ policy check (idade, região, sanções, limites)
  ├─ quote assinado + expiração
  ├─ reserva de saldo / escrow
  ├─ transação atômica: pagamento ↔ ativo
  ├─ indexação e reconciliação
  └─ recibo, histórico e entitlement no jogo
```

Taxa de referência: 2,5% a 5%, parametrizada por categoria; divisão publicada entre operação, creator e treasury. Royalties são transparência comercial e enforcement no marketplace próprio, reconhecendo limitações fora dele.

## 8.3 Proteções

Simulação antes de assinatura, allowlist de coleções, alerta de preço anômalo, cooling-off para conta recuperada, limite de gasto, detecção wash trading, bloqueio de self-trade, provenance visível, URL verificada e suporte a disputas off-chain quando houver fiat/custódia.

# 9. Launchpad para novos jogos

## 9.1 Funil

1. **Aplicação:** equipe, demo, direitos de IP, público e tese econômica.
2. **Due diligence:** segurança, compliance, qualidade, capacidade e reputação.
3. **Sandbox:** SDK, devnet, catálogo e testes de carga.
4. **Economy review:** fontes/sinks, cenários e risco pay-to-win.
5. **Piloto fechado:** limites baixos, métricas e kill switches.
6. **Lançamento:** campanha cross-game, incentivos por milestone.
7. **Operação:** SLA, auditoria, analytics e revisão trimestral.

## 9.2 Modelo de parceria

Revenue share por serviços/marketplace, grants com vesting por milestones e fundo de aquisição cofinanciado. Estúdio não recebe grande emissão líquida apenas por integrar. Critérios de saída: fraude, abandono, violação de IP, insolvência, segurança ou métricas abaixo do período de cura.

## 9.3 Scorecard

Qualidade do jogo 25%, retenção 20%, sustentabilidade econômica 20%, segurança 15%, equipe/execução 10%, inclusão/compliance 10%. Decisão e conflitos de interesse são registrados.

# 10. APIs e SDK

## 10.1 Princípios

REST para comandos/consultas externas, eventos assíncronos para integração, OpenAPI como contrato, semântica idempotente, versionamento por major e SDKs TypeScript, C#, Unity e Unreal. Chaves de servidor nunca entram no cliente. OAuth 2.1/OIDC para usuário; workload identity/mTLS para serviços.

## 10.2 Endpoints mínimos

| Método | Endpoint | Função |
|---|---|---|
| POST | `/v1/sessions/exchange` | troca token do jogo por sessão Mutter |
| GET | `/v1/players/me` | perfil e consentimentos |
| GET | `/v1/inventory` | inventário paginado/filtrado |
| POST | `/v1/economy/events` | evento idempotente assinado |
| POST | `/v1/rewards/claims` | solicita claim elegível |
| POST | `/v1/market/quotes` | quote vinculante com expiração |
| POST | `/v1/market/orders` | cria/aceita ordem |
| GET | `/v1/assets/{id}` | metadata e compatibilidade |
| POST | `/v1/wallet/challenges` | desafio de vínculo de carteira |
| GET | `/v1/transactions/{id}` | estado end-to-end |

## 10.3 Exemplo de evento econômico

```json
{
  "event_id":"01J...ULID",
  "idempotency_key":"match:abc:player:123:reward:v1",
  "type":"match.completed",
  "schema_version":"1.2.0",
  "occurred_at":"2026-08-04T15:04:05Z",
  "game_id":"fallen-tactics",
  "player_id":"uuid",
  "match_id":"abc",
  "payload":{"mode":"ranked","result":"win","score":842,"integrity":0.98},
  "signature":"base64(workload-signature)"
}
```

Resposta `202 Accepted` não significa recompensa concedida. O cliente consulta o status. Duplicata retorna o mesmo resultado. Erros seguem Problem Details (`type`, `title`, `status`, `code`, `trace_id`).

## 10.4 SDK de integração

```csharp
var mutter = new MutterClient(config);
await mutter.Identity.ExchangeServerTicketAsync(ticket);
var inventory = await mutter.Inventory.ListCompatibleAsync("beat-up");
await mutter.Economy.SubmitAsync(EconomyEvent.MatchCompleted(match));
// O servidor envia; o cliente apenas exibe status e entitlements assinados.
```

SDK inclui cache offline de entitlements, verificação de assinatura, retries com jitter, circuit breaker, telemetry hooks e simulador local. Compatibilidade: duas majors suportadas por no mínimo 12 meses; depreciação anunciada 180 dias antes.

# 11. Smart contracts / programas on-chain

## 11.1 Conjunto mínimo

- **MUT Token/Vesting:** mint, vaults e cronograma; preferir primitivas auditadas.
- **Asset Registry:** coleção, schema, status e compatibility roots.
- **Marketplace Escrow:** ordem, nonce, preço, expiração, fee e liquidação atômica.
- **Rewards Vault:** Merkle root/lote, claim único, expiry e retorno de sobra.
- **Staking/Governance:** lock, delegação, snapshot e execução timelocked.
- **Bridge Adapter:** somente fase futura, isolado e pausável.

## 11.2 Modelo de contas do marketplace

```text
MarketConfig PDA [admin, fee_bps, treasury, paused]
CollectionPolicy PDA [collection, allowed, max_fee, royalty_policy]
Order PDA [seller, asset, currency_mint, price, expiry, nonce, status]
Escrow ATA [owner = Order PDA]
Receipt PDA [order, buyer, tx_slot, amounts, timestamp]
```

## 11.3 Invariantes

Conservação de valor; fee total ≤ cap; moeda e mint esperados; signatário é proprietário/delegado; ordem não expirada; nonce não reutilizado; receipt único; coleção permitida; pause respeitado; PDAs e owners validados; nenhuma account arbitrária aceita como treasury.

## 11.4 Upgrade e auditoria

Programas começam upgradeable sob multisig e timelock. Cada release tem hash verificável, changelog, auditoria, testes de propriedade, fuzzing e bug bounty. Caminho à imutabilidade só após estabilidade. Ações de emergência podem pausar novos fluxos, mas não transferir unilateralmente bens de usuários.

# 12. Backend e dados

## 12.1 Serviços

Identity, Wallet Orchestrator, Player Profile, Catalog, Inventory, Economy/Ledger, Rewards, Marketplace, Launchpad, Policy/Risk, Chain Relayer, Indexer, Reconciliation, Notifications e Analytics. Começar como modular monolith bem separado pode ser mais seguro que microserviços prematuros; extrair por escala/domínio.

## 12.2 Modelo relacional

```sql
players(id uuid pk, status, country, birth_band, created_at)
wallet_links(id, player_id fk, chain, address, custody_type, verified_at, revoked_at)
games(id pk, status, sdk_major, economy_policy_version)
assets(id uuid pk, chain, mint, collection, owner_player_id, metadata_hash, status)
entitlements(id, player_id, game_id, asset_id, type, state, valid_until)
ledger_accounts(id uuid pk, owner_type, owner_id, currency, purpose)
ledger_transactions(id uuid pk, idempotency_key unique, type, status, created_at)
ledger_entries(id, transaction_id fk, account_id fk, side, amount_atomic, created_at)
reward_claims(id, player_id, campaign_id, amount, risk_state, chain_signature)
market_orders(id, seller_id, asset_id, quote_currency, price, expiry, status, chain_order)
chain_transactions(id, intent_id unique, signature, cluster, status, slot, finalized_at)
audit_log(id, actor, action, resource, before_hash, after_hash, trace_id, created_at)
```

Invariante do ledger: soma de débitos = soma de créditos por transação e moeda; montantes são inteiros atômicos; registros postados não são editados, apenas compensados.

## 12.3 Event sourcing pragmático

Eventos imutáveis suportam auditoria, mas projeções operacionais continuam relacionais. Transactional outbox grava mudança e evento na mesma transação. Consumidores deduplicam por `event_id`. Schema registry bloqueia breaking changes. DLQ possui owner e runbook.

## 12.4 Estados transacionais

`CREATED → POLICY_APPROVED → LEDGER_RESERVED → SUBMITTED_CHAIN → CONFIRMED → FINALIZED → RECONCILED`. Falha antes de submissão libera reserva; falha incerta consulta chain antes de retry. Compensações têm vínculo explícito ao original.

# 13. Segurança e anti-cheat

## 13.1 Threat model prioritário

Roubo de chave; takeover de conta; concessão falsa por servidor comprometido; duplicação/replay; manipulação de preço; bot/sybil; colusão; wash trading; metadata maliciosa; supply inconsistente; insider; dependência RPC; bridge exploit; abuso de recuperação e engenharia social.

## 13.2 Controles

- Hardware-backed secrets/KMS, rotação e nenhuma chave privada em logs.
- Multisig e segregação de deveres; acesso just-in-time e auditável.
- Allowlist de programas/mints; transaction simulation e human-readable signing.
- Nonce, expiry, domain separation, idempotência e rate limits.
- SAST, SCA, secret scanning, SBOM, revisão obrigatória e ambientes segregados.
- WAF/DDoS, mTLS, zero trust e egress control do relayer.
- Backups imutáveis, restore testado e reconciliação independente.
- Bug bounty, auditoria externa e tabletop trimestral.

## 13.3 Anti-cheat em profundidade

Servidor autoritativo, validação de movimento/combate, attestation de build quando disponível, replay de partidas, detecção comportamental, graph analytics, device risk e human review. Punições graduais: negar recompensa, shadow pool, suspensão, ban e clawback apenas onde termos/base legal permitem. Separar ban de gameplay, bloqueio econômico e obrigação regulatória.

## 13.4 Matriz de resposta

| Severidade | Exemplo | Resposta alvo |
|---|---|---|
| SEV-0 | chave treasury/program authority | pausa imediata, multisig, comunicação e forense |
| SEV-1 | mint/listing indevido em escala | <15 min triagem, bloquear fluxo afetado |
| SEV-2 | fraude localizada/API degradada | <1 h, limites e correção |
| SEV-3 | defeito sem perda | backlog priorizado e postmortem conforme impacto |

# 14. Analytics e economia sustentável

## 14.1 Camadas métricas

Produto: DAU/MAU, D1/D7/D30/D90, sessão, funil e cross-game. Economia: faucets, sinks, emissão líquida, velocity, concentração, preço de cesta, liquidez e receita externa. Marketplace: GMV, compradores/vendedores, sell-through, spread, wash rate e royalties. Risco: chargeback, takeover, bot, falso positivo e apelações. Plataforma: uptime, p95/p99, error rate, finality, reconciliation lag e custo por MAU.

## 14.2 Experimentação

Toda mudança econômica declara hipótese, população, primary metric, guardrails, duração, power mínimo, stop criteria e rollback. Não executar testes exploratórios que induzam gasto excessivo em menores/vulneráveis. Registrar versão de policy em cada evento.

## 14.3 Health score

Score trimestral combina retenção (25), equilíbrio sinks/faucets (20), receita externa (15), concentração (10), fraude (10), satisfação (10), liquidez saudável sem manipulação (5) e confiabilidade (5). Dois trimestres abaixo de 60 congelam expansão econômica e iniciam remediation.

# 15. Governança DAO

## 15.1 Evolução

**Fase 0:** empresa + conselho de segurança, transparência on-chain. **Fase 1:** signaling comunitário e grants. **Fase 2:** governança bicameral: token holders + council de jogadores/estúdios. **Fase 3:** execução on-chain limitada por constituição, timelock e veto de segurança estritamente definido.

## 15.2 Poderes e limites

Governança pode ajustar budgets, fees dentro de faixas, grants e parâmetros não críticos. Não pode confiscar ativos, expor PII, anular direitos do consumidor, elevar cap de supply sem processo constitucional extraordinário ou burlar sanções/leis. Quorum, supermaioria e período de revisão variam por risco.

## 15.3 Anticaptura

Delegação transparente, snapshots, caps de influência para grants, declaração de conflito, council eleito por reputação não transferível, veto temporário revisável e participação de estúdios. Votos de treasury têm análise de impacto e execução parcelada por milestones.

# 16. Monetização

Receitas: fee de marketplace, venda primária de cosméticos/season passes, launchpad B2B, serviços de infraestrutura/analytics, campanhas patrocinadas, licenciamento do SDK e experiências de creator. Evitar venda de poder, taxas ocultas, dark patterns e dependência de valorização do token.

Unit economics por jogo: `Contribution = net sales + marketplace fees + B2B - rewards subsidy - chain/RPC - fraud - support - revenue share`. Integração avança apenas se contribuição ou valor estratégico tiver caminho verificável.

# 17. Conformidade e operação responsável

## 17.1 Workstreams

- Classificação do MUT e NFTs por jurisdição; restrições de marketing e distribuição.
- KYC/KYB/AML, sanções e travel rule quando atividades/limiares exigirem.
- Licenças de pagamentos, custódia e marketplace; parceiros regulados para fiat.
- LGPD/GDPR/CCPA: bases legais, DPIA, direitos, retenção e vendors.
- Proteção de menores, parental consent, limite de gasto e design apropriado à idade.
- Consumidor: preço total, probabilidades, reembolso, suporte e publicidade.
- Tributação, invoices, withholding e relatórios de transações.
- IP, licenças de creator content, moderação e takedown.

## 17.2 Policy engine

Decisão usa `country`, `age_band`, `verification_level`, `asset_class`, `amount`, `risk_score`, `action` e `partner`. Resultado: allow, deny, require_step_up ou alternative_reward. Policies são versionadas, testadas e auditáveis; nunca codificadas apenas no cliente.

# 18. Requisitos funcionais

| ID | Requisito | Critério de aceitação resumido |
|---|---|---|
| FR-001 | Conta única | login em dois jogos retorna mesmo player_id |
| FR-002 | Vínculo de carteira | challenge assinado, nonce/expiry e revogação |
| FR-003 | Inventário | ativos on/off-chain com provenance e compatibilidade |
| FR-004 | Evento econômico | idempotente, assinado, auditável e versionado |
| FR-005 | Claim | elegibilidade, risco, reserva, chain e reconciliação |
| FR-006 | Marketplace | quote, escrow, liquidação atômica e recibo |
| FR-007 | Progressão | XP compartilhado sem poder cross-game automático |
| FR-008 | NFT mint | collection allowlist, metadata hash e supply |
| FR-009 | Launchpad | workflow, scorecard, sandbox e aprovação |
| FR-010 | Governança | proposta, snapshot, voto, timelock e execução |
| FR-011 | Compliance | policy decision antes de ações reguladas |
| FR-012 | Suporte | histórico, contestação e recuperação segura |
| FR-013 | Analytics | eventos consentidos e dashboards de saúde |
| FR-014 | Pausa | pausa por módulo sem indisponibilizar gameplay |
| FR-015 | Exportação | dados pessoais e inventário em formato legível |

# 19. Requisitos não funcionais

| ID | Dimensão | Meta inicial |
|---|---|---|
| NFR-001 | Disponibilidade API core | 99,95% mensal; marketplace 99,9% |
| NFR-002 | Latência | p95 leitura <250 ms; comando off-chain <500 ms |
| NFR-003 | Escala | 1M MAU; 5k eventos/s burst com backpressure |
| NFR-004 | Durabilidade ledger | RPO≈0 para postagens; backups testados |
| NFR-005 | Recuperação | RTO 60 min core; 4 h analytics |
| NFR-006 | Segurança | OWASP ASVS L2; auditoria de programas antes de mainnet |
| NFR-007 | Observabilidade | traces, logs, metrics e trace_id end-to-end |
| NFR-008 | Acessibilidade | WCAG 2.2 AA no portal/marketplace |
| NFR-009 | Privacidade | minimização, retenção e DSAR dentro do prazo legal |
| NFR-010 | Compatibilidade | duas majors de SDK, depreciação ≥180 dias |
| NFR-011 | Reconciliação | 99,9% em <5 min; 100% diária |
| NFR-012 | Custos | budget e alertas por MAU/transação |

# 20. Cenários positivos e negativos

## 20.1 Positivos

**Crescimento saudável.** Fallen Tactics conquista público; 18% experimentam Beat Up por missão cosmética. Retenção aumenta sem elevar emissão porque prêmio é patrocinado e o ativo muda de aparência, não poder.

**Creator flywheel.** Artistas aprovados lançam skins; marketplace gera receita externa, royalties e sinks de mint. Qualidade é curada, supply divulgado e creators recebem relatórios.

**Novo estúdio.** Um indie integra identidade/inventário em seis semanas, roda piloto capped e recebe grant por retenção, não por volume de token.

## 20.2 Negativos e resposta

**Farm de bots:** DAU cresce, retenção real cai e faucet dispara. Resposta: pausar campanha, graph/device risk, reward delay, prova de habilidade e revisão de falsos positivos.

**Queda do MUT:** jogadores percebem recompensas menores. Resposta: denominar preços em valor estável, reduzir discurso financeiro, priorizar utilidade e financiar rewards por receita; nunca defender preço.

**Exploit de programa:** drain potencial em escrow. Resposta: pause por módulo, revogar relayer, preservar gameplay, comunicar fatos, snapshot/reconciliação e plano de reparação aprovado.

**Bridge hack:** representação externa perde backing. Resposta: caps e adapter isolado limitam dano; bridge congela; ativo canônico Solana continua reconhecido.

**Pay-to-win:** equipamento raro domina ranking. Resposta: normalização, modos separados, balance telemetry, refund/remediation e proibição em competições oficiais.

**Captura da DAO:** baleia tenta direcionar grants. Resposta: bicameralidade, conflitos, caps, timelock e veto temporário revisável.

# 21. Estudos de caso conceituais

## 21.1 Fallen Tactics

Loop: partidas táticas geram XP, ranking e crafting materials off-chain. Campeonatos verificados podem conceder MUT e troféu soulbound. Skins e banners são interoperáveis; unidades competitivas não são compráveis como poder irrestrito. Sinks: cosméticos, entrada patrocinada, crafting visual e guild halls.

## 21.2 Beat Up

Loop: skill, combos e temporadas. Luvas/roupas NFT são cosméticas; atributos competitivos são normalizados. Uma relíquia de Fallen Tactics vira banner/efeito visual. Recompensas usam score de habilidade e integridade, com diminishing returns por repetição de oponente.

## 21.3 Jogo “Skyforge Racers” (novo)

Integra Mutter ID, inventário e marketplace. Um veículo continua estado local; sua pintura pode ser NFT. O launchpad oferece missão cross-game, mas rewards vêm de budget de aquisição. Após D30 e auditoria econômica, o jogo recebe acesso ao mint de coleção com caps.

# 22. Fluxos do jogador

## 22.1 Primeiro contato

1. Jogador baixa Beat Up e entra com passkey/e-mail.
2. Mutter ID e carteira embedded são criados com explicação simples.
3. Tutorial concede item off-chain; nenhuma transação ou compra é exigida.
4. Após primeira vitória, jogador vê missão cross-game e opta por participar.
5. Ao tornar item negociável, vê taxa, rede, irreversibilidade e confirma.

## 22.2 Compra no marketplace

Jogador escolhe skin, recebe quote de 60 s, policy engine verifica região/limite, carteira simula, escrow troca pagamento e ativo atomicamente, indexador confirma, ledger reconcilia e entitlement aparece nos jogos compatíveis. Se chain falha, nenhum recibo final é emitido e reserva é liberada após verificação.

## 22.3 Recuperação de conta

Passkey perdida inicia verificação em múltiplos fatores e cooldown. Operações de alto risco são bloqueadas; sessões revogadas. Alteração de carteira exige prova adicional e alerta. Recuperação nunca pede seed phrase.

# 23. Guia de integração de um novo jogo

## 23.1 Plano de 8 semanas

| Semana | Entrega | Gate |
|---|---|---|
| 1 | discovery, threat model, classificação de ativos | architecture review |
| 2 | Mutter ID e ambientes | login E2E |
| 3 | catálogo/inventário read-only | assets compatíveis |
| 4 | eventos de gameplay assinados | idempotência/load test |
| 5 | ledger e rewards em sandbox | economy simulation |
| 6 | marketplace/claim opcional | security test |
| 7 | piloto fechado e analytics | SLO + fraud thresholds |
| 8 | launch review e rollout 1/5/25/100% | go/no-go |

## 23.2 Checklist técnico

- Registrar `game_id`, origens, chaves de workload e owners.
- Implementar server SDK; proibir secret no build cliente.
- Mapear eventos e schemas; testar duplicates/out-of-order.
- Definir ativos locais, on-chain e soulbound.
- Criar compatibility mappings e fallback visual.
- Rodar simulação faucets/sinks por 12–24 meses.
- Implementar consentimento, região e idade.
- Instrumentar traces, metrics, dashboards e alertas.
- Testar indisponibilidade de API/RPC e rollback.
- Passar segurança, compliance, acessibilidade e launch gates.

## 23.3 Definition of Done

Zero concessão econômica pelo cliente; 100% dos comandos idempotentes; reconciliação fecha; nenhum PII on-chain; economia permanece dentro de guardrails nos cenários p10/p50/p90; suporte possui runbooks; rollback praticado; coleção e autoridades publicadas; termos e disclosures aprovados.

# 24. Roadmap de cinco anos

## Ano 1 — Fundação

Mutter ID, embedded wallet, ledger, catálogo, portal, integração read-only de Fallen Tactics/Beat Up, devnet, threat model, legal discovery e simulador econômico. Beta de rewards não transferíveis; marketplace restrito. Gates: SLO, auditoria e retenção sem incentivo artificial.

## Ano 2 — Mainnet controlada

MUT somente após pareceres/auditorias; NFTs cosméticos, marketplace v1, rewards capped, treasury dashboard, launchpad piloto e SDK Unity/TypeScript. Rollout por região. DAO apenas signaling/grants.

## Ano 3 — Escala do ecossistema

3–5 jogos externos, creator hub, SDK Unreal/C#, marketplace avançado sem especulação, analytics para estúdios, governança bicameral inicial e identidade/reputação refinadas.

## Ano 4 — Interoperabilidade segura

Compatibility Registry aberto, bridge piloto com caps após auditoria, mais meios de pagamento, operação multi-região e grants descentralizados por milestones. Nenhuma expansão se economia/risco estiverem fora dos guardrails.

## Ano 5 — Plataforma madura

10+ jogos ativos com qualidade, governança executável limitada, treasury sustentável, standards públicos, certificação de parceiros e possível imutabilidade de módulos estáveis. Sucesso é retenção cross-game e receita de uso, não preço do token.

## Gates transversais

Cada trimestre: segurança, compliance, economia, produto, confiabilidade e treasury. Qualquer gate vermelho bloqueia aumento de supply, regiões, bridge ou limites.

# 25. Plano de implementação

## 25.1 Primeiros 90 dias

1. Nomear Product/Economy/Security/Compliance owners e decision log.
2. Prototipar Mutter ID + inventory read-only em dois jogos.
3. Construir ledger de dupla entrada e suíte de invariantes.
4. Criar simulator com coortes, bots, sinks e volatilidade.
5. Selecionar wallet/RPC/indexer por avaliação de segurança e saída.
6. Especificar programas, PDAs, autoridades e auditoria.
7. Formalizar taxonomy, schemas e OpenAPI/event contracts.
8. Executar DPIA, análise de token e menores nos mercados-alvo.
9. Estabelecer observabilidade e incident response.
10. Fazer piloto sem token transferível; medir retenção real.

## 25.2 RACI resumido

Product responde por experiência e prioridades; Economy por budgets/inflation; Game Studio por gameplay autoritativo; Platform por APIs/ledger; Blockchain por programas/relayer; Security por threat model/incidentes; Legal/Compliance por policies; Data por métricas; Treasury Committee por vaults; DAO assume poderes gradualmente.

# 26. Critérios de aceite do MVP

- Jogador usa dois jogos com a mesma conta e vê inventário compatível.
- Falha da Solana não interrompe gameplay central.
- Ledger demonstra equilíbrio e reconciliação diária sem diferença não explicada.
- Claim duplicado não paga duas vezes; replay e eventos fora de ordem são testados.
- Marketplace troca ativo/pagamento atomicamente em devnet e possui pausa.
- Auditoria independente não contém finding crítico aberto.
- Piloto mostra retenção incremental sem dependência de recompensa monetária.
- Política de região/idade bloqueia fluxos conforme matriz aprovada.
- Suporte recupera conta sem seed e com cooldown de alto risco.
- Dashboards mostram supply, vaults, faucets, sinks e incidentes.

# 27. Registro de decisões e questões abertas

## Decisões propostas

Solana como chain canônica; Token/Token-2022 escolhido após matriz de extensões e compatibilidade; Metaplex Core versus Token Metadata após benchmark; custodial model por região; MUT lançado somente após product-market fit inicial e legal gates; bridges após ano 3; poder competitivo não interoperável.

## Questões abertas

Mercados de lançamento; parceiro de embedded wallet; símbolos/marca; supply final; necessidade real de token transferível; modelo de royalties; oracle/preço; custódia e fiat; idade mínima; política de recuperação; council composition; critérios de descentralização; padrões de licenciamento de creator assets.

# 28. Glossário

**Account (Solana):** unidade de estado endereçável. **ATA:** token account associada. **Bridge:** sistema que representa ativos entre redes. **Burn:** redução permanente de supply. **CPI:** chamada entre programas. **DAO:** governança coordenada por regras e voto. **Entitlement:** direito de uso reconhecido pelo jogo. **Faucet:** fonte de moeda. **Finality:** grau de irreversibilidade. **GMV:** volume bruto negociado. **Ledger:** contabilidade interna. **MPC:** assinatura com chave distribuída. **NFT:** token não fungível. **Outbox:** padrão de publicação atômica de eventos. **PDA:** endereço derivado por programa. **Play-and-Earn:** recompensa limitada ligada ao jogo/contribuição. **RPC:** interface com a rede. **Session key:** chave temporária e limitada. **Sink:** mecanismo de consumo/retirada de moeda. **Soulbound:** não transferível. **SPL:** padrões/programas de tokens Solana. **Timelock:** atraso antes da execução. **Token-2022:** programa SPL com extensões. **Treasury:** reservas administradas. **Vesting:** liberação ao longo do tempo. **Wash trading:** negociação artificial consigo/relacionados.

# 29. Referências técnicas

1. Solana, **Core Concepts** — accounts, programs, transactions, PDAs, CPIs e limites: https://solana.com/docs/core
2. Solana, **Programs** — execução, upgrade authority e sBPF: https://solana.com/docs/core/programs
3. Solana, **Fees** — base fee, priority fee e compute budget: https://solana.com/docs/core/fees
4. Solana, **SPL Token Basics** — mint, transfer, burn, authority e Token-2022: https://solana.com/docs/tokens/basics
5. Solana, **Program Examples** — padrões Anchor/Native e token extensions: https://solana.com/docs/programs/examples
6. Metaplex Developers, documentação oficial para assets e metadata: https://developers.metaplex.com/

> **Nota de atualização.** Limites, fees, padrões e compatibilidade mudam. Antes de implementação, congelar versões, registrar ADRs e validar a documentação oficial corrente. Os números deste whitepaper são parâmetros de referência, não garantias.

# Apêndice A — Invariantes e testes de propriedade

- Supply circulante = mint supply − saldos de vaults classificados como não circulantes, conforme metodologia publicada.
- Um claim `(campaign, player, epoch)` só finaliza uma vez.
- Ledger sempre balanceado por moeda; nenhuma quantidade decimal de ponto flutuante.
- Escrow só libera ativo com pagamento integral e fee dentro do cap.
- Nenhuma alteração de metadata muda `asset_id`, provenance ou hash anterior sem evento.
- Pause não concede autoridade de transferência.
- Evento inválido/repetido não altera saldo.
- Reconciliação compara intenção, assinatura, slot, accounts e montantes.

# Apêndice B — Risk register inicial

| Risco | Prob. | Impacto | Mitigação | Owner |
|---|---|---|---|---|
| token sem utilidade/retenção | média | crítico | adiar lançamento, pilotos sem token | Product/Economy |
| inflação por bots | alta | alto | caps, delay, anti-sybil, orçamento | Risk/Economy |
| exploit de programa | média | crítico | audit, fuzz, caps, pause, bounty | Blockchain/Security |
| chave comprometida | baixa | crítico | HSM/MPC, multisig, JIT | Security/Treasury |
| falha RPC/indexer | média | médio | múltiplos providers, reconcile | Platform |
| bridge hack | média | crítico | adiar, caps, isolamento | Security |
| classificação regulatória | média | crítico | counsel, geofence, utility-first | Legal |
| pay-to-win | média | alto | normalização e telemetry | Game Design |
| captura de governança | média | alto | bicameral, timelock, conflitos | Governance |
| PII correlacionada on-chain | média | alto | pseudonimização e DPIA | Privacy |

# Apêndice C — Runbooks mínimos

**Supply anomaly:** pausar mint/claim, comparar mint authority e vaults, validar indexadores, preservar logs, acionar multisig, publicar status e reconciliar. **Marketplace exploit:** pausar programa/relayer, bloquear UI, identificar orders/receipts, evitar rollback improvisado, auditoria e plano de restituição. **Account takeover:** revogar sessões, cooldown, congelar ações de alto risco, investigar recuperação e notificar. **RPC outage:** failover, colocar chain writes em fila, manter read cache com stale label e reconciliar.

# Apêndice D — Template de ADR

**Título; status; data; contexto; decisão; alternativas; consequências; segurança; privacidade; economia; compliance; rollback; owners; evidências.** ADRs obrigatórios para token standard, wallet custody, metadata protocol, upgradeability, oracle, bridge, treasury e policy engine.

# Apêndice E — Checklist pré-mainnet

- Auditorias concluídas e findings críticos/altos fechados.
- Authorities em multisig; endereços e política publicados.
- Caps, pause, timelock e monitoring testados.
- Mainnet rehearsal com valores mínimos e reconciliação.
- Termos, privacidade, risco, regiões e suporte aprovados.
- Backups/restore, incident drill e comunicação prontos.
- Supply/vesting dashboard e treasury reporting ativos.
- SDK pinned, SBOM, provenance de builds e rollback.
- Economy simulation revisada por terceiro independente.
- Go/no-go assinado por Product, Security, Legal e Treasury.
