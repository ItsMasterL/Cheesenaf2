extends HSlider

enum SoundType {
	MASTER,
	SFX,
	VOICE,
	MUSIC,
	AMBIENT,
	JUMPSCARE,
	TABLET,
}

@export var sound_type: SoundType

@onready var test_sound := $"../../TestSound"


func _ready():
	self.value = db_to_linear(AudioServer.get_bus_volume_db(sound_type))
	drag_ended.connect(_apply_and_test)

func _apply_and_test(volume_changed: bool):
	if volume_changed == false:
		return
	AudioServer.set_bus_volume_db(sound_type, linear_to_db(self.value))
	test_sound.bus = AudioServer.get_bus_name(sound_type)
	match sound_type:
		SoundType.MASTER:
			Globals.master_volume = self.value
		SoundType.SFX:
			Globals.sfx_volume = self.value
		SoundType.VOICE:
			Globals.voice_volume = self.value
		SoundType.MUSIC:
			Globals.music_volume = self.value
		SoundType.AMBIENT:
			Globals.ambient_volume = self.value
		SoundType.JUMPSCARE:
			Globals.jumpscare_volume = self.value
		SoundType.TABLET:
			Globals.tablet_volume = self.value
	Globals._save_settings()
	test_sound.play()
