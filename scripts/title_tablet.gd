extends Control

func _ready():
	$"../../"._mute_music()

func _return():
	get_tree().reload_current_scene()
