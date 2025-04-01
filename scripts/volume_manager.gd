extends Node

@onready var audio := $"."
@export_enum("SFX", "Voice", "Music", "Ambient", "Jumpscare") var sound_type
@export var is_in_tablet = false

func _ready():
	_set_volume()

func _set_volume():
	match sound_type:
		0:
			audio.volume_db = linear_to_db(Globals.sfx_volume)
		1:
			audio.volume_db = linear_to_db(Globals.voice_volume)
		2:
			audio.volume_db = linear_to_db(Globals.music_volume)
		3:
			audio.volume_db = linear_to_db(Globals.ambient_volume)
		4:
			audio.volume_db = linear_to_db(Globals.jumpscare_volume)
	
	if is_in_tablet:
		audio.volume *= linear_to_db(Globals.tablet_volume)
