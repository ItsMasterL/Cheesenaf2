extends Control

func _ready():
	$"../../"._mute_music()
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Tablet"),0,false)

func _return():
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Tablet"),0,true)
	get_tree().reload_current_scene()
