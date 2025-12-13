extends Node


# TODO: Use these signals for connecting to UI. Another comment below talks about what logic needs to be moved.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

@export var address = "127.0.0.1"
@export var port = 17920
@export var player_limit = 4

@export var player_list : Label
@export var join_sound : AudioStreamPlayer

# TODO: if this actually holds players, clean up Globals
var players = {}

# Client
var peer
var compression = ENetConnection.COMPRESS_RANGE_CODER


func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	update_player_list(false)

func _set_ip(input: String):
	address = input

func _set_port(input: String):
	port = str_to_var(input)

# Called on server and clients
func _on_player_connected(id):
	print("Client %s has connected" % [str(id)])
	_register_player.rpc_id(id, Globals.local_playername)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

# Called on server and clients
func _on_player_disconnected(id):
	print("Client %s has disconnected" % [str(id)])
	players.erase(id)
	player_disconnected.emit(id)

# Called on clients
func _on_connected_ok():
	print("Successfully connected to the host!")
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = Globals.local_playername
	player_connected.emit(peer_id, Globals.local_playername)

# Called on clients
func _on_connected_fail():
	print("Unable to connect to server.")
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()

func start_server():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, player_limit)
	if error != OK:
		print("Unable to create server: %s" % [str(error)])
		return
	peer.get_host().compress(compression)
	multiplayer.multiplayer_peer = peer
	
	players[1] = Globals.local_playername
	player_connected.emit(1, Globals.local_playername)
	Globals.is_multiplayer = true
	print("Server started!")

func join_server():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		pass
	peer.get_host().compress(compression)
	multiplayer.multiplayer_peer = peer
	Globals.is_multiplayer = true

func leave_server():
	multiplayer.multiplayer_peer = null
	players.clear()
	Globals.is_multiplayer = false

# TODO: Move to UI and use signals from above.
func update_player_list(playsound = true):
	if player_list != null:
		if playsound:
			join_sound.play()
		player_list.text = ""
		for i in Globals.players:
			player_list.text += "%s(%s)\n" % [Globals.players[i].username, Globals.players[i].id]

@rpc("any_peer")
func remove_player(id):
	multiplayer.multiplayer_peer.disconnect_peer(id)
