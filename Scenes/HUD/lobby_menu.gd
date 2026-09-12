extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func create_game():
	NetworkManager.create_server()
	pass
	
func connect_to_game():
	NetworkManager.join_server();
	pass
	
func disconnect_game():
	NetworkManager.disconnect_from_lobby()
	pass
	
func ping ():
	NetworkManager.check_connection_lcl()
	pass
