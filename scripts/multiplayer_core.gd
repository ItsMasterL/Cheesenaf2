extends Node

@export var address = "127.0.0.1"
@export var port = 17920
@export var player_limit = 4

@export var player_list : Label
@export var join_sound : AudioStreamPlayer

# Client
var peer
var compression = ENetConnection.COMPRESS_RANGE_CODER

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
	update_player_list(false)

func _set_ip(input: String):
	address = input

func _set_port(input: String):
	port = str_to_var(input)

# Called on server and clients
func peer_connected(id):
	print("Client %s has connected" % [str(id)])
# Called on server and clients
func peer_disconnected(id):
	print("Client %s has disconnected" % [str(id)])
	Globals.players.erase(id)
	update_player_list()
# Called on clients
func connected_to_server():
	print("Successfully connected to the host!")
	send_info.rpc_id(1, Globals.local_playername, multiplayer.get_unique_id())
# Called on clients
func connection_failed():
	print("Unable to connect to server.")

func start_server():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, player_limit)
	if error != OK:
		print("Unable to create server: %s" % [str(error)])
		return
	peer.get_host().compress(compression)
	# Sets host to be a peer
	multiplayer.set_multiplayer_peer(peer)
	send_info(Globals.local_playername, multiplayer.get_unique_id())
	Globals.is_host = true
	Globals.is_multiplayer = true
	print("Server started!")

func join_server():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(compression)
	multiplayer.set_multiplayer_peer(peer)
	Globals.is_host = false
	Globals.is_multiplayer = true

func leave_server():
	remove_player.rpc_id(1,multiplayer.get_unique_id())
	Globals.players.clear()
	Globals.is_multiplayer = false

func update_player_list(playsound = true):
	if player_list != null:
		if playsound:
			join_sound.play()
		player_list.text = ""
		for i in Globals.players:
			player_list.text += "%s(%s)\n" % [Globals.players[i].username, Globals.players[i].id]


@rpc("any_peer")
func send_info(username, id):
	if !Globals.players.has(id):
		Globals.players[id] = {
			"username": username,
			"id": id
		}
	
	update_player_list()
	
	if multiplayer.is_server():
		for i in Globals.players:
			send_info.rpc(Globals.players[i].username, i)

@rpc("any_peer")
func remove_player(id):
	multiplayer.multiplayer_peer.disconnect_peer(id)
