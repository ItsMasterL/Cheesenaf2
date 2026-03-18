extends Control

@export var username_input: LineEdit
@export var player_list: Label
@export var join_sound: AudioStreamPlayer
@export var hide_from_clients: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready():
	for b in find_children("*", "Button", true):
		b.mouse_entered.connect(_on_button_hover.bind(b.get_index()))
		b.mouse_exited.connect(_on_button_unhover.bind(b.get_index()))
	
	if username_input != null:
		username_input.text = Globals.local_playername
	
	if player_list != null:
		update_player_list()
	
	for i in hide_from_clients:
		i.visible = MultiplayerCore.is_host
	
	MultiplayerCore.player_connected.connect(update_player_list)
	MultiplayerCore.player_disconnected.connect(update_player_list)

func _on_button_hover(sender: int):
	var button = get_child(sender)
	$HoverSound.play()
	button.text = ">>"

func _on_button_unhover(sender: int):
	var button = get_child(sender)
	button.text = String()

func _change_menu(screen: String):
	$"../../"._load_title_screen("title_" + screen)

func _update_username(new_name: String):
	Globals.local_playername = new_name
	Globals._save()

func update_player_list(_player_id = null, _player_info = null):
	if player_list != null:
		join_sound.play()
		player_list.text = ""
		for i in MultiplayerCore.players:
			player_list.text += "%s(%s)\n" % [MultiplayerCore.players[i], i]

func _on_disconnect():
	_change_menu("menu")

func create_passthrough():
	MultiplayerCore.start_server()

func join_passthrough():
	MultiplayerCore.join_server()

func disconnect_passthrough():
	MultiplayerCore.leave_server()

func set_ip(ip: String):
	MultiplayerCore._set_ip(ip)

func set_port(port: String):
	MultiplayerCore._set_port(port)

func start_game():
	MultiplayerCore.start_test.rpc(int(Time.get_unix_time_from_system()))
