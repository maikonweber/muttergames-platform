# MutterGames Web — Especificação de Produto e UX

**Versão:** 1.0  
**Data:** 4 de agosto de 2026  
**Escopo inicial:** site público, portal do jogador, wallet connection, catálogo e inventário  
**Fora do primeiro release:** compra mainnet, MUT, staking, bridge e marketplace financeiro

## 1. Objetivo

Criar a porta de entrada do ecossistema MutterGames. O usuário deve entender os jogos, criar sua identidade, conectar uma carteira Solana com segurança e consultar ativos compatíveis sem precisar conhecer conceitos de blockchain.

## 2. Públicos

- **Jogador visitante:** quer conhecer e baixar jogos.
- **Jogador registrado:** administra conta, segurança e inventário.
- **Jogador Web3:** conecta carteira externa e consulta ativos.
- **Responsável/menor:** precisa de limites e explicações adequadas.
- **Estúdio parceiro:** consulta documentação e solicita integração.
- **Suporte:** orienta sem controlar carteira ou seed phrase.

## 3. Jornadas prioritárias

### J01 — Conhecer o ecossistema

Home → Jogos → Página do jogo → Download/Play. Sucesso: visitante entende a proposta sem ser obrigado a conectar wallet.

### J02 — Criar Mutter ID

Entrar → passkey/e-mail/conta aprovada → consentimentos → perfil mínimo → portal. Sucesso: conta criada em menos de três minutos e sessão protegida.

### J03 — Conectar wallet

Portal → Wallets → escolher carteira → conectar → revisar endereço/rede → assinar challenge → vínculo confirmado. Nenhuma transação financeira é enviada.

### J04 — Ver inventário

Portal → Inventário → filtro por jogo/coleção → ativo → provenance e compatibilidade. Falha de RPC exibe snapshot e horário da última atualização.

### J05 — Revogar wallet

Wallets → selecionar vínculo → confirmar com step-up → revogar. Revogação não transfere nem apaga ativos on-chain.

## 4. Arquitetura da informação

```text
Público
├─ Home
├─ Jogos
│  └─ Jogo
├─ Ecossistema
├─ Ativos
│  └─ Ativo
├─ Desenvolvedores
├─ Transparência
├─ Status
├─ Suporte
└─ Legal

Autenticado
├─ Visão geral
├─ Perfil
├─ Segurança e sessões
├─ Wallets
├─ Inventário
├─ Progressão
├─ Transações
├─ Privacidade
└─ Suporte
```

## 5. Sitemap e rotas

| Rota | Página | MVP | Objetivo |
|---|---|---:|---|
| `/` | Home | sim | marca, proposta, jogos e CTA |
| `/games` | Jogos | sim | catálogo de experiências |
| `/games/[slug]` | Jogo | sim | detalhes, mídia, download e ativos |
| `/ecosystem` | Ecossistema | sim | identidade, interoperabilidade e segurança |
| `/assets/[chain]/[id]` | Ativo público | sim | metadata, provenance e compatibilidade |
| `/developers` | Desenvolvedores | sim | visão da integração e acesso aos docs |
| `/transparency` | Transparência | sim | arquitetura, riscos e autoridades futuras |
| `/status` | Status | sim | componentes e incidentes |
| `/support` | Suporte | sim | ajuda e alertas contra golpes |
| `/legal/terms` | Termos | sim | termos versionados |
| `/legal/privacy` | Privacidade | sim | tratamento de dados |
| `/legal/digital-assets` | Riscos de ativos | sim | linguagem não especulativa |
| `/auth/sign-in` | Entrar | sim | autenticação |
| `/account` | Dashboard | sim | resumo do jogador |
| `/account/security` | Segurança | sim | passkeys, sessões e recovery |
| `/account/wallets` | Wallets | sim | conectar, verificar e revogar |
| `/account/inventory` | Inventário | sim | ativos e entitlements |
| `/account/transactions` | Transações | leitura | eventos e estado |
| `/account/privacy` | Privacidade | sim | consentimentos e exportação |
| `/store` | Store | fase 2 | catálogo sem mainnet inicialmente |
| `/marketplace` | Marketplace | fase 3 | devnet antes de produção |

## 6. Especificação das páginas principais

### 6.1 Home

Blocos: header; hero com “Jogue mundos conectados”; jogos em destaque; como funciona; identidade/inventário; segurança; notícias; CTA; footer. Evitar promessas de ganho e linguagem de investimento.

**Aceite:** LCP p75 <2,5 s; CTA de jogos visível; conteúdo funciona sem JavaScript essencial; metadata/OG; WCAG 2.2 AA.

### 6.2 Jogos

Cards com arte, gênero, plataformas, status, faixa etária e CTA. Filtros por plataforma/gênero. Página do jogo inclui mídia otimizada, requisitos, links oficiais e itens compatíveis.

### 6.3 Ecossistema

Explica Mutter ID, wallets, ativos compatíveis e progressão com diagramas simples. Seção “o que blockchain faz e não faz”. CTA para criar conta, nunca para comprar token.

### 6.4 Dashboard do jogador

Resumo: jogos recentes, nível Mutter, wallet status, quantidade de ativos, segurança e avisos. Nenhum saldo em moeda recebe destaque especulativo.

### 6.5 Wallets

Lista vínculos com nome da carteira, endereço abreviado, rede, custódia, data, status e ações. Botão “Conectar carteira”; avisos: MutterGames nunca solicita seed phrase; assinatura de vínculo não movimenta fundos.

### 6.6 Inventário

Grid/lista; filtros por jogo, coleção, tipo, transferibilidade e compatibilidade. Card mostra imagem segura, nome, classe, jogo de origem e status. Detalhe mostra provenance, metadata hash, owner, mint, coleção, utilidades por jogo e link ao explorer aprovado.

## 7. Estados UX obrigatórios

Loading com skeleton; empty state instrutivo; erro recuperável; offline/stale; autenticação expirada; carteira indisponível; rede incorreta; assinatura rejeitada; challenge expirado; ativo em quarentena; RPC atrasado; manutenção. Nunca apresentar “sucesso” enquanto estado final for desconhecido.

## 8. Conteúdo de segurança

- “Nunca compartilhe sua frase-semente.”
- “Conectar não concede permissão para movimentar fundos.”
- “Verifique rede, endereço e conteúdo antes de assinar.”
- “A blockchain é pública; endereços e transações podem ser visíveis.”
- “Ativos digitais podem perder utilidade ou valor; não há rendimento garantido.”

## 9. Design system

### 9.1 Personalidade visual

Tecnologia de jogos, não corretora. Fundo navy/charcoal, teal como ação/estado seguro, dourado para raridade moderada e vermelho somente para risco/erro. Movimento discreto; reduzir com `prefers-reduced-motion`.

### 9.2 Tokens iniciais

| Token | Valor de referência |
|---|---|
| Background | `#071522` / `#0B1F33` |
| Surface | `#102A3D` |
| Primary | `#19B6A4` |
| Accent | `#E5B94A` |
| Text | `#F4F7F9` |
| Muted | `#AFC2CE` |
| Danger | `#E05454` |
| Radius | 8/12/16 px |
| Grid | 4/8 px spacing |

Tipografia local ou `next/font`; escala responsiva; contraste AA; targets ≥44 px; foco visível.

## 10. Analytics

Eventos: `page_view`, `game_cta`, `sign_in_started/completed`, `wallet_connect_started`, `wallet_provider_selected`, `wallet_challenge_signed/rejected/expired`, `wallet_linked/revoked`, `inventory_loaded`, `asset_viewed`, `support_opened`. Não enviar address completo, player ID ou PII a ferramentas de analytics. Consentimento por finalidade.

## 11. Requisitos funcionais web

| ID | Requisito | Aceite |
|---|---|---|
| WEB-FR-001 | Navegação pública | rotas acessíveis e indexáveis conforme policy |
| WEB-FR-002 | Login/logout | sessão criada, expirada e revogada corretamente |
| WEB-FR-003 | Conectar wallet | Wallet Standard + challenge verificado |
| WEB-FR-004 | Revogar vínculo | step-up e audit log |
| WEB-FR-005 | Exibir inventário | paginação, filtros, freshness e fallback |
| WEB-FR-006 | Exibir ativo | provenance e compatibilidade |
| WEB-FR-007 | Gerenciar segurança | passkeys e sessões ativas |
| WEB-FR-008 | Privacidade | consentimentos, exportação e solicitação |
| WEB-FR-009 | Status | componentes e incidentes publicados |
| WEB-FR-010 | Suporte | conteúdo antifraude e abertura de caso |

## 12. Requisitos não funcionais web

WCAG 2.2 AA; Core Web Vitals em “good” para p75; disponibilidade pública 99,9%; portal 99,95% para identity; CSP rigorosa; cookies HttpOnly/Secure/SameSite; CSRF; sem secrets no bundle; SSR seguro; i18n pt-BR/en; browsers evergreen e mobile responsivo; logs sem PII; testes E2E das jornadas críticas.

## 13. Critérios de lançamento do MVP

- Site público e páginas legais completas.
- Login/passkey e gerenciamento de sessão.
- Conexão, verificação e revogação de wallet na devnet.
- Inventário read-only com freshness e provenance.
- Testes de replay, network mismatch e challenge expirado.
- Accessibility/security review sem bloqueadores.
- Analytics consentido e status page.
- Suporte treinado e mensagens contra seed phishing.

