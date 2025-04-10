extends Control


@onready var menu = $Menu
@onready var loaded_menu = $Menu/TitleMenu


func _ready():
	Globals._load()
	Globals._load_settings()

func _load_title_screen(screen: String):
	loaded_menu.queue_free()
	var loaded = load("res://scenes/%s.tscn" % [screen])
	loaded_menu = loaded.instantiate()
	menu.add_child(loaded_menu)

func _mute_music():
	$AudioStreamPlayer2D.stop()
