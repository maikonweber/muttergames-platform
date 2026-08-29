# Mapa de sprites

Estilo: ilustração 2D semi-anime, formas elegantes, iluminação cinematográfica. Paleta-base: azul-noturno, violeta, rosa queimado; dourado só em elementos sobrenaturais.

**Resolução piloto:** fundos 1920 × 1080 (16:9). Retratos de busto em canvas 1200 × 1600 com fundo transparente. Confirmar após o primeiro teste em aparelho.

## Estrutura

```text
assets/
  portraits/
    player/
    theo/
    gael/
    noah/
    luna/
    dante/
    bia/
    helena/
    caio/
    marta/
    iris/
  backgrounds/
  cg/
  ui/
  vfx/threads/
  wardrobe/
  audio/
```

## Convenção de nome

`{grupo}_{sujeito}_{variante}_{estado}.png`

Minúsculas, `snake_case`, PNG RGBA. Expressões sempre no final: `_idle`, `_smile`, `_serious`, `_surprise`, `_sad`, `_angry`, `_blush`, `_think`.

## Pacote de retrato por personagem principal

Seis expressões no MVP (GDD: 6–8). Principais: protagonista, Theo, Gael, Noah, Luna, Bia.

| ID | Arquivo | MVP | Nota |
| --- | --- | --- | --- |
| P-01 | `{who}_idle.png` | Sim | Neutro, boca fechada. |
| P-02 | `{who}_smile.png` | Sim | |
| P-03 | `{who}_serious.png` | Sim | |
| P-04 | `{who}_surprise.png` | Sim | |
| P-05 | `{who}_sad.png` | Sim | |
| P-06 | `{who}_blush.png` | Sim | Interesses + Bia; protagonista opcional. |
| P-07 | `{who}_angry.png` | Não | P1 se a cena pedir. |
| P-08 | `{who}_think.png` | Não | Noah e Gael priorizados. |

Apoio (Dante, Helena, Caio, Marta, Íris): `idle` + `serious` no MVP. Íris aparece como foto/CG, não como interlocutora viva.

## Fundos do MVP (12)

| ID | Arquivo | Local | Camadas |
| --- | --- | --- | --- |
| BG-01 | `bg_terminal_dusk.png` | Terminal de Miralume | céu, mar, plataforma, ônibus |
| BG-02 | `bg_patio_day.png` | Pátio Aurora | céu, prédio, árvores, chão |
| BG-03 | `bg_secretaria_day.png` | Secretaria | |
| BG-04 | `bg_dorm_bia.png` | Dormitório | |
| BG-05 | `bg_festa_night.png` | Festa de recepção | lanternas, crowd silhueta |
| BG-06 | `bg_corredor_old.png` | Corredor antigo | |
| BG-07 | `bg_quarto_night.png` | Quarto da protagonista | |
| BG-08 | `bg_lab_foto.png` | Laboratório fotográfico | EP02 |
| BG-09 | `bg_cafe_farol.png` | Café Farol | |
| BG-10 | `bg_lab_nexo.png` | Laboratório de Noah | EP03 |
| BG-11 | `bg_biblioteca.png` | Biblioteca Aurora | |
| BG-12 | `bg_ensaio.png` | Sala de ensaio | Theo |

Cada fundo: `far`, `mid`, `near` se houver parallax; senão um PNG único.

## CGs do MVP (4)

| ID | Arquivo | Gatilho |
| --- | --- | --- |
| CG-01 | `cg_ep01_fio_vermelho.png` | Primeiro toque / fio vermelho (EP01 SC02) |
| CG-02 | `cg_ep01_foto_iris.png` | Foto de Íris com o colar (EP01 SC06) |
| CG-03 | `cg_ep01_festa_rota.png` | Festa; variante por personagem mais presente (`_theo/_gael/_noah/_luna`) |
| CG-04 | `cg_ep03_predicao.png` | O app prevê a morte de uma conexão |

Variantes de CG-03 são o mesmo enquadramento com o interesse escolhido; não quatro ilustrações de composição distinta no MVP.

## UI

| ID | Arquivo | Uso |
| --- | --- | --- |
| UI-01 | `ui_dialogue_box.png` | Caixa de texto |
| UI-02 | `ui_nameplate.png` | |
| UI-03 | `ui_choice.png` / `_hover` / `_critical` | Escolha crítica tem sinal discreto, não cor só |
| UI-04 | `ui_map_pin.png` | |
| UI-05 | `ui_phone_frame.png` | |
| UI-06 | `ui_evidence_card.png` | |
| UI-07 | `ui_thread_icon_{red,blue,gold,gray}.png` | Indicadores com ícone + cor |

## Fios (VFX)

| ID | Arquivo | Leitura |
| --- | --- | --- |
| FX-01 | `vfx_thread_red.png` (+ frames) | atração / perigo emocional |
| FX-02 | `vfx_thread_blue.png` | confiança / proteção / dependência |
| FX-03 | `vfx_thread_gold.png` | verdade / propósito |
| FX-04 | `vfx_thread_gray.png` | segredo / medo / ruptura |

Espessura e pulsação ligadas ao estado emocional (parâmetros, não sprites extras no MVP).

## Guarda-roupa (MVP)

Categorias: `casual`, `formal`, `creative`, `bold`. 8 peças mínimas (2 por tag) + 1 conjunto de festa. Thumbnails 256 × 256. Progresso nunca exige compra.

## Áudio mínimo do slice

| ID | Arquivo | Uso |
| --- | --- | --- |
| AUD-01 | `mus_theme.ogg` | Tema (piano, cordas, textura eletrônica) |
| AUD-02 | `mus_arrival.ogg` | EP01 abertura |
| AUD-03 | `amb_sea.ogg` | Terminal / falésias |
| AUD-04 | `amb_campus.ogg` | Pátio |
| AUD-05 | `amb_party.ogg` | Festa |
| AUD-06 | `sfx_choice.ogg` | Confirmar escolha |
| AUD-07 | `sfx_thread.ogg` | Fio aparece |
| AUD-08 | `sfx_message.ogg` | Celular |
| AUD-09 | `sfx_clue.ogg` | Pista |

Leitmotifs dos interesses: P1, um loop curto cada.

## Atlas

Atlas só para ícones de UI, pins e thumbnails. Retratos, fundos e CGs ficam em arquivos individuais.

## Checklist de aceite da arte

- Retrato alinha no mesmo ponto de âncora em todas as expressões.
- Fundo não corta HUD nem áreas seguras em 16:9 e telas alongadas.
- Fio legível em contraste alto e com ícone (não só cor).
- CG não contém texto embutido (localização).
- Placeholder marcado no nome (`_ph_`) até a arte-alvo.
