# PRJ-01 — Portal Web

**Pasta:** `apps/web`  
**Pacote:** `@muttergames/web`  
**Stack:** Next.js 16 (App Router), React 19, TypeScript  
**Status:** MVP local  
**Owner:** Eng plataforma / Produto

## 1. Objetivo

Portal oficial MutterGames: vitrine de jogos, ecossistema, marketplace, blockchain e conta/wallet do jogador.

## 2. Não-objetivos

- Substituir o launcher na instalação de builds Windows.
- Ser a fonte de verdade de inventário/ledger (isso é a API).
- Manter paridade com `muttergames-web/` (legado).

## 3. Escopo funcional

| ID | Requisito | Aceite |
|---|---|---|
| WEB-RF-01 | Home pública | Renderiza em desktop/mobile |
| WEB-RF-02 | Páginas games / ecosystem / marketplace / blockchain | Rotas acessíveis |
| WEB-RF-03 | Conta e wallets | Challenge Devnet; sem tx financeira automática |
| WEB-RF-04 | CTA para instalação via launcher | Deep link `muttergames://` quando aplicável |
| WEB-RF-05 | Consumir API oficial | Base URL apontando para `apps/api` |

## 4. Rotas

| Path | Função |
|---|---|
| `/` | Home |
| `/games` | Catálogo de jogos |
| `/ecosystem` | Ecossistema |
| `/marketplace` | Marketplace |
| `/blockchain` | Blockchain |
| `/account` | Conta |
| `/account/wallets` | Wallets |

## 5. Como rodar

```bash
pnpm dev:web
# http://localhost:3000
```

## 6. Docs relacionados

- README: [`apps/web/README.md`](../../apps/web/README.md)
- Specs consolidadas: `outputs/MutterGames-Web-Product-Spec.md`, `...-Technical-Spec.md`, `...-Content-Map.md`, `...-Design-System.md`
- Wallet: `outputs/MutterGames-Wallet-Connection-Spec.md`

## 7. Critérios de aceite do MVP local

1. `pnpm dev:web` sobe sem erro com API local.  
2. Rotas listadas respondem 200.  
3. Fluxo de wallet não movimenta fundos.  
4. README deixa claro que `apps/web` é o app oficial.
