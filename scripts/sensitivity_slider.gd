extends HSlider

@onready var slider = $"."

func _ready():
	slider.value = Globals.mouse_sensitivity
	drag_ended.connect(_apply)
	
func _apply(changed: bool):
	if changed == false:
		return
	Globals.mouse_sensitivity = slider.value
	Globals._save_settings()
