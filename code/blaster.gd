extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var gun_flash = $blasterD/GunFlash
@onready var gun_barrel = $blasterD/GunBarrel

@export var bullet_scene: PackedScene

@onready var starting_position = position

func shoot():
	await get_tree().create_timer(.3).timeout
	if !animation_player.is_playing():
		animation_player.play("shoot_2")
		gun_flash.visible = true
		var b = bullet_scene.instantiate()
		b.transform.origin = gun_barrel.transform.origin
		b.transform.basis = gun_barrel.transform.basis
		add_child(b)

func stop_shooting():
#	position = lerp(position, starting_position, 10 * get_process_delta_time())
#	animation_player.stop()
	gun_flash.visible = false



func _on_animation_player_animation_finished(shoot):
	gun_flash.visible = false
