extends Node


# Called when the node enters the scene tree for the first time.
const MAX_PLAYERS = 4;
const PORT = 7000;
const DEFAULT_IP = "127.0.0.1"

signal player_connected (id: int);
signal player_disconnected(id: int)

func _ready() -> void:
	multiplayer.peer_disconnected.connect(on_disconnected)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


# connection management
func create_server():
	var peer = ENetMultiplayerPeer.new();
	var e = peer.create_server(PORT, MAX_PLAYERS);
	print(e);
	multiplayer.multiplayer_peer = peer;

func disconnect_from_lobby ():
	var peer = OfflineMultiplayerPeer.new();
	multiplayer.multiplayer_peer = peer;
	print("Disconnected")
	
func join_server(ip: String = DEFAULT_IP):
	var peer = ENetMultiplayerPeer.new();
	var error = peer.create_client(DEFAULT_IP, PORT);
	print(error)
	multiplayer.multiplayer_peer = peer;
	pass 

func on_disconnected(id: int):
	player_disconnected.emit(id);
	
	pass

func check_connection_lcl ():
	check_connection_remote.rpc();
	pass

@rpc("any_peer", "call_local", "reliable")	
func check_connection_remote ():
	print("is server", multiplayer.is_server())
	pass
