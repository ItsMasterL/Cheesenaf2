extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var string = "\n[wave]Version " + ProjectSettings.get_setting("application/config/version")
	if OS.is_debug_build():
		string += " (Debug Build)"
	$".".text = string
