extends Button

var MainGame = preload("res://Scenes/office.tscn").instantiate()

func _ready():
	var button := get_node(".") as Button
	button.text = ""
	button.pressed.connect(self._button_pressed)
	button.mouse_entered.connect(self._button_hover)
	button.mouse_exited.connect(self._button_unhover)
	add_child(button)

func _button_pressed():
	var tree = get_tree() as SceneTree
	tree.change_scene_to_file("res://Scenes/office.tscn")

func _button_hover():
	var audio := get_node("AudioStreamPlayer2D") as AudioStreamPlayer2D
	var button := get_node(".") as Button
	audio.play()
	button.text = ">> "

func _button_unhover():
	var button := get_node(".") as Button
	button.text = ""
