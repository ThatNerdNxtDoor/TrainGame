extends Node3D

class_name NetworkedObjectSpawner

@export var spawn_on_start: bool = false
@export var server_object: PackedScene;
@export var client_object: PackedScene;

@export var objectName: String;
var instance_count = 0;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if spawn_on_start && multiplayer.is_server():
		spawn_object_rpc.rpc.call_deferred()

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@rpc("any_peer", "call_local", "reliable")
func spawn_object_rpc ():
	var instance : Node3D;
	if multiplayer.is_server():
		instance = server_object.instantiate();
	else:
		instance = client_object.instantiate();
	
	instance.position = position;
	instance.name = objectName + "_" + str(instance_count) + name
	print("spawned ", instance.name)
	instance_count += 1;
	add_sibling(instance);
	pass
