extends Node3D

signal set_active_player

@onready var root = get_node(^"/root/Map")
@onready var p1 = root.p1
@onready var p2 = root.p2

func _ready():
	set_active_player.connect(_switch_player)

func _switch_player(): #This will need modification to work over network
	root.is_p1 = !root.is_p1
	root.p1.get_node("Head/Eyes").current = root.is_p1
	root.p1.get_node("Head/AudioListener3D").current = root.is_p1
	root.p2.get_node("Head/Eyes").current = !root.is_p1
	root.p2.get_node("Head/AudioListener3D").current = !root.is_p1
