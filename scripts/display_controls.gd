extends Label3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.text = tr("TUTORIAL_KEYS").format({"hide_key": InputMap.action_get_events("HideUnderDesk")[0].as_text().to_upper(), "flash_key": InputMap.action_get_events("Flashlight")[0].as_text().to_upper(), "interact_key": InputMap.action_get_events("Interact")[0].as_text().to_upper()}).replace(" (PHYSICAL)","")
