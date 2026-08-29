# Eventos aleatórios

Entre marcos obrigatórios, uma visita opcional ao mapa pode disparar **no máximo um** evento. Eventos dão textura de campus, micro-relação e eco do mistério. Não avançam o caso e não substituem cenas de episódio.

Dados: [`../data/events/campus-day.json`](../data/events/campus-day.json).

## Quando roda

`RandomEventSystem.pick(location_id)` só se:

- o local não está marcado `story_locked` nesta visita;
- o episódio atual está em `event.episodes`;
- todas as `conditions` passam;
- o evento não está em cooldown nem marcado `once` e já visto;
- após filtrar, a escolha é ponderada por `weight` com RNG derivado de `rng_seed + day_index + location_id`.

Se a lista filtrada é vazia, a visita não tem evento (silêncio é válido).

## Pools

| Pool | Função | Pode mudar |
| --- | --- | --- |
| `flavor` | Vida no campus | nada ou coragem 0 |
| `social` | Micro encontro | afinidade ±1 a ±3 |
| `thread` | Ver fios entre NPCs | flag de lore `saw_thread_*` |
| `clue_echo` | Lembra o mistério | nunca evidência nova única |
| `phone` | Notificação opcional | abre nó curto se a jogadora abrir o app |
| `wardrobe` | Comentário de estilo | só se `wardrobe_tag` combinado |

## Denylist de efeitos

O picker **rejeita** (e o teste S5 falha a fixture) qualquer evento cujo efeito:

- seta flag `ep0*_crit_*`, `ep01_viu_foto_iris`, `ep01_ally_*`, `ending_*`, `route_lock_*`;
- concede evidência da tabela canônica (`ev_colar_iris`, `ev_iris_foto_recente`, `ev_nexo_predicao`, …);
- aplica `|delta| > 5` em afinidade ou confiança;
- muda `courage` em mais de 1;
- tranca rota.

## Cooldown e unicidade

- `once: true` — uma vez por save.
- `cooldown_days`: visitas de mapa (não tempo real).
- `repeatable` default true se não `once`.

## Tabela (MVP)

| ID | Pool | Locais | Peso | Condição | Resumo |
| --- | --- | --- | --- | --- | --- |
| `evt_gatos_patio` | flavor | pátio | 8 | — | Gatos no muro da reitoria. |
| `evt_chuva_cafe` | flavor | café | 6 | — | Marta cobre a mesa da janela. |
| `evt_cartaz_iris` | clue_echo | pátio, biblioteca | 3 | not `evt_cartaz_iris` once | Cartaz desbotado “desaparecida”. Sem nova pista. |
| `evt_theo_hum` | social | ensaio, pátio | 5 | not festa locked | Theo canta baixo; escolha: parar ou passar. |
| `evt_gael_fila` | social | secretaria, biblioteca | 4 | — | Gael organiza uma fila; escolha: ajudar / ir embora. |
| `evt_noah_cafeina` | social | café, lab_nexo | 4 | EP ≥ 1 | Noah pede para guardar o notebook. |
| `evt_luna_lente` | social | corredor, lab_foto | 4 | — | Luna pede um segundo para o foco. |
| `evt_bia_snack` | social | dorm_bia, quarto | 6 | `ep01_confided_bia` | Bia deixou comida na mesa. |
| `evt_fio_azul_casal` | thread | pátio | 3 | `ep01_saw_red_thread` | Dois desconhecidos com fio azul. |
| `evt_fio_cinza_helena` | thread | secretaria | 2 | EP ≥ 2 | Helena e um professor: fio cinza. Sem nome na pista. |
| `evt_caio_gravador` | social | café, pátio | 3 | — | Caio entrevista alguém; pode desviar. |
| `evt_marta_lenda` | flavor | café | 4 | once | Marta: “Tecelã que corta o próprio fio”. Lore. |
| `evt_msg_bia` | phone | quarto | 5 | — | Figurinha inútil; +1 afinidade Bia se responder. |
| `evt_roupa_festa` | wardrobe | pátio | 3 | tag `bold` ou `formal` | Comentário de NPC genérico. |
| `evt_dante_aviso` | flavor | biblioteca | 3 | EP ≥ 2 | Dante recomenda um livro sobre folclore costeiro. Sem romance. |
| `evt_wifi_nexo` | clue_echo | lab_nexo, biblioteca | 2 | EP03 | Tela de login do Nexo sem dados novos. |
| `evt_mar_terminal` | flavor | terminal | 5 | — | Cheiro de maresia; texto só. |
| `evt_ensaio_porta` | social | ensaio | 3 | `ep01_festa_theo` | Porta entreaberta; respeito ou escuta. |
| `evt_biblioteca_silencio` | flavor | biblioteca | 7 | — | Alguém ri e leva bronca. |
| `evt_lanterna_quebrada` | flavor | corredor_old | 4 | — | Lâmpada pisca; tensão, 0 evidência. |
| `evt_fio_dourado_eco` | thread | corredor_old | 1 | EP ≥ 3, once | Eco dourado no vidro. Flag `saw_gold_echo` (lore). |
| `evt_helena_discurso` | flavor | pátio | 2 | EP ≥ 2 | Alto-falante: “Aurora protege os seus”. |
| `evt_caio_rival` | social | pátio | 3 | aliado ≠ Caio | Caio insinua que o aliado mente. −1 confiança se concordar sem prova. |

## Implementação

```gdscript
# conceito
func pick(location_id: String) -> String:
    if GameState.story_locked:
        return ""
    var eligible := filter(events, location_id)
    if eligible.is_empty():
        return ""
    var rng := rng_from(GameState.rng_seed, GameState.day_index, location_id)
    return weighted(eligible, rng)
```

Após o evento, se for `phone`, só aplica efeito social se a jogadora abrir a thread. Fechar o celular conta como recusa (sem delta).
