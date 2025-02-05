extends StaticBody3D
@onready var stand := get_parent_node_3d().get_parent_node_3d()
@onready var hold := get_node(^"../../../Player/Head/Camera3D/TabletHolder")
@onready var tablet = get_parent_node_3d()
@onready var audio := tablet.get_child(1) as AudioStreamPlayer3D

func _ready():
	print(stand, ", ", hold)

func _raycast_event():
	var tempparent = tablet.get_parent_node_3d()
	var anim := tablet.get_child(2) as AnimationPlayer
	if stand == tempparent:
		tempparent.remove_child(tablet)
		hold.add_child(tablet)
		anim.play(&"flipup", -1, 1, false)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		audio.play()
	elif tablet.is_mouse_inside == false:
		tempparent.remove_child(tablet)
		stand.add_child(tablet)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		audio.play()
