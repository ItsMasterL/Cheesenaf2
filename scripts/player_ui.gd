extends Control

@export var info_label: Control
@export var sabotage_name: Control
@export var sabotage_description: Control
@export var spectate_overlay: Node
@export var anim: AnimationPlayer

@onready var root = get_node(^"/root/Map")

func _ready():
	root.sabotage_begin.connect(_sabotage_notif)
	root.player_spectating.connect(_spectate)

func _process(delta):
	if OS.is_debug_build():
		var builder = ""
		builder += str(roundi(1/delta)) + " FPS"

		info_label.text = builder

func _sabotage_notif(_sabotage = null):
	sabotage_name.text = "[wave]" + root.sabotage_name
	sabotage_description.text = root.sabotage_description
	anim.play("sabotage_notification")

func _spectate():
	anim.play("spectate_begin")
