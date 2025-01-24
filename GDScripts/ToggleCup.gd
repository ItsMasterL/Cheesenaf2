extends StaticBody3D
@onready var stand := get_parent_node_3d().get_parent_node_3d()
@onready var hold := get_node("../../../Player/Head/Camera3D/CupHolder")

func _ready():
	print(stand, ", ", hold)

func _raycast_event():
	var tablet = get_parent_node_3d()
	var tempparent = tablet.get_parent_node_3d()
	if stand == tempparent:
		tempparent.remove_child(tablet)
		hold.add_child(tablet)
		var audio := tablet.get_child(1) as AudioStreamPlayer3D
		var anim := tablet.get_child(2) as AnimationPlayer
		audio.play(0)
		anim.play("cup_drink")

func _end_drink():
	var tablet = get_parent_node_3d()
	var tempparent = tablet.get_parent_node_3d()
	tempparent.remove_child(tablet)
	stand.add_child(tablet)
