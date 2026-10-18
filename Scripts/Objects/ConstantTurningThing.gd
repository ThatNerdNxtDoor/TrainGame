extends Node3D


# Called when the node enters the scene tree for the first time.
@export var axis : Vector3
@export var speed : float

@onready var current_rotation = axis.dot(rotation)

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#rotation = Vector3.ZERO;
	#current_rotation = speed + delta
	rotate(axis, speed * delta)
	set_rotation_rpc.rpc(rotation)
	
	pass

@rpc("any_peer", "call_remote", "unreliable_ordered")
func set_rotation_rpc(rotation: Vector3):
	#self.rotation = rotation;
	pass
