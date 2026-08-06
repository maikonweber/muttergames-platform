# MutterGames Web (`apps/web`)

Portal oficial Next.js do monorepo. **Não** confundir com `muttergames-web/` (cópia de referência).

**Spec Ecosystem:** [`Ecosystem/projects/01-web.md`](../../Ecosystem/projects/01-web.md)

## Stack

- Next.js 16 / React 19 / TypeScript
- Pacote: `@muttergames/web` (workspace pnpm)

## Rodar

```bash
# na raiz
pnpm dev:web
# ou
scripts/run-web.sh
```

URL local: http://localhost:3000  
API esperada: http://localhost:3001 (ver `apps/api`).

## Rotas

| Path | Conteúdo |
|---|---|
| `/` | Home |
| `/games` | Jogos |
| `/ecosystem` | Ecossistema |
| `/marketplace` | Marketplace |
| `/blockchain` | Blockchain |
| `/account` | Conta |
| `/account/wallets` | Wallets (challenge Devnet; sem txs financeiras) |

## Notas

- Specs de produto/UI: `outputs/MutterGames-Web-*.md`
- Catálogo instalável: via API `GET /api/v1/launcher/catalog`
- Deep link do portal usa protocolo `muttergames://` (launcher)
