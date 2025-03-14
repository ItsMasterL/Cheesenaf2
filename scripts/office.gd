extends Node3D

@onready var blur := $BlurShader/ColorRect

var night = Globals.night
var time = 0 as float
var hour = 0
var minute = 0
var fun_multiplier = 1 #Set by minigames in singleplayer to make time go by faster
const time_to_hour = 90
var using_tablet = false
var in_cams = false
var under_desk = false
var animatronics_in_office = 0
var closed_entrances : Array[int]
var cup_fill = 1
var fan_powered = true
var p1_thirst = 0
var p1_heat = 0
var musicbox = 2000
var is_winding = false
var musicbox_ran_out = false
# Animatronic AI levels; Animatronics will handle their own paths, timers, etc
var edams_friendly = Globals.edams_friendly
var edam_freddy = Globals.edam_freddy
var edam_bonnie = Globals.edam_bonnie
var edam_chica = Globals.edam_chica
var edam_foxy = Globals.edam_foxy
var wither_freddy = Globals.wither_freddy
var wither_bonnie = Globals.wither_bonnie
var wither_chica = Globals.wither_chica
var wither_foxy = Globals.wither_foxy
var cheesestick = Globals.cheesestick
#Changed per night, how long the player has to hide under the desk when an animatronic gets in
var safety_time = Globals.safety_time
var p1_safety_time = safety_time
# Etc
var p1_last_cam

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += (delta * fun_multiplier)
	hour = floor(time / time_to_hour)
	minute = floor(lerp(hour * 60, hour * 60 + 60, time / time_to_hour)) as int % 60
	# Player thirst
	p1_thirst += (delta * 0.05) * fun_multiplier
	# Desk safety
	if animatronics_in_office > 0 && under_desk == false:
		p1_safety_time = clamp(p1_safety_time - delta, 0, safety_time)
		if p1_safety_time > 0:
			print(p1_safety_time)
	elif animatronics_in_office == 0:
		p1_safety_time = clamp(p1_safety_time + delta, 0, safety_time)
		if p1_safety_time < safety_time:
			print(p1_safety_time)
	# Fan heat
	if fan_powered:
		if under_desk:
			p1_heat = clamp(p1_heat - (delta * 0.025), -2, 5)
		else:
			p1_heat = clamp(p1_heat - (delta * 0.05), -2, 5)
	else:
		p1_heat = clamp(p1_heat + (delta * 0.025), 0, 5)
	blur.material.set("shader_parameter/blur_amount", p1_heat)
	# Music box running out
	if musicbox == 0:
		musicbox_ran_out = true
	# Music box winding - Degredation is handled by each music box sensitive animatronic
	if is_winding:
		musicbox = clamp(musicbox + 200 * delta, 0, 2000)
	
	# 6 AM
	if hour == 6:
		if night < 7:
			night = clamp(night + 1, 1, 6)
			Globals.save_night = night
			Globals._save()
		#TODO: Save backbuffer for a fade transition like fnaf
		get_tree().change_scene_to_file("res://scenes/victory.tscn")

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

func _jumpscare(animatronic: Node3D, short: bool = true):
	animatronic.position = Vector3(0, -0.719, -2.25)
	animatronic.rotation_degrees = Vector3(0, -90, 0)
	var anim : AnimationPlayer = animatronic.get_child(1)
	var sound : AudioStreamPlayer = animatronic.get_child(2)
	anim.play(animatronic.jumpscare_animation_id)
	sound.play()
	var playercamanim := $Player/Head/Eyes/AnimationPlayer
	var playerhead = $Player/Head
	var playeranim := $Player/AnimationPlayer
	var tablet = $Player/Head/Eyes/TabletHolder
	var cup = $Player/Head/Eyes/CupHolder
	tablet.visible = false
	cup.visible = false
	p1_heat = -2
	playerhead.rotation_degrees = Vector3.ZERO
	playeranim.play("RESET")
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	if short:
		playercamanim.play("CameraAction_003")
	await get_tree().create_timer(animatronic.jumpscare_length).timeout
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
