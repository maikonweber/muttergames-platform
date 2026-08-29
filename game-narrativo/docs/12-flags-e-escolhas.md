# Flags e escolhas

Fonte única das flags do MVP. IDs estáveis; texto pode mudar.

## Convenções

- Flags booleanas: `snake_case`, prefixo de episódio se nascerem nele.
- Críticas: `ep01_crit_*` — só nós de cena obrigatória.
- Relacionais: `rel_*` ou implícitas nos inteiros de afinidade/confiança.
- Nunca derivar flag do texto da escolha.

## Perfil da protagonista

| Flag / campo | Tipo | Quando | Efeito |
| --- | --- | --- | --- |
| `player_name` | string | Início | Tokens |
| `pronouns` | enum | Início | Tokens |
| `course` | `letters` / `sciences` / `arts` | Início | Diálogo cosmético |
| `profile_empathy` | int (oculto) | Escolhas de personalidade | Voz; não é um stat visível |
| `profile_reason` | int | idem | |
| `profile_daring` | int | idem | |
| `wardrobe_tag` | `casual` / `formal` / `creative` / `bold` | SC04 e guarda-roupa | Cenas reagem |

Tendência = maior dos três perfis; empate = última escolha.

## EP01

| Flag | Origem | Permanente? | Uso |
| --- | --- | --- | --- |
| `ep01_posture_open` | SC01 C01 | episódio | Variação de voz |
| `ep01_posture_guarded` | SC01 C02 | episódio | |
| `ep01_posture_defiant` | SC01 C03 | episódio | +1 coragem |
| `ep01_helped_theo` | SC02 ajudar | sim | Diálogo Theo |
| `ep01_confronted_theo` | SC02 confrontar | sim | |
| `ep01_played_theo` | SC02 brincar | sim | |
| `ep01_saw_red_thread` | SC02 automático | sim | Tutorial de fios |
| `ep01_questioned_grant` | SC03 questionar | sim | Pista `ev_bolsa_inconsistente` |
| `ep01_watched_grant` | SC03 silêncio | sim | |
| `ep01_confided_bia` | SC04 | sim | Bia como âncora |
| `ep01_festa_theo` | SC05 | sim | Diamante |
| `ep01_festa_gael` | SC05 | sim | |
| `ep01_festa_noah` | SC05 | sim | |
| `ep01_festa_luna` | SC05 | sim | |
| `ep01_viu_foto_iris` | SC06 automático | **crítica** | Pista `ev_colar_iris` |
| `ep01_showed_photo` | SC06 mostrar | crítica | Confiança no alvo |
| `ep01_hid_photo` | SC06 esconder | sim | Caio/Luna reagem no EP02 |
| `ep01_replied_threat` | SC07 | crítica | |
| `ep01_blocked_number` | SC07 | crítica | |
| `ep01_traced_number` | SC07 | crítica | +1 coragem se investigar |
| `ep01_ally_theo` | encerramento | sim | EP02 abre com Theo |
| `ep01_ally_gael` | | sim | |
| `ep01_ally_noah` | | sim | |
| `ep01_ally_luna` | | sim | |
| `ep01_ally_bia` | fallback se ninguém | sim | |

Uma só flag `ep01_festa_*` e uma só `ep01_ally_*`.

## Pistas (evidências)

| ID | Origem | Combinações válidas |
| --- | --- | --- |
| `ev_colar_protagonista` | início (inventário) | com `ev_colar_iris` → hipótese `hyp_colares_iguais` |
| `ev_bolsa_inconsistente` | SC03 se questionar; senão no recap do EP02 | com nome da mãe (T1) |
| `ev_colar_iris` | SC06 | ver acima |
| `ev_msg_ameaca` | SC07 | com `ev_colar_iris` → `hyp_alguem_sabe` |
| `ev_iris_foto_recente` | EP02 | T1 |
| `ev_nexo_predicao` | EP03 | T1 |

Combinação errada: gasta uma tentativa na cena, pode −2 confiança do aliado presente, nunca remove evidência.

## Encerramento do EP01 — aliado

| Escolha SC07 + contexto | Aliado |
| --- | --- |
| Investigar o número e festa com X | X |
| Mostrar a foto para X na SC06 | tendência a X |
| Confidente Bia + nenhuma rota forte | Bia |
| Empate | personagem da festa |

Confiança +8 ao aliado. Afinidade +4. Romances permanecem abertos.

## O que eventos aleatórios não podem setar

Qualquer `ep01_crit_*`, `ep01_viu_foto_iris`, `ep01_ally_*`, `ending_*`, `route_lock_*`, evidências da tabela acima. Ver [07-eventos-aleatorios.md](07-eventos-aleatorios.md).
