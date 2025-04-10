extends Node


@onready var head := $Head
@onready var camera := $Head/Eyes


func _unhandled_input(event):
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * (0.005 * Globals.mouse_sensitivity))
		camera.rotate_x(-event.relative.y * (0.005 * Globals.mouse_sensitivity))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	if event.is_action_pressed(&"ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
