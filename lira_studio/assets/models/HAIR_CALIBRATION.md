# Calibração dos sprites de cabelo

## Entrega atual

Cada modelo possui um `model_XX_hair_full_v1.png` em canvas de 1024 × 1536, com canal alfa, além de `model_XX_hair_back_v1.png` e `model_XX_hair_front_v1.png`. Os dois planos são uma partição não sobreposta do cabelo completo: compostos juntos, recompõem exatamente o `hair_full`.

## Uso no protótipo

1. Importe o rosto-base, `hair_back` e `hair_front` sem redimensionamento independente.
2. Posicione ambos na mesma origem do canvas.
3. Renderize `hair_back` atrás do rosto-base e `hair_front` acima dos overlays de maquiagem.
4. Teste sobre fundos claros e escuros para localizar halo ou resíduo de chroma.
5. Registre qualquer correção de posição por modelo; não compartilhe offsets entre modelos.

## Conversão para produção

- Revisar manualmente a fronteira entre `model_XX_hair_back_v1.png` e `model_XX_hair_front_v1.png`, principalmente franja e têmporas.
- Manter ambos no canvas de 1024 × 1536 e na mesma origem do rosto-base.
- `hair_back` deve conter as massas atrás do rosto e dos ombros.
- `hair_front` deve conter franja, fios sobre a testa, têmporas e mechas que cruzam o rosto.
- Limpar resíduos verdes nas bordas e revisar fios semitransparentes em zoom de 200%.
- Não substituir `hair_full_v1`; publicar correções com novo sufixo de versão.

## Critérios de aceite

- Fundo e vazio facial têm alfa zero.
- Cabelo interno tem alfa completo, exceto fios naturalmente semitransparentes.
- Nenhuma área de pele, olho, orelha, pescoço ou roupa permanece no sprite.
- A composição não cria linha de corte visível junto à testa ou às orelhas.
- Os arquivos `hair_back` e `hair_front` recompõem visualmente o `hair_full` quando sobrepostos.
