# Assets gerados — TaskBar Planets Forger

Este diretório contém os primeiros assets raster gerados para o MVP.

| Arquivo | Tipo | Uso |
|---|---|---|
| `planet-oceanic-01-chromakey.png` | Planeta oceânico com lua | Prévia de planeta, orbita e inspetor |
| `vfx-forge-burst-01-chromakey.png` | Explosão cósmica ciano/dourada | Efeito de forja de planeta |

Os PNGs usam fundo magenta (`#FF00FF`) para preservar arestas luminosas. O shader `res://shaders/chroma_key.gdshader` converte essa cor em transparência durante a renderização. O efeito pronto está em `res://scenes/forge_burst.tscn` e pode ser instanciado e acionado com `play_burst(posicao)`.

Não reexporte ou substitua esses arquivos sem manter a referência de seed/prompt no documento de design system.
