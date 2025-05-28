extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_node(^"/root/Map")
	root._jumpscare(root.animatronics.get_child(9))
