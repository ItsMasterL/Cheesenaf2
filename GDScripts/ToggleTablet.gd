extends StaticBody3D
@onready var stand := get_parent_node_3d().get_parent_node_3d()
@onready var hold := get_node("../../../Player/Head/Camera3D/TabletHolder")

func _ready() -> void:
	print(stand, ", ", hold)

func _raycast_event() -> void:
	var tablet = get_parent_node_3d()
	var tempparent = tablet.get_parent_node_3d()
	tempparent.remove_child(tablet)
	if stand == tempparent:
		hold.add_child(tablet)
	else:
		stand.add_child(tablet)
	print("Parent is now ", tablet.get_parent_node_3d().name)
	var audio := tablet.get_child(1) as AudioStreamPlayer3D
	audio.play(0)
