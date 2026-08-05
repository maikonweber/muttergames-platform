class_name GameSettings
extends RefCounted

## Âncoras válidas para posicionamento junto às bordas da tela (perto da barra de tarefas
## sem depender de detectar sua posição exata — ver docs/desktop-window-behavior.md).
const ANCHORS := ["bottom_right", "bottom_left", "top_right", "top_left", "none"]

var notifications_enabled := true
var always_on_top := true # Padrão: a barra idle deve continuar visível junto à tela.
var window_opacity := 1.0
var update_rate := 1.0
var background_efficiency := 0.25
var close_minimizes := true
var accessibility_large_text := false

# Posicionamento junto à barra de tarefas (preferência do jogador, não suposição de OS).
var monitor_index := -1 # -1 = monitor atual da janela.
var anchor := "bottom_right" # "none" preserva a posição escolhida manualmente pelo jogador.
var margin := Vector2i(16, 16)

# Bandeja do Windows e comportamento de clique através.
var tray_enabled := true
var click_through := false

# Áudio.
var master_volume := 0.8
var sfx_enabled := true

# Notificações nativas do sistema operacional (fora da janela do jogo). Experimental:
# depende de shell externo (PowerShell) e só é usado além das notificações internas.
var native_notifications := false

func apply_to_window(window: Window) -> void:
	window.always_on_top = always_on_top
	var real_transparency := window_opacity < 0.99
	window.transparent = real_transparency
	window.transparent_bg = real_transparency
	window.mouse_passthrough = click_through
	reposition(window)

## Reaplica a âncora escolhida em relação à área utilizável do monitor (exclui a barra de
## tarefas via DisplayServer.screen_get_usable_rect). Chamado após mudanças de tamanho/âncora.
func reposition(window: Window) -> void:
	if anchor == "none":
		return
	var screen := monitor_index
	if screen < 0 or screen >= DisplayServer.get_screen_count():
		screen = window.current_screen
	var usable := DisplayServer.screen_get_usable_rect(screen)
	var size := window.size
	var pos := usable.position
	match anchor:
		"top_left":
			pos = usable.position + margin
		"top_right":
			pos = Vector2i(usable.position.x + usable.size.x - size.x - margin.x, usable.position.y + margin.y)
		"bottom_left":
			pos = Vector2i(usable.position.x + margin.x, usable.position.y + usable.size.y - size.y - margin.y)
		"bottom_right":
			pos = Vector2i(usable.position.x + usable.size.x - size.x - margin.x, usable.position.y + usable.size.y - size.y - margin.y)
	window.position = pos

func serialize() -> Dictionary:
	return {
		"notifications_enabled": notifications_enabled, "always_on_top": always_on_top,
		"window_opacity": window_opacity, "update_rate": update_rate,
		"background_efficiency": background_efficiency, "close_minimizes": close_minimizes,
		"accessibility_large_text": accessibility_large_text,
		"monitor_index": monitor_index, "anchor": anchor, "margin": [margin.x, margin.y],
		"tray_enabled": tray_enabled, "click_through": click_through,
		"master_volume": master_volume, "sfx_enabled": sfx_enabled,
		"native_notifications": native_notifications,
	}

func deserialize(data: Dictionary) -> void:
	notifications_enabled = bool(data.get("notifications_enabled", notifications_enabled))
	always_on_top = bool(data.get("always_on_top", always_on_top))
	window_opacity = clampf(float(data.get("window_opacity", window_opacity)), 0.45, 1.0)
	update_rate = clampf(float(data.get("update_rate", update_rate)), 0.25, 2.0)
	background_efficiency = clampf(float(data.get("background_efficiency", background_efficiency)), 0.05, 1.0)
	close_minimizes = bool(data.get("close_minimizes", close_minimizes))
	accessibility_large_text = bool(data.get("accessibility_large_text", accessibility_large_text))
	monitor_index = int(data.get("monitor_index", monitor_index))
	var raw_anchor := str(data.get("anchor", anchor))
	anchor = raw_anchor if raw_anchor in ANCHORS else "bottom_right"
	var margin_data: Array = data.get("margin", [margin.x, margin.y]) as Array
	if margin_data.size() == 2:
		margin = Vector2i(int(margin_data[0]), int(margin_data[1]))
	tray_enabled = bool(data.get("tray_enabled", tray_enabled))
	click_through = bool(data.get("click_through", click_through))
	master_volume = clampf(float(data.get("master_volume", master_volume)), 0.0, 1.0)
	sfx_enabled = bool(data.get("sfx_enabled", sfx_enabled))
	native_notifications = bool(data.get("native_notifications", native_notifications))
