extends Node

signal target_destroyed
signal game_over
signal start_game
var game_started = false

func _ready():
	game_over.connect(_on_game_over)

func _on_game_over():
	game_started = false
