extends Node2D


@onready var audio := $Home/AudioStreamPlayer


func _play_audio():
	if Globals.night < 7:
		audio.stream = load("res://sounds/dialogue/c2afton%s.wav" % Globals.night)
		pass
	else:
		audio.stream = load("res://sounds/error.wav")
	audio.play()
