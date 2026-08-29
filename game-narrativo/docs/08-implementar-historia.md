# Como implementar história

Receita para adicionar conteúdo jogável sem tocar no motor. Se o nó não couber neste contrato, o sistema está errado — não o texto.

## Onde o conteúdo vive

| Coisa | Arquivo |
| --- | --- |
| Falas e escolhas | `data/episodes/epXX/nodes.json` |
| Locais | `data/locations/locations.json` |
| Eventos de mapa | `data/events/campus-day.json` |
| Personalidade / voz | `personagens/{quem}.md` |
| Flags | [12-flags-e-escolhas.md](12-flags-e-escolhas.md) |
| Pistas | mesmo doc + `effects` nos nós |

## Passo a passo — cena nova

1. Reservar prefixo `EP0X_SCYY` no [mapa de cenas](04-mapa-de-cenas.md).
2. Escrever beats em `narrativa/` (o que acontece, decisão, gancho).
3. Ler a ficha de cada `speaker` e recusar fala fora de voz.
4. Criar nós com IDs estáveis. `next` de cada ramo reconverge num marco antes da próxima cena.
5. Escolhas críticas: `tags: ["critical"]` e autosave no manager.
6. Rodar a suite de [testes](09-plano-de-testes.md): todo `next` existe; todo `speaker` tem retrato; toda flag está na matriz.
7. Congelar texto antes de localizar.

**Pronto quando:** o caminho crítico da cena abre e fecha no Godot, e um caminho alternativo reconverge no mesmo marco.

## Contrato do nó

Campos: `id`, `speaker`, `text`, `expression`, `location`, `music`, `conditions`, `choices`, `effects`, `next`, `tags`.

- `speaker`: `narrator` ou id de `personagens/`.
- Sem escolhas: usar `next`. Com escolhas: cada escolha tem `next`; o `next` do nó é ignorado.
- Nó com `conditions` no próprio objeto: se falharem, **pular** o nó e seguir o `next` dele (ex.: fala da Bia só se `ep01_confided_bia`).
- `conditions` na escolha: se falhar, o botão não aparece. Sempre restar ≥ 1 escolha visível, ou o nó não deve ser de escolha.
- `who: "festa"` resolve para o personagem de `ep01_festa_*`. `who: "ally"` resolve para `ep01_ally_*`.
- `effects`: lista de `{ "type", ... }`.

### Tipos de efeito

| type | Campos | Exemplo |
| --- | --- | --- |
| `flag` | `flag`, `value` | `{"type":"flag","flag":"ep01_viu_foto_iris","value":true}` |
| `affinity` | `who`, `delta` | `{"type":"affinity","who":"theo","delta":5}` |
| `trust` | `who`, `delta` | `{"type":"trust","who":"bia","delta":3}` |
| `courage` | `delta` | `{"type":"courage","delta":1}` |
| `evidence` | `id` | `{"type":"evidence","id":"ev_colar_iris"}` |
| `goto` | `node` | raro; preferir `next` da escolha |
| `cg` | `id` | `{"type":"cg","id":"cg_ep01_fio_vermelho"}` |
| `profile` | `stat`, `delta` | `empathy` / `reason` / `daring` |
| `wardrobe_tag` | `tag` | `casual` / `formal` / `creative` / `bold` |

## Diamante

Três variações de festa apontam para o mesmo `EP01_SC06_N001`. Variação posterior usa `conditions` em nós filhos, não cenas clonadas.

```text
SC05_theo ──┐
SC05_gael ──┼── EP01_SC06_N001
SC05_noah ──┤
SC05_luna ──┘
```

## Tokens

No JSON: `"{name} segura o colar."` Pronomes acordados no perfil. Não escrever “ele/ela” fixo na protagonista.

## O que não fazer

- Escolha paga como único caminho correto.
- Trancar romance no EP01.
- Evento aleatório com evidência única do mistério.
- ID derivado do texto (`nodo_oi_theo`).
- Quatro respostas que são a mesma fala reescrita.

## Checklist do roteirista

- [ ] Cada personagem passou pela ficha (voz, limite, desejo).
- [ ] Consentimento e classificação 13+ (sem conteúdo adulto no MVP).
- [ ] Escolha crítica tem sinal e autosave.
- [ ] Recap possível: a jogadora entenderia o final desta cena.
- [ ] Dante não é romance no MVP.
