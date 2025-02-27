extends Control

@onready var menu = $Menu
@onready var loadedmenu = $Menu/TitleMenu

func _load_title_screen(screen: String):
	loadedmenu.queue_free()
	var loaded = load("res://scenes/%s.tscn" % [screen])
	loadedmenu = loaded.instantiate()
	menu.add_child(loadedmenu)

func _mute_music():
	$AudioStreamPlayer2D.stop()
