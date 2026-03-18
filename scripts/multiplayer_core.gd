extends Node


# TODO: Use these signals for connecting to UI. Another comment below talks about what logic needs to be moved.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

var address = "127.0.0.1"
var port = 17920
var player_limit = 4

var players = {}
var is_host = false
var is_multiplayer = false

# Client
var compression = ENetConnection.COMPRESS_RANGE_CODER


func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

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
	Globals.cmd_scene("title")
	print("Server closed!")

func start_server():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, player_limit)
	if error != OK:
		print("Unable to create server: %s" % [str(error)])
		return
	peer.get_host().compress(compression)
	multiplayer.multiplayer_peer = peer
	
	players[1] = Globals.local_playername
	player_connected.emit(1, Globals.local_playername)
	is_multiplayer = true
	is_host = true

	_register_admin_commands()
	print("Server started!")

func join_server():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		pass
	peer.get_host().compress(compression)
	multiplayer.multiplayer_peer = peer
	is_multiplayer = true
	_register_default_commands()

func leave_server():
	if is_host:
		for i in players:
			multiplayer.multiplayer_peer.disconnect_peer(i)
	multiplayer.multiplayer_peer = null
	players.clear()
	is_multiplayer = false
	is_host = false
	_unregister_commands()
	print("Disconnected from server.")

@rpc("any_peer")
func remove_player(id):
	multiplayer.multiplayer_peer.disconnect_peer(id)

#region Commands

func _register_admin_commands():
	_register_default_commands()

func _register_default_commands():
	LimboConsole.register_command(MultiplayerCore.ping_host,"ping","Pings the server.")
	LimboConsole.register_command(MultiplayerCore.client_info,"clientinfo","Displays your information.")

func _unregister_commands():
	LimboConsole.unregister_command("ping")
	LimboConsole.unregister_command("clientinfo")

func ping_host():
	LimboConsole.print_line("Not implemented")

func client_info():
	LimboConsole.print_line("Is host:" + str(is_host))
	LimboConsole.print_line("Peer ID:" + str(multiplayer.get_unique_id()))

#endregion
