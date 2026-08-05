# MutterGames Web — Especificação Técnica

**Versão:** 1.0  
**Arquitetura recomendada:** Next.js App Router + TypeScript + APIs de domínio separadas  
**Ambientes:** local, development, preview, staging e production

## 1. Decisões arquiteturais

- App Router com Server Components por padrão.
- Client Components apenas para interação, wallet adapter e browser APIs.
- Node.js runtime como padrão; Edge somente quando benefício medido e dependências compatíveis.
- Conteúdo público renderizado no servidor e cacheável; conta sempre dinâmica e privada.
- Route Handlers apenas como BFF/webhook/callback; lógica de domínio vive nas APIs MutterGames.
- Server Actions apenas para mutações UI simples e autenticadas; economia/wallet usa API explícita.
- Nenhuma private key, RPC secret, database credential ou server API key no cliente.

## 2. Estrutura sugerida

```text
apps/web/
├─ src/app/
│  ├─ (marketing)/
│  │  ├─ page.tsx
│  │  ├─ games/page.tsx
│  │  ├─ games/[slug]/page.tsx
│  │  ├─ ecosystem/page.tsx
│  │  ├─ developers/page.tsx
│  │  └─ legal/[document]/page.tsx
│  ├─ (account)/account/
│  │  ├─ layout.tsx
│  │  ├─ page.tsx
│  │  ├─ security/page.tsx
│  │  ├─ wallets/page.tsx
│  │  └─ inventory/page.tsx
│  ├─ assets/[chain]/[id]/page.tsx
│  ├─ api/auth/callback/route.ts
│  ├─ api/wallet/challenge/route.ts
│  ├─ api/wallet/verify/route.ts
│  ├─ error.tsx
│  ├─ global-error.tsx
│  ├─ not-found.tsx
│  ├─ robots.ts
│  ├─ sitemap.ts
│  └─ layout.tsx
├─ src/components/{ui,marketing,account,wallet,inventory}/
├─ src/lib/{api,auth,wallet,validation,telemetry}/
├─ src/server/{clients,actions,policies}/
├─ src/styles/
└─ tests/{unit,integration,e2e}/
```

Route groups não aparecem na URL. `params`, `searchParams`, `cookies()` e `headers()` devem seguir APIs async da versão adotada. Componentes assíncronos não podem ser Client Components.

## 3. Rendering e dados

| Superfície | Estratégia | Cache |
|---|---|---|
| Home/jogos/ecossistema | Server Components | revalidação por tag/content publish |
| Página do jogo | SSG/dynamic metadata | tag `game:{slug}` |
| Ativo público | SSR com freshness | curto; invalidado por asset event |
| Account/wallets | dynamic SSR | `private, no-store` |
| Inventário | server initial + client pagination | private; cache controlado |
| Status | SSR/synthetic source | curto e resiliente |

Evitar waterfalls com `Promise.all`, preload e Suspense. Dados privados não usam cache compartilhado. Toda resposta de account aplica `Cache-Control: private, no-store`.

## 4. BFF e APIs

O browser conversa com o BFF no mesmo domínio para sessão/cookies e com APIs públicas permitidas. BFF adiciona access token server-side, correlation ID e valida CSRF/origin. Não replica regras de ledger ou wallet verification.

```text
Browser → Next.js BFF → Identity/Inventory/Wallet APIs
Browser → Wallet Extension (assinatura local)
Next.js BFF → Wallet Verify API → PostgreSQL/Audit
```

## 5. Autenticação

OIDC Authorization Code + PKCE. Sessão em cookie `HttpOnly`, `Secure`, `SameSite=Lax/Strict`, prefixo `__Host-` quando aplicável. Access tokens nunca em localStorage. Refresh token rotativo permanece server-side. Cada área autenticada valida sessão no servidor; UI client não é controle de acesso.

`proxy.ts` pode fazer checagem leve/roteamento, mas autorização final ocorre no servidor/API. Evitar acesso a banco no proxy.

## 6. Wallet boundary

Wallet adapter/provider é Client Component isolado. Server Components recebem apenas estado serializável. Importações de bibliotecas que acessam `window` ficam atrás da boundary client/dynamic necessária. A página continua renderizável sem extensão instalada.

## 7. Segurança web

### 7.1 Headers

HSTS; CSP com nonces e allowlist mínima; `frame-ancestors 'none'` salvo embeds aprovados; `object-src 'none'`; `base-uri 'self'`; Referrer-Policy; Permissions-Policy; X-Content-Type-Options. Report-only antes de enforcement quando necessário.

### 7.2 Controles

CSRF/origin em mutações; rate limit por IP/sessão/identidade; schema validation; output encoding; image proxy allowlist; file upload fora do MVP; dependency pinning; SAST/SCA/secret scan; audit log; WAF; bot protection adaptativa.

## 8. Imagens, fontes e scripts

Usar `next/image`, `sizes`, dimensões e allowlist de hosts. Imagem NFT remota passa por proxy/sanitização e limita MIME/tamanho; SVG não confiável não renderiza inline. Usar `next/font` para evitar layout shift. Scripts terceiros com `next/script`, consentimento e menor privilégio.

## 9. Metadata, SEO e social

`generateMetadata` em games/assets; canonical; robots impede indexação de account; sitemap apenas público; OG images geradas ou versionadas. Dados estruturados somente quando correspondem ao conteúdo visível. Ativos em quarentena retornam página segura e `noindex`.

## 10. Erros e observabilidade

`error.tsx` por domínio, `global-error.tsx`, `not-found.tsx` e estados de autorização. Não engolir `redirect/notFound` em catches. OpenTelemetry correlaciona route, backend request e wallet flow, sem address completo. Web Vitals, JS errors, API latency e journey synthetic.

## 11. Acessibilidade

HTML semântico; skip link; navegação por teclado; foco gerenciado em modais; labels/erros associados; contraste; reduced motion; announcements para conexão e assinatura; address copiável com label; testes axe + manuais.

## 12. Testes

- Unit: componentes, schemas, formatadores e states.
- Integration: BFF, auth callbacks, challenge proxy e inventory.
- Contract: OpenAPI, wallet challenge e asset metadata.
- E2E: visitante, login, conectar/rejeitar/revogar wallet, inventário e sessão expirada.
- Security: CSRF, XSS metadata, open redirect, replay, network/address mismatch.
- Performance: Lighthouse CI, bundle analysis e RUM.

## 13. CI/CD

Lint, typecheck, unit, contract, build, accessibility smoke, secret/SCA/SBOM, preview e E2E. Artifacts imutáveis; migrations separadas; canary e rollback. Variáveis públicas usam prefixo explícito e não carregam secrets. Preview não acessa produção.

## 14. Critérios técnicos de aceite

- `next build` sem warnings críticos.
- Nenhuma rota autenticada é cacheada publicamente.
- Wallet code não aumenta bundle de páginas públicas desnecessariamente.
- Challenge completo funciona em devnet e falha com replay/expiry.
- CSP enforcement sem violações essenciais.
- WCAG 2.2 AA nas jornadas críticas.
- p75 CWV dentro de “good”.
- E2E passa em mobile/desktop e sem wallet instalada.
- Telemetria correlaciona flow sem expor PII/address completo.

