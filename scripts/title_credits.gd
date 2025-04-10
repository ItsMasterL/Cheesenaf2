extends Control


@onready var credits = $Credits


# Called when the node enters the scene tree for the first time.
func _ready():
	$"../../"._mute_music()
	$Music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	credits.position = Vector2(credits.position.x, credits.position.y - (delta * 25))

func _return():
	get_tree().reload_current_scene()
