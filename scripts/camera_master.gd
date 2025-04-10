@tool
extends Node3D


var camera_value = 0
var editor_value = 0

@export var sound: AudioStreamPlayer2D


func _process(delta):
	if Engine.is_editor_hint() == false:
		camera_value = clampf(1.5 * sin(Globals.game_time / 2.0) / 2 + 0.5, 0, 1)
		if camera_value > 0 && camera_value < 1:
			if sound.playing == false:
				sound.play()
		else:
			if sound.playing:
				sound.stop()
	else:
		editor_value += delta
		camera_value = clampf(1.5 * sin(editor_value) / 2 + 0.5, 0, 1)
