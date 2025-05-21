extends StaticBody3D


@onready var stand := $"../.."
@onready var hold := $"../../../Player/Head/Eyes/TabletHolder"
@onready var tablet = $".."
@onready var home_button = $"../HomeButton"
@onready var audio := $"../AudioStreamPlayer"
@onready var cursor := $"../../../Player/Head/Eyes/Cursor"
@onready var root = $"../../.."
@onready var anim := $"../AnimationPlayer"

func _raycast_event():
	if root.p1_has_tablet == false:
		return
	var temp_parent = tablet.get_parent_node_3d()
	if root.using_tablet == false:
		temp_parent.remove_child(tablet)
		hold.add_child(tablet)
		anim.play(&"flipup", -1, 1, false)
		root.using_tablet = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		cursor.hide()
		audio.play()
		if root.night == 1:
			$"../Tutorial".visible = true
	elif home_button.is_mouse_inside == true and tablet.is_mouse_inside == false:
		$"../ScreenQuad/TabletScreen/TabletOS"._home()
	elif tablet.is_mouse_inside == false:
		temp_parent.remove_child(tablet)
		stand.add_child(tablet)
		root.using_tablet = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		cursor.show()
		audio.play()
		$"../Tutorial".visible = false
