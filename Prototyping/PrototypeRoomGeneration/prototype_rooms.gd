extends Node3D

var corner = load("res://Assets/BuildingRooms/CornerRoomRight.tscn")
var basic = load("res://Assets/BuildingRooms/StandardRoom.tscn")
var end = load("res://Assets/BuildingRooms/EndRoom.tscn")

func create_room() -> void:
	var startRoom = load("res://Assets/BuildingRooms/StartRoom.tscn").instantiate()
	add_child(startRoom)
	print("Added Room")
	pass

func _ready() -> void:
	
	pass


func _process(delta: float) -> void:
	create_room()
	pass
