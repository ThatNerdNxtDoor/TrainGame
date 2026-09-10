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
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new();
	
func join_server(ip: String):
	var peer = ENetMultiplayerPeer.new();
	peer.create_client(DEFAULT_IP, PORT);
	pass

func on_disconnected(id: int):
	player_disconnected.emit(id);
	
	pass
