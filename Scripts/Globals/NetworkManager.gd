extends Node


# Called when the node enters the scene tree for the first time.
const MAX_PLAYERS = 4;
const PORT = 7000;
const DEFAULT_IP = "127.0.0.1"

signal player_connected (id: int);
signal player_disconnected(id: int);

var player_ids: PackedInt32Array = PackedInt32Array();

func _ready() -> void:
	multiplayer.peer_disconnected.connect(on_disconnected)
	multiplayer.peer_connected.connect(on_connected)
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
	player_ids.clear();
	print("Disconnected")
	
func join_server(ip: String = DEFAULT_IP):
	var peer = ENetMultiplayerPeer.new();
	var error = peer.create_client(DEFAULT_IP, PORT);
	print(error)
	multiplayer.multiplayer_peer = peer;
	pass 



func check_connection_lcl ():
	check_connection_remote.rpc();
	pass

@rpc("any_peer", "call_local", "reliable")	
func check_connection_remote ():
	print("is server ", multiplayer.is_server(), " id ", multiplayer.get_unique_id())
	pass
	
func on_disconnected(id: int):
	#player_disconnected.emit(id);
	player_ids.erase(id);
	print(id, " disconnected")
	pass

func on_connected(id: int):
	player_ids.append(id);
	print(id, " connected")
	print_ids()
	pass

@rpc("any_peer", "call_local", "reliable")
func load_level(level_name: String):
	print(multiplayer.get_unique_id())
	get_tree().change_scene_to_file(level_name)

func print_ids():
	if multiplayer.is_server():
		for i in range(len(player_ids)):
			print(player_ids[i])
