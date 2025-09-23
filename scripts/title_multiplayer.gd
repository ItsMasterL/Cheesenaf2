extends Control

@onready var username_input = $Username

# Called when the node enters the scene tree for the first time.
func _ready():
	for b in find_children("*", "Button", true):
		b.mouse_entered.connect(_on_button_hover.bind(b.get_index()))
		b.mouse_exited.connect(_on_button_unhover.bind(b.get_index()))
	
	if username_input != null:
		username_input.text = Globals.local_playername

func _on_button_hover(sender: int):
	var button = get_child(sender)
	$HoverSound.play()
	button.text = ">>"

func _on_button_unhover(sender: int):
	var button = get_child(sender)
	button.text = String()

func _change_menu(screen: String):
	$"../../"._load_title_screen("title_" + screen)

func _update_username(new_name: String):
	Globals.local_playername = new_name
	Globals._save()
