extends Control

@export var keybind_button : PackedScene
@export var button_continer : Node
@export var hoversound : AudioStreamPlayer

var active_bind = null

func _ready():
	for bind in InputMap.get_actions():
		if "ui_" in bind or "limbo" in bind:
			continue
		var keybind = keybind_button.instantiate()
		keybind.name = bind
		keybind.get_node("BindButton/BindName").text = bind
		keybind.get_node("BindButton/Key").text = InputMap.action_get_events(bind)[0].as_text().trim_suffix("(Physical)")
		keybind.get_node("BindButton").mouse_entered.connect(_on_button_hover.bind(keybind.get_node("BindButton")))
		keybind.get_node("BindButton").mouse_exited.connect(_on_button_unhover.bind(keybind.get_node("BindButton")))
		keybind.get_node("BindButton").pressed.connect(_rebind.bind(keybind))
		button_continer.add_child(keybind)

func _input(event):
	if active_bind != null:
		if event is InputEventKey or event is InputEventMouseButton:
			if event is InputEventMouseButton or event.physical_keycode != KEY_ESCAPE:
				InputMap.action_erase_events(active_bind)
				if event is InputEventKey:
					Globals.keybind_overrides[active_bind] = "k" + str(event.keycode)
				else:
					Globals.keybind_overrides[active_bind] = "m" + str(event.button_index)
				InputMap.action_add_event(active_bind, event)
				print("Set " + active_bind + " to " + InputMap.action_get_events(active_bind)[0].as_text().trim_suffix("(Physical)"))
				Globals._save_settings()
			button_continer.get_node(active_bind + "/BindButton/Key").text = InputMap.action_get_events(active_bind)[0].as_text().trim_suffix("(Physical)")
			active_bind = null

func _on_button_hover(sender):
	hoversound.play()
	if "text" in sender:
		sender.text = ">>"

func _on_button_unhover(sender):
	if "text" in sender:
		sender.text = String()

func _rebind(sender):
	active_bind = sender.get_node("BindButton/BindName").text
	sender.get_node("BindButton/Key").text = String()
