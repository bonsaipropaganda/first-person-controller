extends CharacterBody3D

# player nodes
@onready var neck = $Neck
@onready var head = $Neck/Head
@onready var eyes = $Neck/Head/Eyes
@onready var camera_3d = $Neck/Head/Eyes/Camera3D
@onready var standing_shape = $StandingShape
@onready var crouch_shape = $CrouchShape
@onready var ray_cast_3d = $RayCast3D
@onready var animation_player = $Neck/Head/Eyes/AnimationPlayer
@onready var blaster = $Neck/Head/Eyes/Camera3D/Blaster
@onready var gun_flash = $Neck/Head/Eyes/Camera3D/Blaster.gun_flash
@onready var bullet_scene = preload("res://scenes/bullet.tscn")
@onready var gun_barrel = $Neck/Head/Eyes/Camera3D/Blaster.gun_barrel
@onready var gun_anim = $Neck/Head/Eyes/Camera3D/Blaster.animation_player
@onready var aim_ray = $Neck/Head/Eyes/Camera3D/AimRay
@onready var aim_ray_end = $Neck/Head/Eyes/Camera3D/AimRayEnd

var start_pos: Vector3

# state machine
var free_looking = false
var sprinting = false
var walking = false
var crouching = false
var sliding = false

# speed vars
var current_speed = 5.0
var lerp_speed = 10.0
var air_lerp_speed = 2.0
const walk_speed = 5.0
const sprint_speed = 8.0
const crouch_speed = 3.0
const slide_speed = 8

# head bobbing vars
const head_bobbing_sprinting_speed = 22
const head_bobbing_walking_speed = 14
const head_bobbing_crouching_speed = 10

const head_bobbing_sprinting_intensity = .2
const head_bobbing_walking_intensity = .1
const head_bobbing_crouching_intensity = .05

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

# slide vars
var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO

# Input
var mouse_sen = 0.4
var direction = Vector3.ZERO
const JUMP_VELOCITY = 5.5

# camera/head height
var crouch_height = -0.5
var normal_height = 0.0
var free_look_tilt = .1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	start_pos = self.position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# camera movement
	if event is InputEventMouseMotion:
		# first check if free looking
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sen))
			neck.rotation.y = clamp(neck.rotation.y,deg_to_rad(-80),deg_to_rad(80))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sen))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sen))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))

func _physics_process(delta):
	# getting input from player to see where we headed bro
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	if Global.game_started == false:
		input_dir = Vector2.ZERO
	
	# release the mouse
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# crouching is checked first because it overrides other movement types
	if Input.is_action_pressed("crouch") or sliding:
		current_speed = lerp(current_speed,crouch_speed,delta * lerp_speed)
		head.position.y = lerp(head.position.y, crouch_height, delta * lerp_speed)
		# sets the appropriate collision shape
		standing_shape.disabled = true
		crouch_shape.disabled = false
		
		if sprinting and input_dir != Vector2.ZERO:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
		
		sprinting = false
		walking = false
		crouching = true
	
	# standing
	# check if something is above your head before letting you stand
	elif !ray_cast_3d.is_colliding():
		standing_shape.disabled = false
		crouch_shape.disabled = true
		# head is at normal position
		head.position.y = lerp(head.position.y, normal_height, delta * lerp_speed)
		# if not crouching you can sprint/walk
		if Input.is_action_pressed("sprint"):
			current_speed = lerp(current_speed,sprint_speed, delta * lerp_speed)
			sprinting = true
			walking = false
			crouching = false
		else:
			sprinting = false
			walking = true
			crouching = false
			current_speed = lerp(current_speed, walk_speed, delta * lerp_speed)
	
	if Input.is_action_pressed("free_look") or sliding:
		# toggles free look
		free_looking = true
		if sliding:
			eyes.rotation.z = lerp(eyes.rotation.z, deg_to_rad(-10), delta * lerp_speed)
		else:
			eyes.rotation.z = neck.rotation.y * free_look_tilt
	else: # not freelooking
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * lerp_speed) # reset neck
		eyes.rotation.z = lerp(eyes.rotation.z, 0.0, delta * lerp_speed)

	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
	
	# headbob logic
	if walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta
	
	if is_on_floor() and !sliding and input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2) +0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity/2),delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*head_bobbing_current_intensity,delta * lerp_speed)
		
		blaster.position.y = lerp(blaster.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity/2),delta * lerp_speed)
		blaster.position.x = lerp(blaster.position.x, head_bobbing_vector.x*head_bobbing_current_intensity,delta * lerp_speed)
		blaster.position.y -= .05
		blaster.position.x += .07
	
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0,delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0,delta * lerp_speed)

		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sliding = false
#		animation_player.play("jump_land")
	
	# Shooting
	if Input.is_action_pressed("shoot"):
		shoot()
	else:
		stop_shooting()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_lerp_speed)
	
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x,0,slide_vector.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		if sliding:
			velocity.x = direction.x * (slide_timer + .3) * slide_speed
			velocity.z = direction.z * (slide_timer + .3) * slide_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()


func shoot():
	await get_tree().create_timer(.3).timeout
	if !gun_anim.is_playing():
		gun_anim.play("shoot_2")
		gun_flash.visible = true
		var b = bullet_scene.instantiate()
		b.position = gun_barrel.global_position
		get_parent().add_child(b)
		if aim_ray.is_colliding():
			b.set_velocity(aim_ray.get_collision_point())
		else:
			b.set_velocity(aim_ray_end.global_position)

func stop_shooting():
#	position = lerp(position, starting_position, 10 * get_process_delta_time())
#	animation_player.stop()
	gun_flash.visible = false
