extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = get_tree().get_root().get_node("Map")
	root._jumpscare(root.animatronics.get_child(9))
