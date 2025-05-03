extends RichTextLabel

@export var file : String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var textfile = FileAccess.open("res://texts/%s" % file, FileAccess.READ)
	self.text = textfile.get_as_text()
