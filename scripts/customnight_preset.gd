extends Label

@export var night : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.text = tr("CUSTOM_START_BASE") + str(night)
