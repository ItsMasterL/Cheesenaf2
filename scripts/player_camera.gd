extends CharacterBody3D
@onready var head := $Head
@onready var camera := $Head/Camera3D
@onready var flashlight := $Head/Camera3D/SpotLight3D
@onready var flashlightsound := $Head/Camera3D/SpotLight3D/FlashlightClick
@onready var root = $".."
@onready var anim := $AnimationPlayer
@onready var breathing := $Head/Breathing
@onready var moving := $Head/MoveUnderDesk
const RAY_LENGTH = 1000.0

func _unhandled_input(event):
	if event.is_action_pressed(&"Flashlight") && root.using_tablet == false:
		flashlight.visible = true
		flashlightsound.play()
	if event.is_action_released(&"Flashlight"):
		flashlight.visible = false
		if root.using_tablet == false:
			flashlightsound.play()
	if event.is_action_pressed(&"HideUnderDesk") && anim.is_playing() == false && root.under_desk == false:
		anim.play(&"desk_hide")
		moving.play()
	if event.is_action_released(&"HideUnderDesk") && anim.is_playing() == false && root.under_desk:
		anim.play(&"desk_hide",-1,-1,true)
		moving.play()
	if event.is_action_pressed(&"LeftClick") && root.using_tablet == false:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed(&"ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * 0.005)
			camera.rotate_x(-event.relative.y * 0.005)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _hidden(state: bool):
	root.under_desk = state

func _breathe():
	breathing.play()

func _stop_breathe():
	breathing.stop()
