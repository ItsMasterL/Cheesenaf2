extends Control


@onready var door_buttons = $"Control Buttons"
@onready var root = get_tree().get_root().get_node("Map")
@onready var dark = $Messages/DarkenBg
@onready var error = $Messages/ErrorMessagebox
@onready var jam = $Messages/JammedMessagebox
@onready var wait = $Messages/Loadingbox
@onready var audio = $AudioFeedback


func _ready():
	for i in root.closed_entrances:
		door_buttons.get_child(i).button_pressed = true

func _check_and_seal():
	var seals: Array[int]
	var i = 0
	for button in door_buttons.get_children():
		if button.button_pressed:
			seals.append(i)
		i += 1
	dark.visible = true
	wait.visible = true
	await get_tree().create_timer(3.25).timeout
	wait.visible = false
	if seals.size() > 2:
		seals = root.closed_entrances
		error.visible = true
		audio.stream = load("res://sounds/vm_fail.wav")
	else:
		for j in root.jammed_entrances:
			if (j in seals && not j in root.closed_entrances) || (j in root.closed_entrances && not j in seals):
				seals = root.closed_entrances
				jam.visible = true
				audio.stream = load("res://sounds/vm_fail.wav")
				audio.play()
				return
		dark.visible = false
		audio.stream = load("res://sounds/vm_success.wav")
		root._set_entrances(seals)
	audio.play()

func _clear_error_message():
	error.visible = false
	jam.visible = false
	dark.visible = false
