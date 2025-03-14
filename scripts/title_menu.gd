extends Control
# Called when the node enters the scene tree for the first time.
func _ready():
	Globals._load()
	
	for b in find_children("*", "Button", false):
		b.mouse_entered.connect(_on_button_hover.bind(b.get_index()))
		b.mouse_exited.connect(_on_button_unhover.bind(b.get_index()))
		# This can be assigned manually
		#b.pressed.connect(_on_button_pressed)

func _on_button_hover(sender: int):
	var button = get_child(sender)
	$HoverSound.play()
	if button.name == "Continue":
		button.text = ">>            Night %s" % [Globals.save_night]
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
	
func _start_singleplayer_custom(night: int = 7):
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$"../../"._mute_music()
	if night < 7:
		Globals._set_night(night)
		_change_menu("loadoffice")
	else:
		Globals.night = 7
		_change_menu("loadoffice")

func _change_menu(screen: String):
	$"../../"._load_title_screen("title_" + screen)

func _toggle_edams(friendly : bool):
	Globals.edams_friendly = friendly
	$ClickSound.play()
	_update_customnight_displays()

func _change_level(animatronic: String, change: int):
	match animatronic:
		"edam_freddy":
			Globals.edam_freddy = clamp(Globals.edam_freddy + change, 0, 20)
		"edam_bonnie":
			Globals.edam_bonnie = clamp(Globals.edam_bonnie + change, 0, 20)
		"edam_chica":
			Globals.edam_chica = clamp(Globals.edam_chica + change, 0, 20)
		"edam_foxy":
			Globals.edam_foxy = clamp(Globals.edam_foxy + change, 0, 20)
		"wither_freddy":
			Globals.wither_freddy = clamp(Globals.wither_freddy + change, 0, 20)
		"wither_bonnie":
			Globals.wither_bonnie = clamp(Globals.wither_bonnie + change, 0, 20)
		"wither_chica":
			Globals.wither_chica = clamp(Globals.wither_chica + change, 0, 20)
		"wither_foxy":
			Globals.wither_foxy = clamp(Globals.wither_foxy + change, 0, 20)
	$ClickSound.play()
	_update_customnight_displays()

func _update_customnight_displays():
	$edam_freddy/Level.text = "%02d" % [Globals.edam_freddy]
	$edam_bonnie/Level.text = "%02d" % [Globals.edam_bonnie]
	$edam_chica/Level.text = "%02d" % [Globals.edam_chica]
	$edam_foxy/Level.text = "%02d" % [Globals.edam_foxy]
	$wither_freddy/Level.text = "%02d" % [Globals.wither_freddy]
	$wither_bonnie/Level.text = "%02d" % [Globals.wither_bonnie]
	$wither_chica/Level.text = "%02d" % [Globals.wither_chica]
	$wither_foxy/Level.text = "%02d" % [Globals.wither_foxy]
	$FriendlyEdams/CheckBox.button_pressed = Globals.edams_friendly
