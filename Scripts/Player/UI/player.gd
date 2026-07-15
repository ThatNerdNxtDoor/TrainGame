extends CharacterBody3D

# Variable for input movement
var input_direction: Vector2

# Exportable variables

# Speeds
@export var speed: float = 5.0
@export var run_speed: float = 10.0
@export var crouch_speed: float = 2.5

# Mouse
@export var look_sensitivity: float = 0.005

# Movement
@export var acceleration := 60.0
@export var jump_velocity: float = 4.5
@export var air_control := 5.0
@export var air_resistance := 2.0
@export var gravity: float = 9.8

# Crouching
@export var standing_height := 1.8
@export var crouching_height := 1.0
@export var crouch_transition_speed := 10.0

# Boolean for if the player is crouched
var is_crouching := false

# Variables for heights
var camera_stand_height: float
var camera_crouch_height: float

# On ready variables
# (Head, Camera, and Collision Shape)
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var collision = $CollisionShape3D


func _ready() -> void:
	
	# Make it where the Mouse is Captured in the app, hidden, and fixed center
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Get Camera Height Parameters
	camera_stand_height = head.position.y
	camera_crouch_height = camera_stand_height - 0.5


func _unhandled_input(event: InputEvent) -> void:

	# Camera
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * look_sensitivity)
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

	# Mouse capture
	if Input.is_action_just_pressed("escape"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:

	# Gravity
	# Check if the player is not on the floor
	if not is_on_floor():
		# Hence, use gravity to effect 'y' velocity
		velocity.y -= gravity * delta

	# Jump
	# Check if 'jump' is pressed and they are on floor
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Crouch
	is_crouching = Input.is_action_pressed("crouch")

	# Input
	input_direction = Input.get_vector("left", "right", "up", "down")

	# Get direction (Convert 2D input vector into 3D)
	var direction = (
		head.transform.basis *
		Vector3(input_direction.x, 0, input_direction.y)
	).normalized()

	# Movement speed
	var target_velocity

	# Check if crouching or running
	if is_crouching:
		target_velocity = direction * crouch_speed
	elif Input.is_action_pressed("run"):
		target_velocity = direction * run_speed
	else:
		target_velocity = direction * speed

	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)

	if is_on_floor():
		
		# Ground Movement
		horizontal_velocity = horizontal_velocity.move_toward(
			target_velocity,
			acceleration * delta
		)
	else:
		
		# Air Movement
		if direction:
			horizontal_velocity = horizontal_velocity.move_toward(
				target_velocity,
				air_control * delta
			)
		horizontal_velocity = horizontal_velocity.move_toward(
			Vector3.ZERO,
			air_resistance * delta
		)

	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	# Smooth camera movement
	var target_camera_height = camera_stand_height

	# Effect height if crouching or not
	if is_crouching:
		target_camera_height = camera_crouch_height

	# Transition camera heights using lerp
	head.position.y = lerp(
		head.position.y,
		target_camera_height,
		crouch_transition_speed * delta
	)

	# Smooth capsule resizing
	var capsule = collision.shape as CapsuleShape3D

	var target_height = standing_height

	if is_crouching:
		target_height = crouching_height

	capsule.height = lerp(
		capsule.height,
		target_height,
		crouch_transition_speed * delta
	)

	move_and_slide()
