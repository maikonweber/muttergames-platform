# Emblemas de desafios

O atlas `atlas/challenge_theme_emblems_atlas_v1.png` e os seis sprites em `challenge_emblems/` são usados na seleção de desafios. Cada sprite mede 512 × 512 e preserva transparência real fora do emblema.

| Tema | Card | Fundo de resultado associado |
| --- | --- | --- |
| Diário | `challenge_emblems/challenge_daily_card_v1.png` | `backgrounds/background_daily_01_v1.png` |
| Gala | `challenge_emblems/challenge_gala_card_v1.png` | `backgrounds/background_gala_01_v1.png` |
| Festival | `challenge_emblems/challenge_festival_card_v1.png` | `backgrounds/background_festival_01_v1.png` |
| Fantasia | `challenge_emblems/challenge_fantasy_card_v1.png` | `backgrounds/background_fantasy_01_v1.png` |
| Editorial urbano | `challenge_emblems/challenge_urban_editorial_card_v1.png` | `backgrounds/background_urban_editorial_01_v1.png` |
| Jardim romântico | `challenge_emblems/challenge_romantic_garden_card_v1.png` | `backgrounds/background_romantic_garden_01_v1.png` |

No Godot, importe-os como thumbnails com filtro linear e mantenha a proporção quadrada. Para grades compactas, use o atlas como fonte; para botões grandes ou animação de foco, use os sprites individuais.
