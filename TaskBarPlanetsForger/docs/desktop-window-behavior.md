# Comportamento da janela desktop

## Modos

- **Compacto (barra idle):** faixa pequena (480×104), **sem bordas do SO**
  (`Window.borderless = true`) para parecer um widget grudado à tela em vez de uma janela de
  aplicativo — é o padrão logo na primeira execução e persiste entre sessões
  (`GameState.compact_mode`, salvo no arquivo de save). Mostra só recursos e os botões
  essenciais (pausar/expandir). Sem barra de título, a janela é arrastada clicando e
  arrastando o próprio cabeçalho (`main.gd:_on_header_gui_input`); ao soltar o mouse a
  âncora muda para "manual" (`anchor = "none"`) para não saltar de volta ao canto
  configurado.
- **Expandido:** janela normal (bordas, redimensionável, 1000×600) com painel de órbitas,
  construção, eventos e configuração. Se um evento cósmico ocorrer enquanto o jogo está no
  modo compacto, a janela expande temporariamente para exibir as escolhas e volta ao modo
  compacto assim que o jogador decide (`main.gd:show_event`), já que a barra idle é pequena
  demais para o conteúdo do evento.

Alternar entre os dois modos sempre passa por `GameState.set_compact_mode()`, único ponto que
redimensiona a janela, reaplica bordas e reancora — evita os dois ficarem fora de sincronia.

## Posicionamento

O jogador escolhe monitor e âncora (superior/inferior, esquerda/direita, ou nenhuma para
posição manual), com uma margem fixa em relação à borda. A posição é calculada a partir de
`DisplayServer.screen_get_usable_rect()`, que já exclui a barra de tarefas do Windows (e
áreas equivalentes em outros sistemas), então a janela nunca fica coberta por ela — sem
precisar detectar sua posição exata, como definido na ADR-004. A reancoragem acontece sempre
que o tamanho da janela muda (ex.: alternar modo compacto), a preferência é alterada, ou o
jogador arrasta a barra manualmente (que muda a âncora para "nenhuma"). Por padrão, a barra
idle também fica **sempre no topo** (`always_on_top = true`) para não ser coberta por outras
janelas — o objetivo de ficar "grudada" à tela perde sentido se outro app a esconde.

Como a posição só é recalculada quando algo muda (tamanho/âncora/preferência), e a janela do
SO pode ainda não estar totalmente mapeada no primeiro frame em algumas plataformas,
`GameState._ready()` reaplica as configurações uma segunda vez após aguardar
`get_tree().process_frame`, tornando o ancoramento inicial mais confiável.

Opacidade, sempre no topo e clique através também são preferências do jogador:

- **Opacidade/transparência real**: além de esmaecer a interface, a janela usa
  `display/window/per_pixel_transparency/allowed` para permitir transparência real do SO
  quando a opacidade é reduzida.
- **Clique através** usa `Window.mouse_passthrough`. É best-effort: essa API do Godot só
  garante repasse confiável de cliques entre janelas da própria aplicação; não substitui um
  clique através real para o desktop/outras janelas, que exigiria uma extensão nativa
  (GDExtension com `WS_EX_LAYERED`/`WS_EX_TRANSPARENT` no Windows) fora do escopo atual.

Em tela cheia, jogo/vídeo ou economia de bateria, a aplicação reduz atualização (via
`background_efficiency`) quando a janela perde o foco; ocultar automaticamente nesses casos
segue como próximo passo (hoje depende de o jogador minimizar/ocultar manualmente ou usar a
bandeja).

## Bandeja do Windows

Implementada com o nó `StatusIndicator` do Godot (`scripts/tray_service.gd`, autoload
`TrayService`), suportado nativamente no Windows e macOS. Clique esquerdo no ícone
mostra/oculta a janela; clique direito abre um menu (mostrar/ocultar, pausar/retomar, salvar
agora, sair). Quando a bandeja está habilitada e é suportada, fechar a janela pela barra de
título esconde para a bandeja em vez de encerrar; a opção "fechar minimiza" antiga continua
disponível como alternativa quando a bandeja está desabilitada, e sair de fato sempre salva
antes. Em plataformas sem suporte a `StatusIndicator` (ex.: Linux) ou dentro do editor
embutido, o serviço fica inativo sem gerar erro.

## Áudio e notificações

Efeitos sonoros curtos são gerados por procedimento em tempo real (sem assets binários) pelo
autoload `AudioService`, reagindo a ações, eventos, prestígio e falhas. Notificações
internas continuam aparecendo na faixa principal; opcionalmente (desligado por padrão), o
autoload `NotificationService` também dispara uma notificação nativa do Windows via
PowerShell/`NotifyIcon` quando a janela está sem foco — ver limitações no README do projeto.

Atalhos: alternar modo, pausar e mostrar/ocultar. A bandeja permite restaurar e encerrar;
encerrar sempre salva antes.
