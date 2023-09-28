extends Node3D


func kill():
	Global.target_destroyed.emit()
	queue_free()
