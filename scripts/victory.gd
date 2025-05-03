extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$"5_6/AnimationPlayer".play("default")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().create_timer(5.5).timeout
	$Yay.play()
	var pay = randf_range(8.00, 11.99)
	Globals.money += pay
	$Stats.text = tr("NIGHT_END_TIME") + " %02d:%02.2d\n" % [floor(Globals.game_time / 60), fmod(Globals.game_time, 60)] + tr("NIGHT_END_PAY") + " $%1.2d" % pay
	$Stats.visible = true
	Globals._save()
	await get_tree().create_timer(7.5).timeout
	if Globals.night < 5:
		Globals._set_night(Globals.save_night)
		get_tree().change_scene_to_file("res://scenes/title_loadoffice.tscn")
	elif Globals.night == 5:
		get_tree().change_scene_to_file("res://scenes/paycheck5.tscn")
	elif Globals.night == 7:
		if Globals.edam_bonnie == 20 && Globals.edam_chica == 20 && Globals.edam_foxy == 20 && Globals.edam_freddy == 20 && Globals.edams_friendly == false:
			if Globals.wither_bonnie == 20 && Globals.wither_chica == 20 && Globals.wither_foxy == 20 && Globals.wither_freddy == 20:
				get_tree().change_scene_to_file("res://scenes/paycheck820.tscn")
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file("res://scenes/title.tscn")
