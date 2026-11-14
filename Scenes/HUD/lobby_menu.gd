extends Control


@export_file_path("*.tscn") var levelScene = "res://Scenes/World/TestScene.tscn";
@onready var textBox = $Panel/TextBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func load_level():
	NetworkManager.load_level.rpc(levelScene)
	pass

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
	
func _process (delta: float):
	var is_server = multiplayer.is_server()
	textBox.text = ("host" if is_server else "client") + " number of players" + str(len(NetworkManager.player_ids));
	pass
