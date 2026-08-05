extends Node
## Simple one-shot SFX player for combat / UI.

var _players: Array[AudioStreamPlayer] = []
const POOL := 6


func _ready() -> void:
	for i in POOL:
		var p := AudioStreamPlayer.new()
		p.bus = "Master"
		add_child(p)
		_players.append(p)


func play_sfx(path: String, volume_db: float = -4.0) -> void:
	if not ResourceLoader.exists(path):
		return
	var stream := load(path)
	if stream == null:
		return
	for p in _players:
		if not p.playing:
			p.stream = stream
			p.volume_db = volume_db
			p.play()
			return
	# steal first
	_players[0].stream = stream
	_players[0].volume_db = volume_db
	_players[0].play()


func slash() -> void:
	play_sfx("res://assets/audio/sfx/slash_hit.wav", -6.0)


func hit() -> void:
	play_sfx("res://assets/audio/sfx/hit.wav", -5.0)


func block() -> void:
	play_sfx("res://assets/audio/sfx/block.wav", -4.0)


func parry() -> void:
	play_sfx("res://assets/audio/sfx/parry.wav", -3.0)


func death() -> void:
	play_sfx("res://assets/audio/sfx/death.wav", -4.0)


func card() -> void:
	play_sfx("res://assets/audio/sfx/card_play.wav", -8.0)


func ui_click() -> void:
	play_sfx("res://assets/audio/sfx/ui_click.wav", -10.0)


func reward() -> void:
	play_sfx("res://assets/audio/sfx/reward.wav", -5.0)
