extends Node
## Autoload do rádio do carro (tuner).
##
## Controles: ] / + próxima | [ / - anterior | M mute | 1–5 estação direta.
## Se existir `.ogg` em `assets/audio/radio/<id>.ogg`, toca o arquivo;
## senão gera tom procedural via `AudioStreamGenerator` (placeholder).
##
## Registrado em project.godot como `RadioManager`.

signal station_changed(station: RadioStation)
signal radio_toggled(is_on: bool)

const SAMPLE_RATE := 22050
const PLACEHOLDER_SECONDS := 2.0

var is_on: bool = true
var current_index: int = 0
var stations: Array[RadioStation] = []

var _player: AudioStreamPlayer
var _generator_player: AudioStreamPlayer
var _generator_playback: AudioStreamGeneratorPlayback
var _phase: float = 0.0
## True enquanto o placeholder procedural está ativo (precisa de `_fill_generator`).
var _using_generator: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_default_stations()
	_player = AudioStreamPlayer.new()
	_player.name = "RadioPlayer"
	_player.bus = &"Master"
	add_child(_player)

	_generator_player = AudioStreamPlayer.new()
	_generator_player.name = "RadioPlaceholder"
	_generator_player.bus = &"Master"
	add_child(_generator_player)

	_bind_input_actions()
	if not stations.is_empty():
		tune_to(0)


func _process(_delta: float) -> void:
	if not is_on or not _using_generator:
		return
	_fill_generator()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var code: Key = event.keycode if event.keycode != KEY_NONE else event.physical_keycode
	match code:
		KEY_BRACKETRIGHT, KEY_EQUAL:
			next_station()
			get_viewport().set_input_as_handled()
		KEY_BRACKETLEFT, KEY_MINUS:
			previous_station()
			get_viewport().set_input_as_handled()
		KEY_M:
			toggle_radio()
			get_viewport().set_input_as_handled()
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5:
			var idx := int(code) - int(KEY_1)
			if idx >= 0 and idx < stations.size():
				tune_to(idx)
				get_viewport().set_input_as_handled()


func get_current_station() -> RadioStation:
	if stations.is_empty() or current_index < 0 or current_index >= stations.size():
		return null
	return stations[current_index]


func get_station_label() -> String:
	if not is_on:
		return "RADIO OFF"
	var station := get_current_station()
	if station == null:
		return "NO SIGNAL"
	return "%s  %s — %s" % [station.frequency, station.display_name, station.genre]


func next_station() -> void:
	if stations.is_empty():
		return
	is_on = true
	tune_to((current_index + 1) % stations.size())


func previous_station() -> void:
	if stations.is_empty():
		return
	is_on = true
	tune_to((current_index - 1 + stations.size()) % stations.size())


func toggle_radio() -> void:
	is_on = not is_on
	if is_on:
		_play_current()
	else:
		_stop_all()
	radio_toggled.emit(is_on)
	station_changed.emit(get_current_station())


func tune_to(index: int) -> void:
	if index < 0 or index >= stations.size():
		return
	current_index = index
	is_on = true
	_play_current()
	station_changed.emit(get_current_station())


## Toca stream real ou fallback procedural para a estação atual.
func _play_current() -> void:
	_stop_all()
	var station := get_current_station()
	if station == null:
		return

	var stream: AudioStream = _try_load_stream(station.stream_path)
	if stream != null:
		_using_generator = false
		_player.stream = stream
		_player.volume_db = station.volume_db
		_player.play()
		return

	_using_generator = true
	_phase = 0.0
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = SAMPLE_RATE
	generator.buffer_length = 0.1
	_generator_player.stream = generator
	_generator_player.volume_db = station.volume_db
	_generator_player.play()
	_generator_playback = _generator_player.get_stream_playback() as AudioStreamGeneratorPlayback
	_fill_generator()


func _stop_all() -> void:
	_using_generator = false
	_generator_playback = null
	if _player.playing:
		_player.stop()
	if _generator_player.playing:
		_generator_player.stop()


func _try_load_stream(path: String) -> AudioStream:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var res := load(path)
	if res is AudioStream:
		return res
	return null


## Empurra frames de áudio sintético (lead + bass + hat) únicos por `tone_hz`.
func _fill_generator() -> void:
	if _generator_playback == null:
		return
	var station := get_current_station()
	if station == null:
		return

	var frames: int = _generator_playback.get_frames_available()
	if frames <= 0:
		return

	var base_hz: float = station.tone_hz
	var to_fill := mini(frames, 1024)
	for i in to_fill:
		# Simple layered placeholder "track" unique per station.
		var t: float = _phase / float(SAMPLE_RATE)
		var beat: float = 1.0 if fmod(t * (base_hz / 55.0), 1.0) < 0.12 else 0.0
		var lead: float = sin(TAU * base_hz * t) * 0.22
		var bass: float = sin(TAU * (base_hz * 0.5) * t) * 0.18
		var hat: float = sin(TAU * (base_hz * 4.0) * t) * 0.04 * beat
		var sample: float = clampf(lead + bass + hat, -1.0, 1.0)
		_generator_playback.push_frame(Vector2(sample, sample))
		_phase += 1.0


## Cinco estações default — paths apontam para futuros .ogg.
func _build_default_stations() -> void:
	stations.clear()
	stations.append(_make_station(&"pulse", "Pulse FM", "Neon Drive", "101.1 FM", 220.0, "res://assets/audio/radio/pulse.ogg"))
	stations.append(_make_station(&"asphalt", "Asphalt Wave", "Synthwave", "97.7 FM", 185.0, "res://assets/audio/radio/asphalt.ogg"))
	stations.append(_make_station(&"night", "Night Circuit", "Dark Electro", "88.4 FM", 140.0, "res://assets/audio/radio/night.ogg"))
	stations.append(_make_station(&"beat", "Beat Up Radio", "Breakbeat", "104.5 FM", 260.0, "res://assets/audio/radio/beat.ogg"))
	stations.append(_make_station(&"static", "City Static", "Ambient", "90.9 FM", 110.0, "res://assets/audio/radio/static.ogg"))


func _make_station(
	id: StringName,
	display_name: String,
	genre: String,
	frequency: String,
	tone_hz: float,
	stream_path: String,
) -> RadioStation:
	var station := RadioStation.new()
	station.id = id
	station.display_name = display_name
	station.genre = genre
	station.frequency = frequency
	station.tone_hz = tone_hz
	station.stream_path = stream_path
	station.volume_db = -10.0
	return station


func _bind_input_actions() -> void:
	_bind_key("radio_next", KEY_BRACKETRIGHT)
	_bind_key("radio_prev", KEY_BRACKETLEFT)
	_bind_key("radio_mute", KEY_M)


func _bind_key(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	for existing in InputMap.action_get_events(action):
		if existing is InputEventKey and existing.physical_keycode == keycode:
			return
	InputMap.action_add_event(action, event)
