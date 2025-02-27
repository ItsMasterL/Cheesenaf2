extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"5_6/AnimationPlayer".play("default")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().create_timer(13).timeout
	if Globals.night < 5:
		Globals._set_night(Globals.save_night)
		get_tree().change_scene_to_file("res://scenes/title_loadoffice.tscn")
	elif Globals.night == 5:
		get_tree().change_scene_to_file("res://scenes/paycheck5.tscn")
	else:
		#TODO: Make proper end screen
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file("res://scenes/title.tscn")
		
