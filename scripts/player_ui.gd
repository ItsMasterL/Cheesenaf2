extends Control

@export var info_label: Control
@export var sabotage_name: Control
@export var sabotage_description: Control
@export var spectate_overlay: Node
@export var anim: AnimationPlayer

@onready var root = get_node(^"/root/Map")

var player_wait_list = ""
var player_disconnect = ""

func _ready():
	root.sabotage_begin.connect(_sabotage_notif)
	root.player_spectating.connect(_spectate)
	MultiplayerCore.player_loaded.connect(_update_wait_list)
	MultiplayerCore.all_players_loaded.connect(_clear_wait_list)
	MultiplayerCore.player_disconnected.connect(_update_disconnect)

func _process(delta):
	var builder = ""
	if OS.is_debug_build():
		builder += str(roundi(1/delta)) + " FPS\n"
	builder += player_wait_list
	builder += player_disconnect
	info_label.text = builder

func _sabotage_notif(_sabotage = null):
	sabotage_name.text = "[wave]" + root.sabotage_name
	sabotage_description.text = root.sabotage_description
	anim.play("sabotage_notification")

func _spectate():
	anim.play("spectate_begin")

func _update_wait_list():
	var builder = ""
	for p in MultiplayerCore.players:
		if p not in MultiplayerCore.players_ready:
			builder += MultiplayerCore.players[p] + " [LOADING]"
		else:
			builder += MultiplayerCore.players[p] + " ✓"
	player_wait_list = builder

func _clear_wait_list():
	player_wait_list = ""

func _update_disconnect(_id = null, playername = "Someone"):
	player_disconnect += playername + " has disconnected.\n"
	await get_tree().create_timer(5).timeout
	player_disconnect = player_disconnect.replace(playername + " has disconnected.\n", "")
