extends Node3D
@onready var coll_ray = $CollRay

var speed = 40
var velocity = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta
	if coll_ray.is_colliding():
		var collider = coll_ray.get_collider()
		if collider.is_in_group("enemy"):
			collider.kill()
		queue_free()

func set_velocity(target):
	look_at(target)
	velocity = position.direction_to(target) * speed

func _on_kill_timer_timeout():
	queue_free()
