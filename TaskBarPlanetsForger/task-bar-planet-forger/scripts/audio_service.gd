extends Node
## Autoload "AudioService": efeitos sonoros curtos gerados por procedimento (sem
## dependência de assets binários externos), para reagir a eventos do jogo.
## Respeita GameState.settings.sfx_enabled e master_volume.

const MIX_RATE := 22050
const POOL_SIZE := 4

var _players: Array[AudioStreamPlayer] = []
var _next_player := 0
var _cache: Dictionary = {}

func _ready() -> void:
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_players.append(player)
	GameState.sfx_requested.connect(play)

func play(sfx_name: String) -> void:
	if not GameState.settings.sfx_enabled:
		return
	var cached: Variant = _cache.get(sfx_name)
	var stream: AudioStreamWAV = cached as AudioStreamWAV
	if stream == null:
		stream = _build(sfx_name)
		if stream == null:
			return
		_cache[sfx_name] = stream
	var player: AudioStreamPlayer = _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	player.stream = stream
	player.volume_db = linear_to_db(clampf(GameState.settings.master_volume, 0.0, 1.0))
	player.play()

func _build(sfx_name: String) -> AudioStreamWAV:
	match sfx_name:
		"success":
			return _melody([[520.0, 0.09]])
		"chime":
			return _melody([[660.0, 0.08], [880.0, 0.12]])
		"event":
			return _melody([[440.0, 0.09], [330.0, 0.09], [440.0, 0.12]])
		"prestige":
			return _melody([[440.0, 0.1], [554.0, 0.1], [659.0, 0.1], [880.0, 0.22]])
		"error":
			return _melody([[180.0, 0.16]], "square")
		_:
			return null

## Concatena tons puros (senoidal por padrão) com um leve envelope para evitar cliques.
func _melody(notes: Array, wave: String = "sine") -> AudioStreamWAV:
	var bytes := PackedByteArray()
	for note in notes:
		bytes.append_array(_tone_bytes(float(note[0]), float(note[1]), wave))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = bytes
	return stream

func _tone_bytes(freq: float, duration: float, wave: String) -> PackedByteArray:
	var frame_count := int(MIX_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(frame_count * 2)
	var attack := mini(frame_count / 6, 200)
	var release := mini(frame_count / 4, 400)
	for i in frame_count:
		var phase := fmod(float(i) * freq / float(MIX_RATE), 1.0)
		var raw: float = sin(phase * TAU) if wave == "sine" else signf(sin(phase * TAU))
		var envelope := 1.0
		if i < attack:
			envelope = float(i) / float(maxi(attack, 1))
		elif i > frame_count - release:
			envelope = float(frame_count - i) / float(maxi(release, 1))
		var sample := int(clampf(raw * envelope, -1.0, 1.0) * 32000.0)
		bytes.encode_s16(i * 2, sample)
	return bytes
