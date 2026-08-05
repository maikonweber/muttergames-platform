extends Node
## Autoload global de estado de sessão (score + machine states).
##
## Registrado em `project.godot` como `GameManager`.
## Ainda não existe menu/game-over UI completa — estados existem para
## HUD, debug e futuras telas. Ver plano no README (Fase 1).

## Ciclo de vida da sessão. `MENU` é o estado inicial antes de `start_game()`.
enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

signal score_changed(score: int)
signal state_changed(state: GameState)

var score: int = 0
var state: GameState = GameState.MENU


func _ready() -> void:
	print("🎮 GameManager iniciado!")


## Zera score e entra em PLAYING. Chamado por `main.gd` no boot.
func start_game() -> void:
	score = 0
	change_state(GameState.PLAYING)


func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)


## Troca de estado (idempotente — não reemite se for o mesmo).
func change_state(new_state: GameState) -> void:
	if state == new_state:
		return

	state = new_state
	state_changed.emit(state)


## Pausa a árvore de cena (`get_tree().paused`) + estado PAUSED.
func pause_game() -> void:
	get_tree().paused = true
	change_state(GameState.PAUSED)


func resume_game() -> void:
	get_tree().paused = false
	change_state(GameState.PLAYING)


## Marca game over (sem desligar a árvore ainda — UI futura).
func game_over() -> void:
	change_state(GameState.GAME_OVER)
