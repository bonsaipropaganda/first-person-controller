extends Node3D


func kill():
	Global.game_started = true
	Global.start_game.emit()
	queue_free()
