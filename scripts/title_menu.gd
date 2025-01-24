extends Control

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready():
	for b in find_children("*", "Button"):
		b.mouse_entered.connect(_on_button_hover.bind(b.get_index()))
		b.mouse_exited.connect(_on_button_unhover.bind(b.get_index()))
		b.pressed.connect(_on_button_pressed)

func _on_button_hover(sender: int):
	var button = get_child(sender)
	$HoverSound.play()
	button.text = ">>"

func _on_button_unhover(sender: int):
	var button = get_child(sender)
	button.text = ""

func _on_button_pressed():
	start_game.emit()
