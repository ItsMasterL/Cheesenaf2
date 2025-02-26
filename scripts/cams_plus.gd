extends Control
@onready var cams = $Background/SubViewport/Cameras
@onready var current_cam := $Background/SubViewport/Cameras/Camera4
@onready var light := $Background/SubViewport/Cameras/Camera4/SpotLight3D
@onready var lightsound := $Light
@onready var camsound := $ChangeCam
@onready var root = get_tree().get_root().get_node("Map")

func _change_camera(cam: int):
	current_cam = cams.get_child(cam)
	var lighttemp = light.visible
	light.visible = false
	lightsound.stop()
	light = current_cam.get_child(1)
	light.visible = lighttemp
	current_cam.current = true
	camsound.play()

func _unhandled_input(event):
	if event.is_action_pressed(&"Flashlight") && root.using_tablet:
		light.visible = true
		lightsound.play()
	if event.is_action_released(&"Flashlight"):
		light.visible = false
		lightsound.stop()
