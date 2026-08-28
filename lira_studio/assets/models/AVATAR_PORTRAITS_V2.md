# Avatar portraits v2

Revisão visual dos retratos exibidos no estúdio.

- `model_01` a `model_04`: `base/*_face_base_v2.png`
- `model_01` a `model_04`: `thumbnails/*_thumb_v2.png`
- As miniaturas são recortes da respectiva base v2, portanto a foto de perfil
  e a personagem selecionada permanecem consistentes.
- Pixels de vazamento azul/ciano com transparência parcial foram removidos nas
  bordas, evitando contorno colorido contra os fundos do jogo.

Validação local:

```powershell
./tools/verify_avatar_portraits_v2.ps1
```
