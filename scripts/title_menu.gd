extends Control


@export var title_renders: Array[Sprite2D]
@export var visible_render = 0

var time = 4
var opacity = 1
var flicker_timer = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	for b in find_children("*", "Button", true):
		b.mouse_entered.connect(_on_button_hover.bind(b.get_index()))
		b.mouse_exited.connect(_on_button_unhover.bind(b.get_index()))
		# This can be assigned manually
		#b.pressed.connect(_on_button_pressed)
	
	if title_renders.is_empty() == false:
		for render in title_renders:
			render.visible = false
		title_renders[visible_render].visible = true

func _process(delta):
	if title_renders.is_empty() == false:
		time += delta
		if randi_range(0, 60) == 0:
			flicker_timer = randf_range(0.000, 0.100)
		opacity = clampf(abs(sin(time / 4)), 0, 1)
		if opacity <= 0.01:
			title_renders[visible_render].visible = false
			visible_render = randi_range(0, title_renders.size() - 1)
			title_renders[visible_render].visible = true
		if flicker_timer > 0:
			opacity -= 0.25
			flicker_timer = clampf(flicker_timer - delta, 0, 1)
		title_renders[visible_render].self_modulate.a = opacity

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
		Globals.saw_foxy = false
		Globals.saw_foxy_night_1 = false
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
		Globals.safety_time = _calculate_safety()
		Globals.cheesestick = randi_range(0, 5)
		_change_menu("loadoffice")

func _change_menu(screen: String):
	$"../../"._load_title_screen("title_" + screen)

func _open_url(url: String):
	OS.shell_open(url)

func _close_game():
	get_tree().quit()

func _toggle_edams(friendly: bool):
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

func _calculate_safety() -> float:
	var value = (Globals.edam_freddy / 20) + (Globals.edam_bonnie / 20) + (Globals.edam_chica / 20) + (Globals.edam_foxy / 20) + (Globals.wither_freddy / 20) + (Globals.wither_bonnie / 20) + (Globals.wither_chica / 20) + (Globals.wither_foxy / 20) / 8
	if OS.is_debug_build():
		print(str(clampf((3.8 - 3 * value) + 1, 1.5, 5)))
	return clampf((3.8 - 3 * value) + 1, 1.5, 5) # Revisit this
