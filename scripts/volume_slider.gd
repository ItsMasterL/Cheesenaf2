extends HSlider

@export_enum("Master", "SFX", "Voice", "Music", "Ambient", "Jumpscare", "Tablet") var sound_type
@onready var slider := $"."
@onready var test_sound := $"../../TestSound"

func _ready():
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(sound_type))
	drag_ended.connect(_apply_and_test)

func _apply_and_test(changed: bool):
	if changed == false:
		return
	AudioServer.set_bus_volume_db(sound_type, linear_to_db(slider.value))
	test_sound.bus = AudioServer.get_bus_name(sound_type)
	match sound_type:
		0:
			Globals.master_volume = slider.value
		1:
			Globals.sfx_volume = slider.value
		2:
			Globals.voice_volume = slider.value
		3:
			Globals.music_volume = slider.value
		4:
			Globals.ambient_volume = slider.value
		5:
			Globals.jumpscare_volume = slider.value
		6:
			Globals.tablet_volume = slider.value
	Globals._save_settings()
	test_sound.play()
