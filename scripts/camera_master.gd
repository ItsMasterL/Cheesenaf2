extends Node3D

@onready var camera_value = 0

func _process(delta):
	
	camera_value = clampf(1.5 * sin(Globals.game_time / 2) / 2 + 0.5, 0, 1)
