extends Node3D

var night = 1
var time = 0 as float
var hour = 0
var minute = 0
var fun_multiplier = 1 #Set by minigames in singleplayer to make time go by faster
var time_to_hour = 90
var using_tablet = false
var under_desk = false
var animatronics_in_office = 0
var closed_entrances : Array[int]
var cup_fill = 1
var p1_thirst = 0
# Animatronic AI levels; Animatronics will handle their own paths, timers, etc
var edams_friendly = false
var edam_freddy = 0
var edam_bonnie = 20
var edam_chica = 0
var edam_foxy = 0
var wither_freddy = 0
var wither_bonnie = 0
var wither_chica = 0
var wither_foxy = 0
var cheesestick = 0
# Etc

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += (delta * fun_multiplier)
	hour = floor(time / time_to_hour)
	minute = floor(lerp(hour * 60, hour * 60 + 60, time / time_to_hour)) as int % 60
	p1_thirst += (delta * 0.05) * fun_multiplier

func _get_ai(animatronic: String) -> int:
	match animatronic:
		"edam_freddy":
			return edam_freddy
		"edam_bonnie":
			return edam_bonnie
		"edam_chica":
			return edam_chica
		"edam_foxy":
			return edam_foxy
		"wither_freddy":
			return wither_freddy
		"wither_bonnie":
			return wither_bonnie
		"wither_chica":
			return wither_chica
		"wither_foxy":
			return wither_foxy
		"cheesestick":
			return cheesestick
	return 0

func _jumpscare(animatronic: Node3D):
	animatronic.position = Vector3(0, -0.719, -2)
	animatronic.rotation_degrees = Vector3(0, -90, 0)
	var anim : AnimationPlayer = animatronic.get_child(1)
	var sound : AudioStreamPlayer = animatronic.get_child(2)
	anim.play(animatronic.jumpscare_animation_id)
	sound.play()
	await get_tree().create_timer(animatronic.jumpscare_length).timeout
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/title.tscn")
