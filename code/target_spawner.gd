extends Node3D

var children: Array
var target_scene = preload("res://scenes/target.tscn")

func _ready():
	Global.start_game.connect(_on_start_game)

func _on_start_game():
	children = get_children()
	for child in children:
		var target = target_scene.instantiate()
		child.add_child(target)
