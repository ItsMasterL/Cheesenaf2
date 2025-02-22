extends StaticBody3D
@onready var stand := $"../.."
@onready var hold := $"../../../Player/Head/Camera3D/CupHolder"
@onready var root = $"../../.."

func _ready():
	print(stand, ", ", hold)

func _raycast_event():
	var tablet = get_parent_node_3d()
	var temp_parent = tablet.get_parent_node_3d()
	if stand == temp_parent:
		temp_parent.remove_child(tablet)
		hold.add_child(tablet)
		var audio := tablet.get_child(1)
		var anim := tablet.get_child(2)
		if (root.cup_fill > 0):
			audio.play()
		anim.play(&"cup_drink")

func _end_drink():
	var tablet = get_parent_node_3d()
	var temp_parent = tablet.get_parent_node_3d()
	temp_parent.remove_child(tablet)
	stand.add_child(tablet)
	root.cup_fill = clamp(root.cup_fill - root.p1_thirst, 0, 1)
	root.p1_thirst = 0
