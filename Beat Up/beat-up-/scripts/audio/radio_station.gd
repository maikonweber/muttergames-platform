extends Resource
class_name RadioStation
## Metadados de uma estação do rádio (`RadioManager`).
##
## Coloque o áudio real em `stream_path` (ex.: res://assets/audio/radio/pulse.ogg).
## Se o arquivo não existir, o manager usa `tone_hz` para gerar placeholder.

@export var id: StringName = &""
@export var display_name: String = "Station"
@export var genre: String = "Mix"
@export var frequency: String = "00.0 FM"
## Path .ogg/.wav sob res://. Vazio ou ausente = tom procedural.
@export var stream_path: String = ""
## Frequência base do placeholder procedural (Hz).
@export var tone_hz: float = 220.0
@export var volume_db: float = -8.0
