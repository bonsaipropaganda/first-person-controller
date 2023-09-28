extends Node3D
signal start_game

func kill():
	Global.game_started = true
	start_game.emit()
	queue_free()
