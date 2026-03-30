extends Node3D

signal switch_players

@onready var root = get_node(^"/root/Map")
@onready var p1 = root.p1
@onready var p2 = root.p2

func _ready():
	switch_players.connect(_switch_player)

func _switch_player():
	var sync_items: Array
	root.is_p1 = !root.is_p1
	root.p1.get_node("Head/Eyes").current = root.is_p1
	root.p1.get_node("Head/AudioListener3D").current = root.is_p1
	root.p2.get_node("Head/Eyes").current = !root.is_p1
	root.p2.get_node("Head/AudioListener3D").current = !root.is_p1
	if root.is_p1:
		sync_items.append(p1)
		for i in p1.authority_items:
			sync_items.append(i)
		MultiplayerCore.set_authority(p1, multiplayer.get_unique_id())
	else:
		sync_items.append(p2)
		for i in p2.authority_items:
			sync_items.append(i)
		MultiplayerCore.set_authority(p2, multiplayer.get_unique_id())

@rpc("any_peer","call_local","reliable")
func init_player():
	root.is_p1 = !root.is_p1
	root.p1.get_node("Head/Eyes").current = root.is_p1
	root.p1.get_node("Head/AudioListener3D").current = root.is_p1
	root.p2.get_node("Head/Eyes").current = !root.is_p1
	root.p2.get_node("Head/AudioListener3D").current = !root.is_p1

func spectate_switch():
	root.is_p1 = !root.is_p1
	root.p1.get_node("Head/Eyes").current = root.is_p1
	root.p1.get_node("Head/AudioListener3D").current = root.is_p1
	root.p2.get_node("Head/Eyes").current = !root.is_p1
	root.p2.get_node("Head/AudioListener3D").current = !root.is_p1
