extends Control

var modulate_timer = -0.6

# Called when the node enters the scene tree for the first time.
func _ready():
	$Time.text = "%02d:%02.2d" % [floor(Globals.game_time / 60), fmod(Globals.game_time, 60)]
	await get_tree().create_timer(5.5).timeout
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _process(delta):
	modulate_timer += delta/3
	$Time.modulate = Color.WHITE * modulate_timer
