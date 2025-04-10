extends CharacterBody3D


const RAY_LENGTH = 1000.0

@onready var head := $Head
@onready var camera := $Head/Eyes
@onready var flashlight := $Head/Eyes/SpotLight3D
@onready var flashlight_sound := $Head/Eyes/SpotLight3D/FlashlightClick
@onready var root = $".."
@onready var anim := $AnimationPlayer
@onready var breathing := $Head/Breathing
@onready var moving := $Head/MoveUnderDesk


func _unhandled_input(event):
	if root.p1_can_action:
		if event.is_action_pressed(&"Flashlight") && root.using_tablet == false:
			flashlight.visible = true
			flashlight_sound.play()
		if event.is_action_released(&"Flashlight"):
			flashlight.visible = false
			if root.using_tablet == false:
				flashlight_sound.play()
		if event.is_action_pressed(&"HideUnderDesk") && anim.is_playing() == false && root.under_desk == false:
			anim.play(&"desk_hide")
			moving.play()
		if event.is_action_released(&"HideUnderDesk") && anim.is_playing() == false && root.under_desk:
			anim.play(&"desk_hide", -1, -1, true)
			moving.play()
	if event.is_action_pressed(&"LeftClick") && root.using_tablet == false:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed(&"ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE && root.using_tablet == false:
			get_tree().change_scene_to_file("res://scenes/title.tscn")
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * (0.005 * Globals.mouse_sensitivity))
			camera.rotate_x(-event.relative.y * (0.005 * Globals.mouse_sensitivity))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _hidden(state: bool):
	root.under_desk = state

func _breathe():
	breathing.play()

func _stop_breathe():
	breathing.stop()
