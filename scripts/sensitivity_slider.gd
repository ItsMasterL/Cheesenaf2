extends HSlider


func _ready():
	self.value = Globals.mouse_sensitivity
	drag_ended.connect(_apply)
	
func _apply(sensitivity_changed: bool):
	if sensitivity_changed == false:
		return
	Globals.mouse_sensitivity = self.value
	Globals._save_settings()
