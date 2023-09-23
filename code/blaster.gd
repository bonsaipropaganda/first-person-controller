extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var gun_flash = $blasterD/GunFlash
@onready var gun_barrel = $blasterD/GunBarrel

@export var bullet_scene: PackedScene


func shoot():
	if !animation_player.is_playing():
		animation_player.play("shoot",1,5,false)
		gun_flash.visible = true
		var b = bullet_scene.instantiate()
		b.global_position = gun_barrel.global_position
		b.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(b)

func stop_shooting():
	animation_player.stop()
	gun_flash.visible = false



func _on_animation_player_animation_finished(shoot):
	gun_flash.visible = false
