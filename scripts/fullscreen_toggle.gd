extends CheckBox


@onready var check = $"."


func _ready():
	check.button_pressed = Globals.fullscreen
	pressed.connect(_apply)
	
func _apply():
	Globals.fullscreen = check.button_pressed
	Globals._save_settings()
	Globals._load_settings()
