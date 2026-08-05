# Taskbar Planets Forger — Godot MVP

Protótipo funcional em **Godot 4.7** de um jogo idle desktop: forje asteroides e planetas, terraform e desenvolva vida/civilizações enquanto o sistema produz recursos.

## Como abrir

1. Abra `project.godot` no Godot 4.7 ou superior.
2. Execute a cena principal (`F6`/`F5`).

## Fluxo de jogo

1. Crie dois asteroides usando Matéria e forje um planeta numa órbita vazia.
2. Capture água com Energia e use-a para terraformar o planeta até que fique habitável.
3. Inicie vida; ela produz Biomassa. Converta Biomassa/Energia em Conhecimento por meio de pesquisa e evolua a civilização.
5. Complete as três órbitas e execute a Supernova para obter Essência permanente.

## Recursos implementados

- Produção contínua e pausa.
- Inventário com capacidades e custos sem saldo negativo.
- Três órbitas, asteroides, forja de planetas, terraformação, vida e civilização.
- Eventos cósmicos com escolhas e efeitos.
- Progresso offline limitado a oito horas.
- Salvamento JSON local (`user://`) com backup.
- **Interface idle (barra compacta) e modo expandido:** por padrão o jogo abre como uma
  barra pequena (480×104) **sem bordas do SO**, sempre no topo, grudada a um canto da tela —
  arrastável clicando no cabeçalho (a âncora vira "manual" ao soltar). O modo expandido
  (1000×600, com bordas) dá acesso a órbitas, construção, eventos e configurações; eventos
  cósmicos expandem a janela automaticamente e voltam ao modo compacto depois da escolha.
- Tutorial não bloqueante, acessibilidade (texto ampliado) e configurações persistidas
  (incluindo o modo compacto/expandido, que é lembrado entre sessões).
- **Janela desktop:** monitor e âncora configuráveis (superior/inferior, esquerda/direita),
  posicionada dentro da área utilizável da tela (fora da barra de tarefas, via
  `DisplayServer.screen_get_usable_rect`), sempre no topo por padrão, opacidade/transparência
  real e clique através best-effort (ver limitações abaixo).
- **Bandeja do Windows:** ícone nativo (`StatusIndicator`) com clique esquerdo para
  mostrar/ocultar e menu de contexto (pausar, salvar, sair); fechar a janela minimiza para a
  bandeja quando habilitado, em vez de encerrar o jogo.
- **Áudio:** efeitos sonoros curtos gerados por procedimento (sem assets binários) para
  ações, eventos, prestígio e erros, com volume e ativar/desativar nas configurações.
- **Notificações nativas do Windows (experimental, desativado por padrão):** toast via
  `NotifyIcon` do PowerShell quando a janela está sem foco, além da notificação interna.

## Organização

- `scripts/game_state.gd`: ciclo de simulação e casos de uso do jogo.
- `scripts/resource_inventory.gd`, `planet.gd` e `game_event.gd`: modelo de domínio.
- `scripts/game_settings.gd`: preferências persistidas, incluindo posicionamento de janela.
- `scripts/save_service.gd`: persistência local.
- `scripts/audio_service.gd`: pool de `AudioStreamPlayer` e sons procedurais (autoload `AudioService`).
- `scripts/tray_service.gd`: ícone de bandeja do Windows/macOS (autoload `TrayService`).
- `scripts/notification_service.gd`: notificação nativa opcional via PowerShell (autoload `NotificationService`).
- `scripts/main.gd` e `scenes/main.tscn`: interface, incluindo o painel de configurações.

## Limitações conhecidas (ver `docs/desktop-window-behavior.md`)

- **Bandeja** (`StatusIndicator`) só é suportada no Windows e macOS pelo próprio Godot; em
  outras plataformas ou dentro do editor embutido, o recurso fica inativo sem gerar erro.
- **Clique através** usa a propriedade `Window.mouse_passthrough` documentada pelo Godot, que
  só é confiável entre janelas da mesma aplicação — não substitui um clique através real para
  o desktop (isso exigiria um GDExtension nativo com `WS_EX_LAYERED`/`WS_EX_TRANSPARENT`, fora
  do escopo deste incremento).
- **Notificações nativas** dependem de invocar `powershell.exe` (via `OS.create_process`, sem
  bloquear o jogo) para exibir um balão do `System.Windows.Forms.NotifyIcon`; por isso ficam
  desligadas por padrão e exigem PowerShell disponível no sistema.

Este é o MVP jogável com o primeiro incremento de integrações nativas. Acessibilidade
avançada adicional e validação em múltiplos monitores/gerenciadores de janela seguem como
próximos passos.
