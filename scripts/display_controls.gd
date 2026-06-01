extends Label3D

@export var p1 = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if p1:
		self.text = tr("TUTORIAL_KEYS").format({"hide_key": InputMap.action_get_events("HideUnderDesk")[0].as_text().to_upper(), "flash_key": InputMap.action_get_events("Flashlight")[0].as_text().to_upper(), "interact_key": InputMap.action_get_events("Interact")[0].as_text().to_upper()}).replace(" (PHYSICAL)","")
	else:
		self.text = tr("TUTORIAL_KEYS2").format({"hide_key": InputMap.action_get_events("LaptopLid")[0].as_text().to_upper(), "flash_key": InputMap.action_get_events("Flashlight")[0].as_text().to_upper(), "interact_key": InputMap.action_get_events("Interact")[0].as_text().to_upper(), "home_key": InputMap.action_get_events("LaptopHome")[0].as_text().to_upper()}).replace(" (PHYSICAL)","")
