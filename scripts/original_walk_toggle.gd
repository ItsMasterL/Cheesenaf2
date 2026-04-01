extends CheckBox

func _ready():
	self.button_pressed = Globals.original_walk
	pressed.connect(_apply)
	
func _apply():
	Globals.original_walk = self.button_pressed
	Globals._save_settings()
	Globals._load_settings()
