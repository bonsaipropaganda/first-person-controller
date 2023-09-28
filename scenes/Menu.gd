extends Node3D

var start_button_scene = preload("res://scenes/start_target.tscn")
@onready var start_marker = $StartMarker


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.game_over.connect(_on_game_over)


func _on_game_over():
	var i = start_button_scene.instantiate()
	start_marker.add_child(i)
