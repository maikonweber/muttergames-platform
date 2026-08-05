extends Node
## Autoload "NotificationService": além da notificação interna já exibida na faixa
## principal (GameState.notification_sent), pode opcionalmente emitir uma notificação
## nativa do Windows (experimental) quando a janela não está em foco.
##
## É opt-in (GameSettings.native_notifications = false por padrão) porque depende de
## invocar um processo PowerShell externo — evita depender de plugins nativos/GDExtension
## apenas para isso, ao custo de ser best-effort e específico do Windows.

const APP_TITLE := "Taskbar Planets Forger"
const BALLOON_TIMEOUT_MS := 6000

func _ready() -> void:
	GameState.notification_sent.connect(func(message: String) -> void: _maybe_notify(APP_TITLE, message))
	GameState.event_started.connect(func(event: CosmicEvent) -> void: _maybe_notify(event.title, event.description))

func _maybe_notify(title: String, message: String) -> void:
	if not GameState.settings.notifications_enabled or not GameState.settings.native_notifications:
		return
	if OS.get_name() != "Windows":
		return
	if DisplayServer.window_is_focused():
		return # Evita ruído quando o jogador já está olhando para a janela.
	_send_windows_toast(title, message)

## Usa System.Windows.Forms.NotifyIcon via PowerShell (sempre disponível no Windows,
## sem exigir módulos extras). Roda em processo independente (OS.create_process) para
## não bloquear o jogo enquanto o balão fica visível.
func _send_windows_toast(title: String, message: String) -> void:
	var script := (
		"Add-Type -AssemblyName System.Windows.Forms,System.Drawing;" +
		"$ni = New-Object System.Windows.Forms.NotifyIcon;" +
		"$ni.Icon = [System.Drawing.SystemIcons]::Information;" +
		"$ni.Visible = $true;" +
		"$ni.BalloonTipTitle = '{title}';" +
		"$ni.BalloonTipText = '{message}';" +
		"$ni.ShowBalloonTip({timeout});" +
		"Start-Sleep -Milliseconds {sleep};" +
		"$ni.Dispose();"
	).format({
		"title": title.replace("'", "''"),
		"message": message.replace("'", "''"),
		"timeout": BALLOON_TIMEOUT_MS,
		"sleep": BALLOON_TIMEOUT_MS + 500,
	})
	OS.create_process("powershell.exe", ["-NoProfile", "-NonInteractive", "-WindowStyle", "Hidden", "-Sta", "-Command", script])
