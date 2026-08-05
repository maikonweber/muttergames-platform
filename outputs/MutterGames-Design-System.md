# MutterGames — Blockforge Design System

**Versão:** 1.0  
**Origem visual:** logo modular em grafite, amarelo e vermelho  
**Aplicação:** sites públicos, portal do jogador, wallet, inventário, store e marketplace

## 1. Conceito

**Blockforge** combina três ideias do símbolo: blocos modulares, construção de ecossistema e núcleo energético. O sistema deve parecer uma plataforma premium de jogos, não uma corretora. Geometria é precisa; cor é semântica; animação é discreta.

## 2. Paleta

| Token | Hex | Uso |
|---|---|---|
| `void-950` | `#111819` | fundo principal dark |
| `obsidian-900` | `#232C2D` | superfícies elevadas |
| `graphite-700` | `#3B4648` | bordas, controles secundários |
| `stone-500` | `#5E605D` | texto secundário light |
| `artifact-200` | `#D8D4C9` | fundo light e linhas claras |
| `artifact-50` | `#F3F1EA` | texto principal dark |
| `core-500` | `#F0BC2C` | CTA, foco, progresso, seleção |
| `core-300` | `#FFD45A` | hover do CTA |
| `forge-600` | `#CB3E31` | perigo e ação irreversível |
| `forge-400` | `#E45244` | hover de perigo |

### Regras

- Core Gold identifica no máximo uma ação principal por grupo.
- Forge Red é reservado para erro, risco, destruição ou revogação.
- Grafite compõe a maior parte das superfícies.
- Raridade de item não pode substituir estados de erro/sucesso.
- Texto e controles devem atingir WCAG 2.2 AA.

## 3. Tokens CSS

```css
:root {
  --mg-void-950: #111819;
  --mg-obsidian-900: #232c2d;
  --mg-graphite-700: #3b4648;
  --mg-stone-500: #5e605d;
  --mg-artifact-200: #d8d4c9;
  --mg-artifact-50: #f3f1ea;
  --mg-core-500: #f0bc2c;
  --mg-core-300: #ffd45a;
  --mg-forge-600: #cb3e31;
  --mg-forge-400: #e45244;

  --mg-radius-sm: 8px;
  --mg-radius-md: 10px;
  --mg-radius-lg: 14px;
  --mg-radius-xl: 18px;
  --mg-space-1: 4px;
  --mg-space-2: 8px;
  --mg-space-3: 12px;
  --mg-space-4: 16px;
  --mg-space-6: 24px;
  --mg-space-8: 32px;
  --mg-focus: 0 0 0 3px rgb(240 188 44 / 22%);
}
```

## 4. Tipografia

Títulos: sans geométrica como Geist Sans, Space Grotesk ou equivalente local. Interface/corpo: Geist Sans ou Inter. Monospace: Geist Mono para endereços, hashes e valores técnicos.

| Papel | Tamanho | Peso | Uso |
|---|---:|---:|---|
| Display | 48–64 px | 700/800 | hero |
| H1 | 36–48 px | 700/800 | página |
| H2 | 28–32 px | 700 | seção |
| H3 | 20–24 px | 650/700 | componente |
| Body | 16 px | 400 | conteúdo |
| Small | 14 px | 400/500 | suporte |
| Label | 12 px | 600/700 | uppercase técnico |

## 5. Botões

Altura mínima 44 px; radius 10 px; padding horizontal 16 px; gap de ícone 8 px; texto curto com verbo. Um grupo deve possuir no máximo um botão primário.

### Primary

Fundo `core-500`, texto `#201A08`, hover `core-300`. Uso: criar conta, conectar carteira, confirmar ação segura.

### Secondary

Fundo `graphite-700`, texto `artifact-50`, borda clara discreta. Uso: explorar jogos, abrir detalhes.

### Outline

Fundo transparente, texto/borda `core-500`. Uso: ações alternativas ligadas ao ecossistema.

### Ghost

Fundo transparente, texto neutro. Uso: cancelar, voltar e ações de baixa ênfase.

### Danger

Fundo `forge-600`, texto claro. Uso: revogar wallet, excluir ou confirmar ação irreversível. Exige confirmação quando o impacto for alto.

### Estados

Hover altera luminosidade; active desloca 1 px; focus usa anel Core Gold; disabled reduz opacidade e remove interação; loading mantém largura e substitui ícone por spinner com label acessível.

## 6. Formulários

Labels sempre visíveis. Inputs 44 px, surface Void/Artifact, borda Graphite e foco Core Gold. Erro usa Forge Red junto de ícone e texto; nunca somente cor. Helper text fica abaixo do campo. Endereços de wallet são monospace, abreviados visualmente e copiáveis integralmente.

## 7. Cards e superfícies

Cards usam `obsidian-900`, borda Graphite, radius 14 px e sem glow decorativo. Apenas elementos interativos recebem elevação no hover. Cards de jogo priorizam arte; cards de wallet priorizam estado e segurança; cards de ativo mostram origem, compatibilidade e provenance.

## 8. Badges

- Gold soft: compatível, destaque controlado.
- Graphite: informação neutra.
- Red soft: risco, revogado, quarentena.
- Nunca usar badge colorido sem texto.

## 9. Ícones e geometria

Ícones lineares 16/20/24 px, cantos levemente retos e espessura consistente. Motivo hexagonal/cúbico pode aparecer em ilustração, skeleton e divisores, mas não atrás de texto. Evitar excesso de contornos “sci-fi”.

## 10. Movimento

150 ms para hover/press, 200–250 ms para painéis e 300 ms máximo para transições de página. Sem loops decorativos. Respeitar `prefers-reduced-motion`. Ações financeiras ou de wallet não usam celebração antes da confirmação final.

## 11. Acessibilidade

Contraste AA; alvos ≥44 px; foco visível; navegação por teclado; labels e mensagens programáticas; redução de movimento; não depender apenas de cor; botões com rótulo visível; estado loading anunciado; modal devolve foco ao acionador.

## 12. Nomenclatura de componentes

`Button`, `IconButton`, `LinkButton`, `Input`, `Select`, `Checkbox`, `WalletAddress`, `Badge`, `GameCard`, `AssetCard`, `WalletCard`, `Alert`, `Dialog`, `Toast`, `Tabs`, `Skeleton`, `EmptyState`, `StatusDot` e `PageHeader`.

## 13. Critérios de aceite

- Todos os botões possuem default, hover, active, focus, disabled e loading.
- Dark e light passam contraste.
- Componentes funcionam em 320 px.
- Nenhum endereço/valor importante é truncado sem acesso ao conteúdo completo.
- Danger não é usado como decoração.
- Tokens são a única fonte de cor, spacing e radius na implementação.

