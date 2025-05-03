extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	var string = tr("GAME_VER") + ProjectSettings.get_setting("application/config/version")
	if OS.is_debug_build():
		string += " (Debug Build)"
	self.text = string
