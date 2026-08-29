# Mapa de locais

Doze cenários no MVP. O mapa do jogo mostra locais disponíveis no episódio atual, quem está presente e o objetivo. Sem custo de deslocamento no MVP.

Dados: [`../data/locations/locations.json`](../data/locations/locations.json).

## Grafo

```text
                    [Falésias / mar]
                           |
 [Terminal] ---- [Pátio Aurora] ---- [Secretaria]
                      |    \
                      |     [Biblioteca] ---- [Laboratório Nexo]
                      |
              [Dormitórios] ---- [Quarto da protagonista]
                      |              |
                      |           [Dormitório da Bia]
                      |
              [Corredor antigo] ---- [Laboratório fotográfico]
                      |
              [Salão / Festa]      [Sala de ensaio]
                      |
                 [Café Farol]
```

Locais pontilhados (Observatório, Reitoria, Túneis) existem na T1 completa, não no mapa jogável do MVP.

## Catálogo

| ID | Nome | Episódios | Tags | Quem costuma estar | Ambiência |
| --- | --- | --- | --- | --- | --- |
| `loc_terminal` | Terminal de Miralume | 1 | `arrival`, `sea`, `public` | — (abertura) | `amb_sea` |
| `loc_patio` | Pátio Aurora | 1–3 | `campus`, `day`, `hub` | qualquer interesse | `amb_campus` |
| `loc_secretaria` | Secretaria | 1 | `admin`, `indoor` | Helena (passagem) | indoor suave |
| `loc_dorm_bia` | Dormitório (Bia) | 1–3 | `private`, `safe` | Bia | indoor íntimo |
| `loc_festa` | Festa de recepção | 1 | `night`, `social`, `once` | todos os interesses | `amb_party` |
| `loc_corredor_old` | Corredor antigo | 1–2 | `mystery`, `indoor` | Luna, Caio | drones graves |
| `loc_quarto` | Quarto da protagonista | 1–3 | `private`, `phone`, `hub` | Bia (visita) | noite quieta |
| `loc_lab_foto` | Laboratório fotográfico | 2 | `mystery`, `hidden` | Luna | químico, gotas |
| `loc_cafe` | Café Farol | 1–3 | `town`, `social`, `lore` | Marta, Caio | xícaras, mar distante |
| `loc_lab_nexo` | Laboratório de Noah | 3 | `tech`, `restricted` | Noah | fans, UI beeps |
| `loc_biblioteca` | Biblioteca Aurora | 2–3 | `campus`, `quiet` | Gael, Dante | páginas |
| `loc_ensaio` | Sala de ensaio | 1–3 | `music`, `private` | Theo | guitarra, amp |

## Regras do mapa

- Objetivo do episódio sempre visível.
- Personagens presentes são um subconjunto derivado de flags + hora fictícia do capítulo, não de RNG.
- Locais `once` (festa) saem do mapa depois da cena obrigatória.
- Visitar um local opcional pode disparar no máximo um [evento aleatório](07-eventos-aleatorios.md).
- Locais de cena obrigatória do episódio ignoram a tabela aleatória.

## Hubs

| Hub | Função |
| --- | --- |
| Pátio | Escolha de quem abordar no meio do episódio |
| Quarto | Celular, recap, guarda-roupa, fim de capítulo |
| Café Farol | Lore de Miralume e Marta; eventos de flavor |

## Fora do MVP (T1)

Reitoria, Observatório Aurora, túneis sob as falésias, residência da reitora, estúdio de rádio do campus. Reservar IDs (`loc_reitoria`, `loc_observatorio`, `loc_tuneis`) para não colidir depois.
