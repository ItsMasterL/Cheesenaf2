extends Control


@onready var text := $RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.night < 7:
		text.text = "[center]%s %s" % [tr("NIGHT"), Globals.night]
	else:
		text.text = "[center]%s" % tr("CUSTOM_NIGHT")
	await get_tree().create_timer(1.25).timeout
	# This stopped working as soon as I made the button click events separate, so I had to move it here
	get_tree().change_scene_to_file("res://scenes/office.tscn")
