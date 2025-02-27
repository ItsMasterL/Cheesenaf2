extends Control

@onready var text := $RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text.text = "Night %s" % [Globals.night]
	await get_tree().create_timer(2).timeout
	# This stopped working as soon as I made the button click events separate, so I had to move it here
	get_tree().change_scene_to_file("res://scenes/office.tscn")
