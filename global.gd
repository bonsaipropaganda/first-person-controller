extends Node

signal target_destroyed
signal game_over
signal start_game
var game_started = false
var total_time: float

func _ready():
	game_over.connect(_on_game_over)

func _on_game_over():
	game_started = false
