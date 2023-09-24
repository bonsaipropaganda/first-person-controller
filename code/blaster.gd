extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var gun_flash = $blasterD/GunFlash
@onready var gun_barrel = $GunBarrel

@onready var starting_position = position



func _on_animation_player_animation_finished(shoot):
	gun_flash.visible = false
