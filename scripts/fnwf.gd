extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_node(^"/root/Map")
	if root.is_p1:
		root._jumpscare(root.animatronics.get_node("PinkSlip"), true)
	else:
		root._jumpscare(root.animatronics.get_node("PinkSlip2"), false)

