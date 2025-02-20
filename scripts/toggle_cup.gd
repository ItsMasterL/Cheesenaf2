extends StaticBody3D
@onready var stand := $"../.."
@onready var hold := $"../../../Player/Head/Camera3D/CupHolder"

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
		audio.play()
		anim.play(&"cup_drink")

func _end_drink():
	var tablet = get_parent_node_3d()
	var temp_parent = tablet.get_parent_node_3d()
	temp_parent.remove_child(tablet)
	stand.add_child(tablet)
