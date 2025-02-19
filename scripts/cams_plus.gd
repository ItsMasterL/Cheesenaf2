extends Control
@onready var cams = $Background/SubViewport/Cameras
@onready var current_cam := $Background/SubViewport/Cameras/Camera1
@onready var light := $Background/SubViewport/Cameras/Camera1/SpotLight3D
@onready var lightsound := $Light
@onready var camsound := $ChangeCam

func _change_camera(cam: int):
	current_cam = cams.get_child(cam)
	light.visible = false
	lightsound.stop()
	light = current_cam.get_child(1)
	current_cam.current = true
	camsound.play()

func _unhandled_input(event):
	if event.is_action_pressed(&"Flashlight"):
		light.visible = true
		lightsound.play()
	if event.is_action_released(&"Flashlight"):
		light.visible = false
		lightsound.stop()
