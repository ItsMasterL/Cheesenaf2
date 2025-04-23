extends CheckBox


func _ready():
	self.button_pressed = Globals.fullscreen
	pressed.connect(_apply)
	
func _apply():
	Globals.fullscreen = self.button_pressed
	Globals._save_settings()
	Globals._load_settings()
