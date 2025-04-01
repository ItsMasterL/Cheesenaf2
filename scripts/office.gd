extends Node3D
@onready var blur := $BlurShader/ColorRect

var night = Globals.night
var time = 0 as float
var hour = 0
var minute = 0
var fun_multiplier = 1 #Set by minigames in singleplayer to make time go by faster
var purchased_apps
const time_to_hour = 90
var using_tablet = false
var in_cams = false
var under_desk = false
var animatronics_in_office = 0
var closed_entrances : Array[int]
var jammed_entrances : Array[int]
var cup_fill = 1
var fan_powered = true
var p1_thirst = 0
var p1_heat = 0
var musicbox = 2000
var is_winding = false
var musicbox_ran_out = false
var gamer_in_office = false # This is for Edam Foxy. I just thought it'd be a fun variable name
var p1_has_tablet = true
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
var p1_vent_cam = false
var game_sensitive : Array[Node3D]
var can_jumpscare = true # If a game sensitive animatronic is saving you
var p1_can_action = true # False if in a jumpscare
var paranormal_attacking = false # Why is it here?
var paranormal_attacker : Node3D # What even is it?
var paranormal_primed = false # What is it doing?

signal music_box_ran_out
signal entrance_closing

@export var tablet : MeshInstance3D
@export var animatronics : Node3D
@export var doors : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	for animatronic in animatronics.get_children():
		if animatronic.music_box_sensitive:
			music_box_ran_out.connect(animatronic._stop_dance)
		if animatronic.vent_checker && night == 2:
			entrance_closing.connect(animatronic._kill_vent_checker)
	if night == 1:
		$Player/Head/Eyes/Controls.visible = true
		closed_entrances = [1, 4]
	_set_entrances(closed_entrances)
	# Remove Bonnie when he's dead
	if night > 2 && night < 6:
		animatronics.get_child(1).visible = false
		animatronics.get_child(1).can_move = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Globals.game_time += delta
	time += (delta * fun_multiplier)
	hour = floor(time / time_to_hour)
	minute = floor(lerp(hour * 60, hour * 60 + 60, time / time_to_hour)) as int % 60
	# Player thirst
	p1_thirst += (delta * 0.05) * fun_multiplier
	# Desk safety
	if animatronics_in_office > 0 && under_desk == false:
		p1_safety_time = clamp(p1_safety_time - delta, 0, safety_time)
	elif animatronics_in_office == 0:
		p1_safety_time = clamp(p1_safety_time + delta, 0, safety_time)
	# Fan heat
	if fan_powered:
		if under_desk:
			p1_heat = clamp(p1_heat - (delta * 0.025), -2, 5)
		else:
			p1_heat = clamp(p1_heat - (delta * 0.05), -2, 5)
	else:
		p1_heat = clamp(p1_heat + (delta * 0.015), 0, 5)
	blur.material.set("shader_parameter/blur_amount", p1_heat)
	# Music box running out
	if musicbox == 0:
		musicbox_ran_out = true
		music_box_ran_out.emit()
	# Music box winding - Degredation is handled by each music box sensitive animatronic
	if is_winding:
		musicbox = clamp(musicbox + 200 * delta, 0, 2000)
	
	# ????????
	if paranormal_attacking:
		if in_cams && using_tablet:
			paranormal_primed = true
		elif paranormal_primed:
			paranormal_attacker._move_animatronic()
			paranormal_attacker.timer = 8 - night
			paranormal_primed = false
	
	# 6 AM
	if hour == 6:
		if night < 7:
			night = clamp(night + 1, 1, 6)
			Globals.save_night = night
		#TODO: Save backbuffer for a fade transition like fnaf
		get_tree().change_scene_to_file("res://scenes/victory.tscn")
	
	if OS.is_debug_build():
		if can_jumpscare:
			if Input.is_key_pressed(KEY_F1):
				_jumpscare(animatronics.get_child(0))
			if Input.is_key_pressed(KEY_F2):
				_jumpscare(animatronics.get_child(1))
			if Input.is_key_pressed(KEY_F3):
				_jumpscare(animatronics.get_child(2))
			if Input.is_key_pressed(KEY_F4):
				_jumpscare(animatronics.get_child(3))
			if Input.is_key_pressed(KEY_F5):
				_jumpscare(animatronics.get_child(4))
			if Input.is_key_pressed(KEY_F6):
				_jumpscare(animatronics.get_child(5))
			if Input.is_key_pressed(KEY_F7):
				_jumpscare(animatronics.get_child(6))
			if Input.is_key_pressed(KEY_F9):
				_jumpscare(animatronics.get_child(7))
			if Input.is_key_pressed(KEY_F10):
				_jumpscare(animatronics.get_child(8))
			if Input.is_key_pressed(KEY_F11):
				_jumpscare(animatronics.get_child(9))
		if Input.is_key_pressed(KEY_F12):
			time = 540

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

func _take_tablet():
	if using_tablet:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	using_tablet = false
	in_cams = false
	p1_has_tablet = false
	$Player/Head/Eyes/Cursor.visible = true
	tablet.queue_free() # You ain't getting that back lmao
	$Player/Head/LoseTablet.play()

func _set_entrances(values: Array[int]):
	var i = 0
	for door in doors.get_children():
		if values.has(i) && closed_entrances.has(i) == false:
			door.get_child(1).play(&"close")
			door.get_child(2).play()
		elif values.has(i) == false && closed_entrances.has(i):
			door.get_child(1).play(&"close", -1, -1, true)
			door.get_child(2).play()
		elif values.has(i) == false && closed_entrances.has(i) == false:
			door.get_child(1).play(&"opened", -1, -1, true)
		i += 1
	closed_entrances = values
	if time > 0.2:
		entrance_closing.emit()

func _jumpscare(animatronic: Node3D):
	while can_jumpscare == false:
		pass
	p1_can_action = false
	print("Jumpscared by %s" % animatronic.animatronic)
	if gamer_in_office:
		for gamer in game_sensitive:
			if gamer.guarding == true: # Only is set to this when in the office
				if animatronic.ignore_save == true && animatronic.save_jumpscare_id != animatronic.jumpscare_animation_id:
					gamer.can_move = false
					gamer.position = gamer.jumpscare_position
					gamer.rotation_degrees = gamer.jumpscare_rotation
					gamer.anim.play(animatronic.save_jumpscare_id)
				elif animatronic.ignore_save == false:
					animatronic._fail_attack()
					_jumpscare_save(gamer)
					return
	can_jumpscare = false
	under_desk = false
	animatronic.can_move = false
	var anim : AnimationPlayer = animatronic.get_child(1)
	var sound : AudioStreamPlayer = animatronic.get_child(2)
	if gamer_in_office && animatronic.ignore_save == true && animatronic.save_jumpscare_id != animatronic.jumpscare_animation_id:
		animatronic.position = animatronic.save_ignore_jumpscare_position
		animatronic.rotation_degrees = animatronic.save_ignore_jumpscare_rotation
		sound.stream = load("res://sounds/jumpscare_interrupted.wav")
		anim.play(animatronic.save_jumpscare_id)
	else:
		animatronic.position = animatronic.jumpscare_position
		animatronic.rotation_degrees = animatronic.jumpscare_rotation
		anim.play(animatronic.jumpscare_animation_id)
	sound.play()
	var playercamanim := $Player/Head/Eyes/AnimationPlayer
	var playerhead = $Player/Head
	var playercam = $Player/Head/Eyes
	var playeranim := $Player/AnimationPlayer
	var cup = $Player/Head/Eyes/CupHolder
	if tablet != null:
		tablet.visible = false
	cup.visible = false
	p1_heat = -2
	playerhead.rotation_degrees = Vector3.ZERO
	playercam.rotation_degrees = Vector3.ZERO
	playeranim.play("RESET")
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	if animatronic.jumpscare_length < 0.7:
		playercamanim.play("Default")
	else:
		playercamanim.play("Long")
	await get_tree().create_timer(animatronic.jumpscare_length).timeout
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _jumpscare_save(animatronic: Node3D):
	can_jumpscare = false
	under_desk = false
	animatronic.position = Vector3(0, -0.719, -2.25)
	animatronic.rotation_degrees = Vector3(0, -90, 0)
	var anim : AnimationPlayer = animatronic.get_child(1)
	var sound : AudioStreamPlayer = animatronic.get_child(2)
	var warning : AudioStreamPlayer = animatronic.get_child(4)
	warning.stream = load("res://sounds/dialogue/edamfoxy-save%s.wav" % [randi_range(1,7)])
	anim.play(animatronic.save_animation_id)
	sound.play()
	var playercamanim := $Player/Head/Eyes/AnimationPlayer
	var playerhead = $Player/Head
	var playercam = $Player/Head/Eyes
	var playeranim := $Player/AnimationPlayer
	var cup = $Player/Head/Eyes/CupHolder
	if tablet != null:
		tablet.visible = false
	cup.visible = false
	p1_heat = -2
	playerhead.rotation_degrees = Vector3.ZERO
	playercam.rotation_degrees = Vector3.ZERO
	playeranim.play("RESET")
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	playercamanim.play("CameraAction_003")
	if animatronic.save_voiceline_delay < animatronic.save_player_free: # Most likely
		await get_tree().create_timer(animatronic.save_voiceline_delay).timeout
		warning.play()
		await get_tree().create_timer(animatronic.save_player_free - animatronic.save_voiceline_delay).timeout
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if tablet != null:
			tablet.visible = true
		cup.visible = true
		p1_can_action = true
	elif animatronic.save_voiceline_delay > animatronic.save_player_free: # Less likely
		await get_tree().create_timer(animatronic.save_player_free).timeout
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if tablet != null:
			tablet.visible = true
		cup.visible = true
		p1_can_action = true
		await get_tree().create_timer(animatronic.save_voiceline_delay - animatronic.save_player_free).timeout
		warning.play()
	else: # Least likely
		await get_tree().create_timer(animatronic.save_voiceline_delay).timeout
		warning.play()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if tablet != null:
			tablet.visible = true
		cup.visible = true
		p1_can_action = true
	animatronic.guarding = false
	can_jumpscare = true
