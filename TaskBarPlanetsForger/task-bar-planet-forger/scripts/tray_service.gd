extends Node
## Autoload "TrayService": ícone de bandeja nativo (Windows/macOS) via StatusIndicator.
## Clique esquerdo mostra/oculta a janela; clique direito abre o menu de contexto.
## Em plataformas sem suporte (ou dentro do editor embutido), fica inativo sem gerar erros.

const ITEM_TOGGLE := 1
const ITEM_PAUSE := 2
const ITEM_SAVE := 3
const ITEM_QUIT := 4

var _indicator: StatusIndicator
var _menu: PopupMenu

func is_supported() -> bool:
	return DisplayServer.has_feature(DisplayServer.FEATURE_STATUS_INDICATOR) and not Engine.is_embedded_in_editor()

func _ready() -> void:
	if not is_supported():
		return
	_menu = PopupMenu.new()
	_menu.add_item("Mostrar/Ocultar", ITEM_TOGGLE)
	_menu.add_item("Pausar", ITEM_PAUSE)
	_menu.add_separator()
	_menu.add_item("Salvar agora", ITEM_SAVE)
	_menu.add_separator()
	_menu.add_item("Sair", ITEM_QUIT)
	_menu.id_pressed.connect(_on_menu_id_pressed)
	add_child(_menu)

	_indicator = StatusIndicator.new()
	_indicator.icon = load("res://icon.svg") as Texture2D
	_indicator.tooltip = "Taskbar Planets Forger"
	_indicator.pressed.connect(_on_indicator_pressed)
	add_child(_indicator)

	GameState.state_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	if _indicator == null:
		return
	_indicator.visible = GameState.settings.tray_enabled
	if _menu != null:
		_menu.set_item_text(_menu.get_item_index(ITEM_PAUSE), "Retomar" if GameState.paused else "Pausar")

func hide_to_tray() -> void:
	if _indicator:
		_indicator.visible = true
	get_window().hide()

func show_from_tray() -> void:
	get_window().show()
	if get_window().mode == Window.MODE_MINIMIZED:
		get_window().mode = Window.MODE_WINDOWED
	get_window().grab_focus()

func _on_indicator_pressed(mouse_button: int, mouse_position: Vector2i) -> void:
	if mouse_button == MOUSE_BUTTON_LEFT:
		if get_window().visible:
			hide_to_tray()
		else:
			show_from_tray()
	elif mouse_button == MOUSE_BUTTON_RIGHT and _menu != null:
		_menu.popup(Rect2i(mouse_position, Vector2i.ZERO))

func _on_menu_id_pressed(id: int) -> void:
	match id:
		ITEM_TOGGLE:
			if get_window().visible:
				hide_to_tray()
			else:
				show_from_tray()
		ITEM_PAUSE:
			GameState.paused = not GameState.paused
			GameState.state_changed.emit()
		ITEM_SAVE:
			GameState.save_game()
			GameState.notification_sent.emit("Partida salva pela bandeja.")
		ITEM_QUIT:
			GameState.save_game()
			get_tree().quit()
