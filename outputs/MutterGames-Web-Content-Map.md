# MutterGames Web — Mapa de Conteúdo e Entregas

**Objetivo:** definir conteúdo necessário para construir, revisar e lançar os sites sem páginas vazias ou mensagens contraditórias.

## 1. Navegação global

Header: Jogos, Ecossistema, Ativos, Desenvolvedores, Suporte; ações Entrar/Criar conta. Footer: Status, Segurança, Transparência, Termos, Privacidade, Riscos de ativos, Cookies, Contato e redes oficiais.

## 2. Inventário de conteúdo

| Página | Conteúdo necessário | Owner | Gate |
|---|---|---|---|
| Home | proposta, hero, jogos, como funciona, CTA | Product/Brand | review de claims |
| Jogos | imagens, descrição, plataforma, rating, links | Game Studios | IP/rating |
| Jogo | trailer, screenshots, requisitos, FAQ | Game Studio | assets finais |
| Ecossistema | identidade, wallets, ativos, segurança | Product/Architecture | technical review |
| Ativo | metadata, provenance, compatibilidade | Catalog | collection validation |
| Wallets | tutorial, riscos, mensagens de estado | Security/Product | wallet threat review |
| Inventário | labels, filtros, empty/error states | Product | integration test |
| Developers | overview, quickstart, APIs/SDK status | Platform | docs accuracy |
| Transparency | architecture, authorities e riscos | Legal/Security | disclosure approval |
| Status | componentes, templates de incidentes | SRE | status drill |
| Suporte | recovery, phishing, tickets | Support/Security | runbook readiness |
| Legal | termos, privacidade, cookies, ativos | Legal | jurisdiction approval |

## 3. Copy base da Home

### Hero

**Título:** Mundos diferentes. Uma identidade de jogador.  
**Subtítulo:** Descubra jogos MutterGames, leve suas conquistas e use ativos compatíveis entre experiências — com segurança e controle.  
**CTAs:** Explorar jogos / Criar Mutter ID.

### Como funciona

1. Crie sua identidade MutterGames.
2. Jogue sem precisar entender blockchain.
3. Conecte uma carteira somente quando quiser.
4. Consulte ativos e compatibilidade com transparência.

### Segurança

“A MutterGames nunca pede sua frase-semente. Conectar uma carteira não transfere fundos. Revise toda assinatura antes de confirmar.”

## 4. Glossário para usuários

**Mutter ID:** sua conta no ecossistema. **Wallet:** aplicativo que controla chaves e endereços. **Conectar:** permitir que o site veja o endereço público. **Assinar mensagem:** provar controle sem movimentar fundos. **Ativo digital:** item registrado numa blockchain. **Mint:** identificador on-chain de um token/ativo. **Devnet:** rede de testes sem valor real.

## 5. Mensagens que não devem ser usadas

“Renda garantida”, “investimento seguro”, “valor só sobe”, “ganhe jogando sem risco”, “NFT exclusivo com retorno”, “staking garantido” ou qualquer promessa financeira. Não chamar conexão de wallet de “login” quando o usuário está apenas vinculando uma credencial.

## 6. Assets necessários

Logo horizontal/vertical; favicon; social/OG; key art de cada jogo; screenshots; trailers; ícones de plataformas; ilustrações de identidade/wallet/inventário; placeholders; empty states; avatar padrão; badges de compatibilidade; ícones de status e segurança. Todo asset precisa de licença, owner, dimensões, formato e alt text.

## 7. Conteúdo legal mínimo antes do beta

Termos de uso; privacidade/LGPD; cookies; riscos de ativos digitais; conteúdo de terceiros; propriedade intelectual; regras de conta/idade; suporte e recuperação; política de marketplace apenas quando existir; região e versão/data de vigência.

## 8. Matriz de idiomas

MVP pt-BR e en. Conteúdo legal não usa tradução automática sem revisão. Slugs estáveis; locale em rota ou negociação definida por ADR. Metadata, alt text, erros e e-mails também são localizados.

## 9. Processo editorial

Draft → Product Review → Technical/Security Review → Legal Review quando necessário → Localization → Accessibility → Publish → Expiry/Review date. Conteúdo versionado e invalidado por tag no site.

## 10. Checklist de prontidão de página

- Objetivo e CTA definidos.
- Copy final e traduzida.
- Imagens otimizadas, licenciadas e com alt text.
- Loading, empty, error e offline states.
- Metadata, canonical, OG e robots.
- Analytics e consentimento.
- Mobile, teclado, leitor de tela e contraste.
- Security/privacy/legal review conforme risco.
- Owner e data de revisão.

