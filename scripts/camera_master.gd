extends Node3D

@onready var camera_value = 0
@export var sound : AudioStreamPlayer2D

func _process(delta):
	camera_value = clampf(1.5 * sin(Globals.game_time / 2) / 2 + 0.5, 0, 1)
	if camera_value > 0 && camera_value < 1:
		if sound.playing == false:
			sound.play()
	else:
		if sound.playing:
			sound.stop()
