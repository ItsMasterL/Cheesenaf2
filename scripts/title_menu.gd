extends Control
# Called when the node enters the scene tree for the first time.
func _ready():
	Globals._load()
	
	for b in find_children("*", "Button"):
		b.mouse_entered.connect(_on_button_hover.bind(b.get_index()))
		b.mouse_exited.connect(_on_button_unhover.bind(b.get_index()))
		# This can be assigned manually
		#b.pressed.connect(_on_button_pressed)

func _on_button_hover(sender: int):
	var button = get_child(sender)
	$HoverSound.play()
	if button.name == "Continue":
		button.text = ">>           %s" % [Globals.save_night]
	else:
		button.text = ">>"

func _on_button_unhover(sender: int):
	var button = get_child(sender)
	button.text = String()

func _start_singleplayer(load_night: bool = false):
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if load_night:
		Globals._set_night(Globals.save_night)
	else:
		Globals._set_night(1)
	$"../../"._mute_music()
	_change_menu("loadoffice")

func _change_menu(screen: String):
	$"../../"._load_title_screen("title_" + screen)

# Keep at bottom for organization's sake
