extends Node2D

var current_process
@onready var home = $Home
@onready var app_home = $Application
@onready var time = $TimeUI/Clock
@onready var root = $"../../../../.."

func _process(_delta):
	if root.hour == 0:
		time.text = "12:%02d AM" % [root.minute]
	else:
		time.text = "%02d:%02d AM" % [root.hour, root.minute]

func _load_application(appscene: String):
	if app_home.get_child_count() > 0:
		app_home.get_child(0).queue_free()
	current_process = load("res://scenes/%s.tscn" % [appscene])
	var instance = current_process.instantiate()
	app_home.add_child(instance)
	home.hide()

func _home():
	if app_home.get_child_count() > 0:
		app_home.get_child(0).queue_free()
	home.show()
