extends Node2D

var currentProcess
@onready var home = $Home
@onready var apphome = $Application
@onready var time = $TimeUI/Clock
@onready var root = $"../../../../.."

func _process(delta: float) -> void:
	if root.hour == 0:
		time.text = "12:" + str(root.minute).pad_zeros(2) + " AM"
	else:
		time.text = str(root.hour).pad_zeros(2) + ":" + str(root.minute).pad_zeros(2) + " AM"

func _load_application(appscene: String) -> void:
	if apphome.get_child_count() > 0:
		apphome.get_child(0).queue_free()
	currentProcess = load("res://scenes/" + appscene + ".tscn")
	var instance = currentProcess.instantiate()
	apphome.add_child(instance)
	home.hide()

func _home():
	if apphome.get_child_count() > 0:
		apphome.get_child(0).queue_free()
	home.show()
