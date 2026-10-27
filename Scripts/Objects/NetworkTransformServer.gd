extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_transform():
	var target: Node3D = get_parent();
	set_transform_rpc.rpc(
		target.global_position,
		target.global_basis.x,
		target.global_basis.y,
		target.global_basis.z
	);

@rpc("any_peer", "unreliable_ordered", "call_remote")
func set_transform_rpc (position: Vector3, basis_x: Vector3, basis_y: Vector3, basis_z: Vector3) -> void:
	var target = get_parent()
	target.global_position = position
	target.global_basis.x = basis_x;
	target.global_basis.y = basis_y;
	target.global_basis.z = basis_z;
	pass
