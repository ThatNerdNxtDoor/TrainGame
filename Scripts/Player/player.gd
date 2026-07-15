extends CharacterBody3D


const SPEED = 10.0
const SPEED_CHANGE = 2;
const JUMP_VELOCITY = 4.5

@onready var cam = $Pivot/Camera3D;
@onready var pivot = $Pivot
var cam_velocity = Vector2.ZERO


func _physics_process(delta: float) -> void:
	var m_dir2D = -Input.get_vector("move_right", "move_left", "move_backwards", "move_forward")
	var m_dir3D = Vector3(m_dir2D.x, 0, m_dir2D.y)
	pivot.rotate_y(-cam_velocity.x * delta * 0.5);
	cam.rotate_x(-cam_velocity.y * delta * 0.5);
	
	var rotated_dir = m_dir3D.rotated(Vector3(0, 1, 0), pivot.rotation.y)
	var target_velocity = rotated_dir * SPEED;
	target_velocity.y = velocity.y
	velocity = (velocity - target_velocity)*exp(-delta * SPEED_CHANGE) + target_velocity
	cam_velocity = Vector2.ZERO
	
	
		
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	move_and_slide()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		cam_velocity = event.screen_relative
		
