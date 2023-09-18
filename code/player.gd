extends CharacterBody3D

# player nodes
@onready var neck = $Neck
@onready var head = $Neck/Head
@onready var camera_3d = $Neck/Head/Camera3D
@onready var standing_shape = $StandingShape
@onready var crouch_shape = $CrouchShape
@onready var ray_cast_3d = $RayCast3D

# state machine
var free_looking = false
var sprinting = false
var walking = false
var crouching = false
var sliding = false

# speed vars
var current_speed = 5.0
var lerp_speed = 10
const walk_speed = 5
const sprint_speed = 8
const crouch_speed = 3

# Input
var mouse_sen = 0.4
var direction = Vector3.ZERO
const JUMP_VELOCITY = 4.5

# camera/head height
var crouch_height = -0.5
var normal_height = 0.0
var free_look_tilt = .1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
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
	# release the mouse
	if Input.is_action_just_pressed("escape"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# crouching is checked first because it overrides other movement types
	if Input.is_action_pressed("crouch"):
		current_speed = crouch_speed
		head.position.y = lerp(head.position.y, crouch_height, delta * lerp_speed)
		# sets the appropriate collision shape
		standing_shape.disabled = true
		crouch_shape.disabled = false
	
	# standing
	# check if something is above your head before letting you stand
	elif !ray_cast_3d.is_colliding():
		standing_shape.disabled = false
		crouch_shape.disabled = true
		# head is at normal position
		head.position.y = lerp(head.position.y, normal_height, delta * lerp_speed)
		# if not crouching you can sprint/walk
		if Input.is_action_pressed("sprint"):
			current_speed = sprint_speed
		else:
			current_speed = walk_speed
	
	if Input.is_action_pressed("free_look"):
		# toggles free look
		free_looking = true
		camera_3d.rotation.z = neck.rotation.y * free_look_tilt
	else: # not freelooking
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * lerp_speed) # reset neck
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, 0.0, delta * lerp_speed)

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
