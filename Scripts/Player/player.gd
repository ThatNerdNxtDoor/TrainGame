extends CharacterBody3D


# ============================================================
# INPUT
# ============================================================

var input_direction: Vector2


# ============================================================
# EXPORTABLE VARIABLES
# ============================================================

# ------------------------------------------------------------
# Speeds
# ------------------------------------------------------------

@export var speed: float = 5.0
@export var crouch_speed: float = 2.5


# ------------------------------------------------------------
# Mouse
# ------------------------------------------------------------

@export var look_sensitivity: float = 0.005


# ------------------------------------------------------------
# Movement
# ------------------------------------------------------------

@export var acceleration := 60.0
@export var jump_velocity: float = 4.5
@export var air_control := 5.0
@export var air_resistance := 2.0
@export var gravity: float = 9.8


# ------------------------------------------------------------
# Crouching
# ------------------------------------------------------------

@export var standing_height := 1.8
@export var crouching_height := 1.0
@export var crouch_transition_speed := 10.0


# ------------------------------------------------------------
# Pressurized Gas
# ------------------------------------------------------------

@export_category("Pressurized Gas")

# Maximum amount of gas the player can hold
@export var max_gas: float = 100.0

# Current amount of gas
@export var gas: float = 100.0

# Gas required for each air jump
@export var air_jump_gas_cost: float = 20.0

# Gas consumed per second while gliding
@export var glide_gas_per_second: float = 10.0

# Gas required to dash
@export var dash_gas_cost: float = 30.0

# Gas recharge rate
@export var gas_recharge_rate: float = 15.0


# ------------------------------------------------------------
# Dash
# ------------------------------------------------------------

@export_category("Dash")

# Speed of the dash
@export var dash_speed: float = 18.0

# How long the dash lasts
@export var dash_duration: float = 0.2


# ------------------------------------------------------------
# Glide
# ------------------------------------------------------------

@export_category("Glide")

# How strongly gravity is reduced while gliding
@export var glide_gravity: float = 2.0

# Maximum downward speed while gliding
@export var glide_fall_speed: float = -2.0


# ============================================================
# BOOLEAN / STATE VARIABLES
# ============================================================

# Is the player crouched?
var is_crouching := false

# Is the player currently dashing?
var is_dashing := false


# ============================================================
# VARIABLES FOR HEIGHTS
# ============================================================

var camera_stand_height: float
var camera_crouch_height: float


# ============================================================
# DASH VARIABLES
# ============================================================

# Direction the player will travel during the dash
var dash_direction := Vector3.ZERO

# How much longer the dash lasts
var dash_timer := 0.0


# ============================================================
# JUMP VARIABLES
# ============================================================

# Keeps track of how many times the player has jumped
var jump_count := 0


# ============================================================
# ON READY VARIABLES
# ============================================================

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var collision = $CollisionShape3D


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	# Make it where the Mouse is Captured in the app,
	# hidden, and fixed center
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Get Camera Height Parameters
	camera_stand_height = head.position.y
	camera_crouch_height = camera_stand_height - 0.5

	# Make sure gas starts at maximum
	gas = max_gas


# ============================================================
# INPUT
# ============================================================

func _unhandled_input(event: InputEvent) -> void:

	# --------------------------------------------------------
	# Camera
	# --------------------------------------------------------

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:

		head.rotate_y(-event.relative.x * look_sensitivity)

		camera.rotate_x(-event.relative.y * look_sensitivity)

		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)


	# --------------------------------------------------------
	# Mouse Capture
	# --------------------------------------------------------

	if Input.is_action_just_pressed("escape"):

		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:

			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:

			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


	if event is InputEventMouseButton and event.pressed:

		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ============================================================
# PHYSICS PROCESS
# ============================================================

func _physics_process(delta: float) -> void:

	# ========================================================
	# CROUCH
	# ========================================================

	# The player can ONLY crouch while on the ground.
	#
	# This means pressing crouch in the air will not work.
	if is_on_floor():

		is_crouching = Input.is_action_pressed("crouch")

	else:

		is_crouching = false


	# ========================================================
	# DASH
	# ========================================================

	# If currently dashing, handle the dash.
	if is_dashing:

		handle_dash(delta)

	else:

		# Otherwise check whether the player wants to dash.
		handle_dash_input()


	# ========================================================
	# GRAVITY
	# ========================================================

	# Don't apply normal gravity while dashing.
	if not is_on_floor() and not is_dashing:

		# Check whether the player is currently gliding.
		if Input.is_action_pressed("jump") and gas > 0.0:

			# Reduced gravity while gliding.
			velocity.y -= glide_gravity * delta

			# Prevent the player from falling faster than
			# the maximum glide fall speed.
			velocity.y = max(
				velocity.y,
				glide_fall_speed
			)

			# Consume gas while gliding.
			gas -= glide_gas_per_second * delta

			# Don't let gas go below zero.
			gas = max(gas, 0.0)

		else:

			# Normal gravity.
			velocity.y -= gravity * delta


	# ========================================================
	# JUMP
	# ========================================================

	handle_jump()


	# ========================================================
	# INPUT
	# ========================================================

	input_direction = Input.get_vector(
		"left",
		"right",
		"forward",
		"back"
	)


	# ========================================================
	# GET DIRECTION
	# ========================================================

	# Convert 2D input vector into 3D.
	var direction = (
		head.transform.basis *
		Vector3(
			input_direction.x,
			0,
			input_direction.y
		)
	).normalized()


	# ========================================================
	# MOVEMENT SPEED
	# ========================================================

	var target_velocity


	# Check if crouching.
	if is_crouching:

		target_velocity = direction * crouch_speed

	else:

		target_velocity = direction * speed


	# ========================================================
	# HORIZONTAL VELOCITY
	# ========================================================

	var horizontal_velocity = Vector3(
		velocity.x,
		0,
		velocity.z
	)


	# Don't allow normal movement to override the dash.
	if not is_dashing:

		if is_on_floor():

			# ------------------------------------------------
			# Ground Movement
			# ------------------------------------------------

			horizontal_velocity = horizontal_velocity.move_toward(
				target_velocity,
				acceleration * delta
			)

		else:

			# ------------------------------------------------
			# Air Movement
			# ------------------------------------------------

			if direction:

				horizontal_velocity = horizontal_velocity.move_toward(
					target_velocity,
					air_control * delta
				)

			horizontal_velocity = horizontal_velocity.move_toward(
				Vector3.ZERO,
				air_resistance * delta
			)


	# ========================================================
	# APPLY HORIZONTAL VELOCITY
	# ========================================================

	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z


	# ========================================================
	# SMOOTH CAMERA MOVEMENT
	# ========================================================

	var target_camera_height = camera_stand_height


	# Effect height if crouching or not.
	if is_crouching:

		target_camera_height = camera_crouch_height


	# Transition camera heights using lerp.
	head.position.y = lerp(
		head.position.y,
		target_camera_height,
		crouch_transition_speed * delta
	)


	# ========================================================
	# SMOOTH CAPSULE RESIZING
	# ========================================================

	var capsule = collision.shape as CapsuleShape3D

	var target_height = standing_height


	if is_crouching:

		target_height = crouching_height


	capsule.height = lerp(
		capsule.height,
		target_height,
		crouch_transition_speed * delta
	)


	# ========================================================
	# MOVE PLAYER
	# ========================================================

	move_and_slide()


	# ========================================================
	# RESET JUMP COUNT
	# ========================================================

	# Once we land, the next jump from the ground is free.
	if is_on_floor():

		jump_count = 0
		
	# Recharge gas
	if gas < max_gas:
		gas += gas_recharge_rate * delta
		gas = min(gas, max_gas)


# ============================================================
# JUMP HANDLING
# ============================================================

func handle_jump() -> void:

	# --------------------------------------------------------
	# CANNOT JUMP WHILE CROUCHED
	# --------------------------------------------------------

	if is_crouching:

		return


	# --------------------------------------------------------
	# JUMP BUTTON PRESSED
	# --------------------------------------------------------

	if Input.is_action_just_pressed("jump"):

		# ----------------------------------------------------
		# GROUND JUMP
		# ----------------------------------------------------

		if is_on_floor():

			velocity.y = jump_velocity

			jump_count = 1

			return


		# ----------------------------------------------------
		# AIR JUMP
		# ----------------------------------------------------

		# Player is airborne.
		#
		# Check whether they have enough gas.
		if gas >= air_jump_gas_cost:

			# Consume gas.
			gas -= air_jump_gas_cost

			# Launch the player upward again.
			velocity.y = jump_velocity

			# Keep track of the jump.
			jump_count += 1


# ============================================================
# DASH INPUT
# ============================================================

func handle_dash_input() -> void:

	# Cannot dash while crouched
	if is_crouching:
		return

	# Cannot dash without enough gas
	if gas < dash_gas_cost:
		return

	# Check if dash button was pressed
	if Input.is_action_just_pressed("dash"):

		var dash_input = Input.get_vector(
			"left",
			"right",
			"up",
			"down"
		)

		# Dash in movement direction
		if dash_input.length() > 0.0:

			dash_direction = (
				head.transform.basis *
				Vector3(
					dash_input.x,
					0,
					dash_input.y
				)
			).normalized()

		# If no movement input, dash forward
		else:

			dash_direction = -head.transform.basis.z

			# Keep dash horizontal
			dash_direction.y = 0.0
			dash_direction = dash_direction.normalized()

		# Consume gas
		gas -= dash_gas_cost
		gas = max(gas, 0.0)

		# Start dash
		is_dashing = true
		dash_timer = dash_duration

# ============================================================
# DASH MOVEMENT
# ============================================================

func handle_dash(delta: float) -> void:

	# --------------------------------------------------------
	# HORIZONTAL DASH
	# --------------------------------------------------------

	# Only change horizontal velocity.
	#
	# This means if you are airborne, your current vertical
	# velocity is preserved.
	velocity.x = dash_direction.x * dash_speed
	velocity.z = dash_direction.z * dash_speed


	# Reduce dash timer
	dash_timer -= delta


	# --------------------------------------------------------
	# END DASH
	# --------------------------------------------------------

	if dash_timer <= 0.0:

		is_dashing = false

		# Stop horizontal dash velocity
		velocity.x = 0.0
		velocity.z = 0.0
