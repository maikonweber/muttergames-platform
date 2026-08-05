extends Node

signal state_changed
signal notification_sent(message: String)
signal event_started(event: CosmicEvent)
signal prestige_completed(reward: int)
signal sfx_requested(sfx_name: String)

const ORBITS := 3
const MAX_OFFLINE_SECONDS := 28800.0
## Tamanhos da janela: compacto é a "barra idle" que fica junto à borda da tela; expandido
## é a janela normal de gerenciamento (bordas, redimensionável, título e configurações).
const COMPACT_SIZE := Vector2i(480, 104)
const EXPANDED_SIZE := Vector2i(1000, 600)
var inventory := ResourceInventory.new()
var planets: Array[Planet] = []
var asteroids := 0
var essence_upgrades := 0
var paused := false
var compact_mode := true # Padrão: iniciar como barra idle junto à tela, não janela cheia.
var active_event: CosmicEvent
var elapsed := 0.0
var event_cooldown := 55.0
var autosave_elapsed := 0.0
var settings := GameSettings.new()
var tutorial := TutorialState.new()
var universe_seed := int(Time.get_unix_time_from_system())
var random := RandomNumberGenerator.new()

func _ready() -> void:
	load_game()
	random.seed = universe_seed
	get_window().size = COMPACT_SIZE if compact_mode else EXPANDED_SIZE
	apply_settings()
	# Necessário para que fechar a janela (X) chegue como NOTIFICATION_WM_CLOSE_REQUEST
	# em vez de encerrar o processo imediatamente; ver _notification() abaixo, que decide
	# entre minimizar, enviar para a bandeja ou sair de fato.
	get_tree().auto_accept_quit = false
	# Em algumas plataformas/gerenciadores de janela a posição definida antes do primeiro
	# frame é sobrescrita quando a janela é efetivamente mapeada na tela; reaplicar uma vez
	# após o primeiro frame torna o ancoramento junto à barra de tarefas confiável.
	await get_tree().process_frame
	apply_settings()

## Alterna entre a barra idle (compacta, sem bordas, junto à tela) e a janela de gerenciamento
## (expandida, com bordas). Deve ser o único ponto de entrada para mudar compact_mode.
func set_compact_mode(value: bool) -> void:
	compact_mode = value
	get_window().size = COMPACT_SIZE if compact_mode else EXPANDED_SIZE
	apply_settings()

func _process(delta: float) -> void:
	if paused: return
	tick(delta)

func tick(delta: float) -> void:
	var simulation_delta := delta * settings.update_rate
	if not DisplayServer.window_is_focused(): simulation_delta *= settings.background_efficiency
	if simulation_delta <= 0.0: return
	elapsed += simulation_delta
	autosave_elapsed += delta
	inventory.add("Energia", (1.5 + essence_upgrades * 0.15) * simulation_delta)
	inventory.add("Materia", (0.8 + asteroids * 0.12) * simulation_delta)
	for planet in planets: planet.evolve(simulation_delta, inventory)
	event_cooldown -= simulation_delta
	if event_cooldown <= 0.0 and active_event == null:
		active_event = CosmicEvent.random_event(planets, random)
		event_cooldown = 75.0
		event_started.emit(active_event)
		sfx_requested.emit("event")
	if autosave_elapsed >= 30.0:
		autosave_elapsed = 0.0
		save_game()
	state_changed.emit()

func create_asteroid() -> bool:
	if not inventory.pay({"Materia": 15.0}): return false
	asteroids += 1
	if asteroids >= 2 and tutorial.current_step == 0: tutorial.complete_current()
	notification_sent.emit("Asteroide criado.")
	sfx_requested.emit("success")
	state_changed.emit()
	return true

func forge_planet(orbit: int) -> bool:
	if orbit < 0 or orbit >= ORBITS or planet_at_orbit(orbit) != null or asteroids < 2: return false
	if not inventory.pay({"Materia": 25.0, "Energia": 15.0}): return false
	asteroids -= 2
	planets.append(Planet.new(orbit, random))
	if tutorial.current_step == 1: tutorial.complete_current()
	notification_sent.emit("Novo planeta forjado na orbita %d." % (orbit + 1))
	sfx_requested.emit("success")
	state_changed.emit()
	return true

func terraform(planet: Planet) -> bool:
	if not inventory.pay({"Agua": 12.0, "Energia": 20.0}): return false
	planet.atmosphere = minf(100.0, planet.atmosphere + 25.0)
	planet.water = minf(100.0, planet.water + 20.0)
	if planet.is_habitable() and tutorial.current_step == 2: tutorial.complete_current()
	sfx_requested.emit("success")
	state_changed.emit()
	return true

func start_life(planet: Planet) -> bool:
	if not planet.is_habitable() or planet.life or not inventory.pay({"Agua": 10.0, "Energia": 15.0}): return false
	planet.life = true
	if tutorial.current_step == 3: tutorial.complete_current()
	notification_sent.emit("Vida floresceu em uma orbita!")
	sfx_requested.emit("chime")
	state_changed.emit()
	return true

func advance_civilization(planet: Planet) -> bool:
	if not planet.life or planet.civilization or not inventory.pay({"Biomassa": 35.0, "Conhecimento": 20.0}): return false
	planet.civilization = true
	if tutorial.current_step == 4: tutorial.complete_current()
	notification_sent.emit("Uma civilizacao alcancou as estrelas.")
	sfx_requested.emit("chime")
	state_changed.emit()
	return true

func resolve_event(choice: Dictionary) -> void:
	var effect: Dictionary = choice.get("effect", {})
	for resource in effect:
		inventory.apply_delta(str(resource), float(effect[resource]))
	active_event = null
	state_changed.emit()

func prestige() -> bool:
	if planets.size() < ORBITS: return false
	var reward: int = maxi(1, int(sqrt(planets.size() * 4.0)))
	inventory.add("Essencia", reward)
	essence_upgrades += reward
	planets.clear(); asteroids = 0
	if tutorial.current_step == 5: tutorial.complete_current()
	notification_sent.emit("Supernova concluida: +%d Essencia." % reward)
	prestige_completed.emit(reward)
	sfx_requested.emit("prestige")
	state_changed.emit()
	return true

func planet_at_orbit(orbit: int) -> Planet:
	for planet in planets:
		if planet.orbit == orbit: return planet
	return null

func collect_water() -> bool:
	if not inventory.pay({"Energia": 8.0}): return false
	inventory.add("Agua", 20.0)
	notification_sent.emit("Cometa capturado: +20 Água.")
	sfx_requested.emit("success")
	state_changed.emit()
	return true

func research() -> bool:
	if not inventory.pay({"Energia": 12.0, "Biomassa": 8.0}): return false
	inventory.add("Conhecimento", 10.0)
	notification_sent.emit("Pesquisa concluída: +10 Conhecimento.")
	sfx_requested.emit("success")
	state_changed.emit()
	return true

func save_game() -> bool:
	return SaveService.save({
		"universe_seed": universe_seed,
		"inventory": inventory.serialize(),
		"asteroids": asteroids,
		"planets": planets.map(func(p: Planet) -> Dictionary: return p.serialize()),
		"essence_upgrades": essence_upgrades,
		"settings": settings.serialize(),
		"tutorial": tutorial.serialize(),
		"compact_mode": compact_mode,
		"saved_at": Time.get_unix_time_from_system(),
	})

func load_game() -> void:
	var data: Dictionary = SaveService.load()
	if data.is_empty(): return
	inventory.deserialize(data.get("inventory", {}) as Dictionary)
	asteroids = int(data.get("asteroids", 0)); essence_upgrades = int(data.get("essence_upgrades", 0))
	universe_seed = int(data.get("universe_seed", universe_seed)); random.seed = universe_seed
	settings.deserialize(data.get("settings", {}) as Dictionary)
	tutorial.deserialize(data.get("tutorial", {}) as Dictionary)
	compact_mode = bool(data.get("compact_mode", compact_mode))
	planets.clear()
	var saved_planets: Array = data.get("planets", []) as Array
	for planet_data in saved_planets:
		if planet_data is Dictionary:
			planets.append(Planet.from_data(planet_data as Dictionary))
	var offline := clampf(Time.get_unix_time_from_system() - float(data.get("saved_at", 0)), 0.0, MAX_OFFLINE_SECONDS)
	if offline > 1.0:
		tick(offline)
		if settings.notifications_enabled: notification_sent.emit("Progresso offline aplicado: %d min." % int(offline / 60.0))

func apply_settings() -> void:
	var window := get_window()
	settings.apply_to_window(window)
	# A barra idle (compacta) fica sem bordas para parecer um widget junto à barra de
	# tarefas; expandida volta a ser uma janela normal (título, borda, redimensionável).
	window.borderless = compact_mode
	state_changed.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
		var tray := get_node_or_null("/root/TrayService")
		if settings.tray_enabled and tray != null and tray.is_supported():
			tray.hide_to_tray()
		elif settings.close_minimizes:
			get_window().mode = Window.MODE_MINIMIZED
		else:
			get_tree().quit()
