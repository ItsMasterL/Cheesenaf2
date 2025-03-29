extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"surprisingly not placeholder/AnimationPlayer".play("adam_dance")
	Globals.money += 16
	Globals._save()
	await get_tree().create_timer(15).timeout
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/title.tscn")
