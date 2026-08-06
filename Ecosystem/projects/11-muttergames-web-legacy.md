# PRJ-11 — muttergames-web (legado / referência)

**Pasta:** `muttergames-web/`  
**Status:** Cópia independente de referência  
**Owner:** Eng plataforma (manutenção mínima)

## 1. Decisão

O app **oficial** executado pela raiz, pnpm workspace e Docker Compose é sempre [`apps/web`](01-web.md) (PRJ-01).

`muttergames-web` permanece como histórico/protótipo inicial (Blockforge DS, challenge local). **Não** adicionar features novas aqui.

## 2. Tratamento

| Ação | Política |
|---|---|
| Desenvolvimento | Somente `apps/web` |
| Docs / links | Apontar para PRJ-01 |
| Remoção futura | ADR de deprecação quando paridade for confirmada |

## 3. Docs

- [`muttergames-web/README.md`](../../muttergames-web/README.md)
- README raiz do monorepo
