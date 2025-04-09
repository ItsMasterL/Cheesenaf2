extends Button

func _reset_audio():
		Globals.master_volume = 1
		Globals.sfx_volume = 1
		Globals.voice_volume = 1
		Globals.music_volume = 1
		Globals.ambient_volume = 1
		Globals.jumpscare_volume = 1
		Globals.tablet_volume = 1
		Globals._save_settings()
		Globals._load_settings()
		for child in 7:
			$"..".get_child(child).value = 1

func _test_sensitivity():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _reset_sensitivity():
	Globals.mouse_sensitivity = 1
	$"..".get_child(0).value = 1
