extends Node

enum ROLES {
	ADAM_OFFICE_A,
	PSY_OFFICE_A,
	ADAM_OFFICE_B,
	PSY_OFFICE_B,
}

# TODO: Use these signals for connecting to UI. Another comment below talks about what logic needs to be moved.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal settings_changed
signal all_players_loaded
signal player_loaded

var address = "127.0.0.1"
var port = 17920
var players = {}
var player_roles = {}
var players_ready = {}
var is_host = false
var is_multiplayer = false

# Lobby Settings
var player_limit = 4:
	set(limit):
		player_limit = limit
		if is_host:
			sync_lobby_settings()

var lobby_gamemode = Globals.OfficeMode.CO_OP:
	set(gamemode):
		lobby_gamemode = gamemode
		if is_host:
			sync_lobby_settings()

var lobby_night = 2:
	set(night):
		lobby_night = night
		if is_host:
			sync_lobby_settings()

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
	player_disconnected.emit(id, players[id])
	players.erase(id)

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
	is_multiplayer = false
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
		is_host = false
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	players.clear()
	is_multiplayer = false
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

#region Gameplay Initialization

@rpc("authority","call_remote","reliable")
func send_lobby_settings(gamemode = lobby_gamemode, night = lobby_night, limit = player_limit):
	lobby_gamemode = gamemode
	lobby_night = night
	player_limit = limit

	settings_changed.emit()

func sync_lobby_settings():
	send_lobby_settings.rpc(lobby_gamemode, lobby_night, player_limit)
	#Emitted here since the other emit is remote only
	settings_changed.emit()

@rpc("authority","call_local","reliable")
func start_test(rand_seed: int):
	Globals._set_night(lobby_night)
	Globals.office_mode = lobby_gamemode
	seed(rand_seed)
	# EXTREMELY TEMPORARY
	for i in players:
		if i != 1:
			player_roles[i] = ROLES.PSY_OFFICE_A
		else:
			player_roles[i] = ROLES.ADAM_OFFICE_A
	Globals.set_scene("title_loadoffice")

@rpc("any_peer","call_local","reliable")
func player_ready(id: int):
	players_ready[id] = true
	if players_ready.size() == players.size():
		all_players_loaded.emit()
	else:
		player_loaded.emit()

#endregion

func set_authority(node, id: int):
	var array: Array
	for i in node:
		array.append(i.get_path())
	_sync_authority.rpc(array, id)

@rpc("any_peer","call_local","reliable")
func _sync_authority(node_names: Array, id: int):
	# Hardcoded loading check for now
	while not is_instance_valid(get_node(^"/root/Map")):
		await get_tree().process_frame
		if is_instance_valid(get_node(^"/root/Map")):
			break
	if get_node(^"/root/Map").is_node_ready() == false:
		await get_node(^"/root/Map").ready
	for item in node_names:
		var node = get_node(item)
		node.set_multiplayer_authority(id, true)
