extends StaticBody3D
@onready var stand := $"../.."
@onready var hold := $"../../../Player/Head/Camera3D/TabletHolder"
@onready var tablet = $".."
@onready var homebutton = $"../HomeButton"
@onready var audio := $"../AudioStreamPlayer3D"
@onready var cursor := $"../../../Player/Head/Camera3D/Cursor"

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
		cursor.hide()
		audio.play()
	elif homebutton.is_mouse_inside == true && tablet.is_mouse_inside == false:
		get_node(^"../ScreenQuad/TabletScreen/TabletOS")._home()
	elif tablet.is_mouse_inside == false:
		tempparent.remove_child(tablet)
		stand.add_child(tablet)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		cursor.show()
		audio.play()
