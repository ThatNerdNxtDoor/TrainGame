extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	var m_dir2D = Input.get_vector("move_right", "move_left", "move_backwards", "move_forward")
	var m_dir3D = Vector3(m_dir2D.x, 0, m_dir2D.y)
	
	velocity = m_dir3D * delta * 20;
	move_and_slide()
