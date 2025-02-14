extends Node2D

var current_process
@onready var home = $Home
@onready var app_home = $Application
@onready var time = $TimeUI/Clock
@onready var root = $"../../../../.."

func _process(_delta):
	if root.hour == 0:
		time.text = "12:" + str(root.minute).pad_zeros(2) + " AM"
	else:
		time.text = str(root.hour).pad_zeros(2) + ":" + str(root.minute).pad_zeros(2) + " AM"

func _load_application(appscene: String):
	if app_home.get_child_count() > 0:
		app_home.get_child(0).queue_free()
	current_process = load("res://scenes/" + appscene + ".tscn")
	var instance = current_process.instantiate()
	app_home.add_child(instance)
	home.hide()

func _home():
	if app_home.get_child_count() > 0:
		app_home.get_child(0).queue_free()
	home.show()
