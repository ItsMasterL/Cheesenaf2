extends HSlider

@export_enum("SFX", "Voice", "Music", "Ambient", "Jumpscare", "Tablet") var sound_type
@onready var slider := $"."
@onready var test_sound := $"../TestSound"

func _ready():
	match sound_type:
		0:
			slider.value = Globals.sfx_volume
		1:
			slider.value = Globals.voice_volume
		2:
			slider.value = Globals.music_volume
		3:
			slider.value = Globals.ambient_volume
		4:
			slider.value = Globals.jumpscare_volume
		5:
			slider.value = Globals.tablet_volume
	
	drag_ended.connect(_apply_and_test)

func _apply_and_test(changed: bool):
	if changed == false:
		return
	test_sound.is_in_tablet
	match sound_type:
		"SFX":
			Globals.sfx_volume = slider.value
			test_sound.sound_type = "SFX"
		"Voice":
			Globals.voice_volume = slider.value
			test_sound.sound_type = "Voice"
		"Music":
			Globals.music_volume = slider.value
			test_sound.sound_type = "Music"
		"Ambient":
			Globals.ambient_volume = slider.value
			test_sound.sound_type = "Ambient"
		"Jumpscare":
			Globals.jumpscare_volume = slider.value
			test_sound.sound_type = "Jumpscare"
		"Tablet":
			Globals.tablet_volume = slider.value
			test_sound.sound_type = null
			test_sound.is_in_tablet = true
	Globals._save_settings()
	test_sound._set_volume()
	test_sound.play()
