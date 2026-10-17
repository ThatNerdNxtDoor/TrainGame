##################### 
# Note for Makendra
# I did not have time to implement your player code. Honestly, we should spend time merging our branches together, perhaps every meeting? XD

extends CharacterBody3D

@export var speed : float = 5.0
@export var jump_velocity : float = 6.0
@export var gravity : float = 20.0
@export var mouse_sensitivity : float = 0.003

## Movement when on a floor versus in the air is separated, allowing the preservation of momentum when jumping on a moving platform like a train while also still allowing some control in the air. 
## Set to 0 to prevent any movement in the air.  
@export var air_control: float = 15.0


@onready var camera : Camera3D = $Camera3D

var camera_pitch : float = 0.0
var jump_requested : bool = false
var launch_velocity : Vector3

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -1.4, 1.4)
		camera.rotation.x = camera_pitch

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			jump_requested = true
		elif event.keycode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif jump_requested:
		velocity.y = jump_velocity
	jump_requested = false

	var input_dir := Vector2(
		float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A)),
		float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W))
	).normalized()

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor(): # Standing on something?
		if direction: # Pressing a movement key?
			velocity.x = direction.x * speed  # Set movement speed to walking speed.
			velocity.z = direction.z * speed 
		else:
			velocity.x = move_toward(velocity.x, 0, speed) # Stop moving
			velocity.z = move_toward(velocity.z, 0, speed)
	else: # Not standing on something. 
		if direction:
			velocity.x = move_toward(velocity.x, launch_velocity.x + direction.x * speed, air_control* delta)
			velocity.z = move_toward(velocity.z, launch_velocity.z + direction.z * speed, air_control* delta)

	move_and_slide()
	if is_on_floor():
		rotate_y(get_platform_angular_velocity().y * delta) # Allows the player to rotate alongside the train.
		launch_velocity = get_platform_velocity()
