extends Control
## Main launcher / title screen for Fallen Tactics.


@onready var title: Label = $Root/Center/VBox/Title
@onready var subtitle: Label = $Root/Center/VBox/Subtitle
@onready var status: Label = $Root/Center/VBox/Status
@onready var play_btn: Button = $Root/Center/VBox/PlayBtn
@onready var combat_btn: Button = $Root/Center/VBox/CombatBtn
@onready var pvp_btn: Button = $Root/Center/VBox/PvpBtn
@onready var quit_btn: Button = $Root/Center/VBox/QuitBtn


func _ready() -> void:
	play_btn.pressed.connect(_on_play)
	combat_btn.pressed.connect(_on_combat_debug)
	pvp_btn.pressed.connect(_on_pvp)
	quit_btn.pressed.connect(func(): get_tree().quit())
	MultiplayerSession.status_changed.connect(func(t): status.text = t)
	title.text = "FALLEN TACTICS"
	subtitle.text = "RPG tático · deckbuilder · Região Caída"
	status.text = "v%s  ·  Godot 4.7" % _read_version()
	_pulse_title()


func _read_version() -> String:
	## Optional VERSION file from monorepo root is not in res://; hardcode for now.
	return "0.1.0"


func _pulse_title() -> void:
	var tw := create_tween().set_loops()
	tw.tween_property(title, "modulate", Color(1.0, 0.92, 0.75, 1.0), 1.4)
	tw.tween_property(title, "modulate", Color(0.85, 0.9, 1.0, 1.0), 1.4)


func _on_play() -> void:
	status.text = "Iniciando nova run..."
	GameState.start_new_run()
	get_tree().change_scene_to_file(GameState.ZONE_SCENE)


func _on_combat_debug() -> void:
	status.text = "Abrindo combate direto (debug)..."
	GameState.start_new_run()
	GameState.return_to_zone = false
	GameState.combat_setup.clear()
	get_tree().change_scene_to_file(GameState.COMBAT_SCENE)


func _on_pvp() -> void:
	status.text = "Abrindo lobby PVP na região..."
	if not GameState.run_active:
		GameState.start_new_run()
	get_tree().change_scene_to_file(GameState.ZONE_SCENE)
