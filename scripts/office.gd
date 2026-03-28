extends Node3D

#region Variables
signal music_box_ran_out
signal entrance_closing
signal sabotage_begin
signal sabotage_end
signal player_spectating

const TIME_TO_HOUR = 90

@export var tablet: MeshInstance3D
@export var animatronics: Node3D
@export var doors: Node3D
@export var drink: MeshInstance3D
@export var blur: ColorRect
@export var sabotage_warning: AudioStreamPlayer
#Multiplayer
@export var lights: Array[Node3D]
@export var player_manager: Node

@export_category("Player 1")
@export var p1 : Node
@export var p1_tablet_holder : Node
@export var p1_cup_holder : Node
@export var p1_cursor : Node
@export_category("Player 2")
@export var p2 : Node

var night = Globals.night
var time = 0 as float
var hour = 0
var minute = 0
var fun_multiplier = 1 # Set by minigames in singleplayer to make time go by faster
var purchased_apps
var using_tablet = false
var using_laptop = false
var p1_in_cams = false
var p2_in_cams = false
var under_desk = false
var is_laptop_closed = false
var animatronics_in_office = 0 # Not networked
var closed_entrances: Array[int]
var jammed_entrances: Array[int]
var cup_fill = 1
var fan_powered = true
var p1_thirst = 0 # Not networked
var p1_heat = 0 # Not networked
var musicbox = 2000
var is_winding = false
var musicbox_is_playing = true # This is true anytime the musicbox is playing
var musicbox_ran_out = false # This is true once the musicbox has run out at least once in the night
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
# Multiplayer specific
var is_p1 = true # Not networked
var sabotage_name
var sabotage_description
var temp_closed_entrances: Array[int]
var music_box_multiplier = 1
var active_sabotage: Globals.Sabotages = Globals.Sabotages.NONE:
	set(type):
		active_sabotage = type
		match active_sabotage:
			Globals.Sabotages.NONE:
				sabotage_name = "None"
				sabotage_description = "All is well."
				return
			Globals.Sabotages.POWER_OUTAGE: #
				sabotage_name = "Power Outage"
				sabotage_description = "The main power to the building has been cut! The lights have gone dark and the doorways have all been opened. However, any device with a battery should still function."
			Globals.Sabotages.TABLET_BLOCK:
				sabotage_name = "Tablet Block"
				sabotage_description = "Uh oh, looks like your tablet isn't functioning right now. Hope you didn't need cameras, games, or a way to close the doors around you."
			Globals.Sabotages.STIFF_NECK: #
				sabotage_name = "Stiff Neck"
				sabotage_description = "Oops! Looks like your neck is a little stiff. I guess you could call this some kind of Stiff Neck. I'm sure you'll be fine."
			Globals.Sabotages.CAMERA_MALFUNCTION:
				sabotage_name = "Camera Malfunction"
				sabotage_description = "The cameras aren't working right at the moment. Seems they'll be a bit more unreliable than usual. Thankfully this isn't a main mechanic, otherwise it might be a bit more controversial."
			Globals.Sabotages.PIZZA_DELIVERY: #
				sabotage_name = "Pizza Delivery"
				sabotage_description = "Congratulations! You have been delivered a fresh pizza! Unfortunately, the old animatronics love the pizza even more than you do. Expect trouble."
			Globals.Sabotages.EXTREME_THIRST: #
				sabotage_name = "Extreme Thirst"
				sabotage_description = "Uh oh! Someone's getting a little too irritated about how much you've been neglecting your water cup. I mean, chugging the whole thing when they show up? Now they're checking twice as often!"
			Globals.Sabotages.BALLOON_BOY: #
				sabotage_name = "Balloon Boy"
				sabotage_description = "That pesky animatronic stole your flashlight batteries without even being seen! I mean, surely he exists in the game. Don't look at the source code." #He's not in the game actually
			Globals.Sabotages.SWAP:
				sabotage_name = "Swap"
				sabotage_description = "Swippity Swappity your boss is now you're goppity"
			Globals.Sabotages.DATA_CORRUPTION:
				sabotage_name = "Data Corruption"
				sabotage_description = "Uh oh! The games on your tablet aren't working! Now the animatronics that like watching you play them aren't gonna be so happy around you."
			Globals.Sabotages.UNSTABLE_CONNECTION:
				sabotage_name = "Unstable Connection"
				sabotage_description = "Looks like Skype is having some issues connecting tonight. They really should have done something locally networked instead."
			Globals.Sabotages.MUSIC_UNWOUND: #
				sabotage_name = "Music Unwound"
				sabotage_description = "The music box malfunctioned! It's now playing twice as fast as it's supposed to! Make sure to attend to it more often!"
			Globals.Sabotages.SOFT_SLIPPERS:
				sabotage_name = "Soft Slippers"
				sabotage_description = "The animatronics have gotten sneakier! You won't be able to hear them nearly as well."
			_:
				sabotage_name = "???"
				sabotage_description = "Something has gone wrong, but you don't know what!"
				return
		sabotage_begin.emit(active_sabotage as Globals.Sabotages)
var spectating = false
var alive_players = {}

# Etc
var last_cam # Not networked
var is_in_vent_cam = false # Not networked
var game_sensitive: Array[Node3D]
var can_jumpscare = true # If a game sensitive animatronic is saving you
var p1_can_action = true # False if in a jumpscare
var p2_can_action = true # False if in a jumpscare
var paranormal_attacking = false # Why is it here?
var paranormal_attacker: Node3D # What even is it?
var paranormal_primed = false # What is it doing?
var is_paused = false # Used to pause the gameplay without freezing the player, mainly for debug
#endregion

# Called when the node enters the scene tree for the first time.
func _ready():
	if MultiplayerCore.is_multiplayer:
		_register_player.rpc()
		if MultiplayerCore.player_roles[multiplayer.get_unique_id()] == MultiplayerCore.ROLES.PSY_OFFICE_A:
				player_manager.set_active_player.emit()

	for animatronic in animatronics.get_children():
		if animatronic.music_box_sensitive:
			music_box_ran_out.connect(animatronic._stop_dance)
		if animatronic.vent_checker and night == 2:
			entrance_closing.connect(animatronic._kill_vent_checker)
		entrance_closing.connect(animatronic._leave_doorway_check)
	
	sabotage_begin.connect(_sabotage_event)
	sabotage_end.connect(_sabotage_event_end)

	if night == 1:
		p1.get_node("Head/Eyes/Controls").visible = true
		closed_entrances = [1, 4]
	_set_entrances(closed_entrances)
	# Remove Bonnie when he's dead
	if night > 2 and night < 6:
		animatronics.get_child(1).visible = false
		animatronics.get_child(1).can_move = false
	Globals.game_time = 0

#region Command Setup
	LimboConsole.register_command(cmd_jumpscare, "jumpscare", "Triggers a jumpscare with the specified animatronic. Defaults to Edam Freddy.")
	LimboConsole.add_argument_autocomplete_source("jumpscare", 0, func(): return animatronics.get_children().map(func(node): return node.animatronic))

	LimboConsole.register_command(cmd_gamer_to_office, "summongamer", "Summons a game-sensitive animatronic to your office. Defaults to Edam Foxy.")
	LimboConsole.add_argument_autocomplete_source("summongamer", 0, func(): return animatronics.get_children().map(_gamer_filter).filter(func(string): return string != null))

	LimboConsole.register_command(cmd_friendly_edams, "friendlyedams", "Makes Edam animatronics friendly or hostile.")

	LimboConsole.register_command(cmd_set_level, "level", "Sets the level of an animatronic.")
	LimboConsole.add_argument_autocomplete_source("level", 0, func(): return animatronics.get_children().map(func(node): return node.animatronic))
	LimboConsole.add_argument_autocomplete_source("level", 1, func(): return animatronics.get_children().map(func(node): return node.level))

	LimboConsole.register_command(cmd_sabotage, "sabotage", "Sets the active sabotage. Defaults to NONE")
	LimboConsole.add_argument_autocomplete_source("sabotage", 0, func(): return Globals.Sabotages.keys())

	LimboConsole.register_command(cmd_set_time, "time value", "Sets the time at the smallest level.")
	LimboConsole.register_command(cmd_set_hour, "time hour", "Sets the time by the hour.")
	LimboConsole.register_command(cmd_pause, "time pause", "Toggles the flow of time")

func _exit_tree():
	LimboConsole.unregister_command("jumpscare")
	LimboConsole.unregister_command("summongamer")
	LimboConsole.unregister_command("friendlyedams")
	LimboConsole.unregister_command("level")
	LimboConsole.unregister_command("sabotage")
	LimboConsole.unregister_command("time value")
	LimboConsole.unregister_command("time hour")
	LimboConsole.unregister_command("time pause")
#endregion

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_paused:
		return
	Globals.game_time += delta
	time += (delta * fun_multiplier)
	hour = floor(time / TIME_TO_HOUR)
	minute = floor(lerp(hour * 60, hour * 60 + 60, time / TIME_TO_HOUR)) as int % 60
	# Player thirst
	p1_thirst += (delta * 0.05) * fun_multiplier
	# Fan heat
	if active_sabotage != Globals.Sabotages.POWER_OUTAGE:
		if fan_powered:
			if under_desk:
				p1_heat = clamp(p1_heat - (delta * 0.025), -2, 5)
			else:
				p1_heat = clamp(p1_heat - (delta * 0.05), -2, 5)
		elif active_sabotage:
			p1_heat = clamp(p1_heat + (delta * 0.015), 0, 5)
	blur.material.set("shader_parameter/blur_amount", p1_heat)
	# Music box running out
	if musicbox == 0:
		if musicbox_is_playing:
			music_box_ran_out.emit()
		musicbox_ran_out = true
		musicbox_is_playing = false
	# Music box winding - Degredation is handled by each music box sensitive animatronic
	if is_winding:
		musicbox_is_playing = true
		musicbox = clamp(musicbox + 200 * delta, 0, 2000)
	
	# ????????
	if paranormal_attacking:
		if p1_in_cams and using_tablet:
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
		var fade_image = get_viewport().get_texture().get_image()
		Globals.fade_texture = ImageTexture.create_from_image(fade_image)
		get_tree().change_scene_to_file("res://scenes/victory.tscn")

# Submits variables on all clients for multiplayer
@rpc("any_peer","call_local","reliable")
func _register_player():
	for p in MultiplayerCore.players:
		alive_players[p] = true
		print(MultiplayerCore.players[p])
	print(alive_players)

@rpc("any_peer","call_local","reliable")
func _register_spectate(id: int):
	alive_players[id] = false
	#Check if everyone has died, then bring up the death screen
	#TODO: Change logic for 2v2
	for alive in alive_players:
		if alive_players[alive] == true:
			print(str(MultiplayerCore.players[alive]) + " (" + str(alive) + ") is still alive!")
			return
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")

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

@rpc("authority","call_local","reliable")
func _take_tablet():
	if using_tablet:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	using_tablet = false
	p1_in_cams = false
	p1_has_tablet = false
	$Player/Head/Eyes/Cursor.visible = true
	tablet.queue_free() # You ain't getting that back lmao
	$Player/Head/LoseTablet.play()

@rpc("authority","call_local","reliable")
func _set_entrances(values: Array[int]):
	var i = 0
	for door in doors.get_children():
		if values.has(i) and closed_entrances.has(i) == false:
			door.get_child(1).play(&"close")
			door.get_child(2).play()
		elif values.has(i) == false and closed_entrances.has(i):
			door.get_child(1).play(&"close", -1, -1, true)
			door.get_child(2).play()
		elif values.has(i) == false and closed_entrances.has(i) == false:
			door.get_child(1).play(&"opened", -1, -1, true)
		i += 1
	closed_entrances = values
	if time > 0.2:
		entrance_closing.emit()

func _refill_cup():
	if cup_fill != 1:
		cup_fill = 1
		if is_p1:
			drink.get_node("Refill").play()
		drink.get_node("StaticBody3D").local_cup_fill = cup_fill
		drink.get_node("StaticBody3D")._update_water()

func _jumpscare(animatronic: Node3D):
	while can_jumpscare == false:
		return
	var is_player_one = true
	if animatronic.positions[animatronic.current_position].office_entrance.entrance == EntranceProperty.Entrances.LEFT_DOOR and animatronic.positions[animatronic.current_position].office_entrance.entrance == EntranceProperty.Entrances.RIGHT_DOOR:
		is_player_one = false

	can_jumpscare = false
	animatronic.can_move = false
	var anim: AnimationPlayer = animatronic.anim
	var sound: AudioStreamPlayer = animatronic.get_node("Jumpscare")
	var player_cam_anim := p1.get_node("Head/Eyes/AnimationPlayer")
	var player_head = p1.get_node("Head")
	var player_cam = p1.get_node("Head/Eyes")
	var player_anim := p1.get_node("AnimationPlayer")
	var cup = p1.get_node("Head/Eyes/CupHolder")

	if is_player_one:
		p1_can_action = false
		print("Jumpscared by %s" % animatronic.animatronic)
		if gamer_in_office:
			for gamer in game_sensitive:
				if gamer.guarding == true: # Only is set to this when in the office
					if animatronic.ignore_save == true and animatronic.save_jumpscare_id != animatronic.jumpscare_animation_id:
						gamer.can_move = false
						gamer.position = gamer.jumpscare_position
						gamer.rotation_degrees = gamer.jumpscare_rotation
						gamer.anim.play(animatronic.save_jumpscare_id)
					elif animatronic.ignore_save == false:
						animatronic._fail_attack()
						_jumpscare_save(gamer)
						return
		under_desk = false
		if gamer_in_office and animatronic.ignore_save == true and animatronic.save_jumpscare_id != animatronic.jumpscare_animation_id:
			animatronic.position = animatronic.save_ignore_jumpscare_position
			animatronic.rotation_degrees = animatronic.save_ignore_jumpscare_rotation
			sound.stream = load("res://sounds/jumpscare_interrupted.wav")
			anim.play(animatronic.save_jumpscare_id)
		else:
			animatronic.position = animatronic.jumpscare_position
			animatronic.rotation_degrees = animatronic.jumpscare_rotation
			anim.speed_scale = 1 # For the Music Unwound sabotage
			anim.play(animatronic.jumpscare_animation_id)
		if tablet != null:
			tablet.visible = false
			cup.visible = false
			p1_heat = -2
	else:
		player_cam_anim = p2.get_node("Head/Eyes/AnimationPlayer")
		player_head = p2.get_node("Head")
		player_cam = p2.get_node("Head/Eyes")
		player_anim = p2.get_node("AnimationPlayer")
		
		animatronic.position = animatronic.jumpscare_position_2
		animatronic.rotation_degrees = animatronic.jumpscare_rotation_2
		anim.speed_scale = 1 # For the Music Unwound sabotage
		anim.play(animatronic.jumpscare_animation_id)


	sound.play()
	player_head.rotation_degrees = Vector3.ZERO
	player_cam.rotation_degrees = Vector3.ZERO
	player_anim.play("RESET")
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	if animatronic.jumpscare_length < 0.7:
		player_cam_anim.play("Default")
	else:
		player_cam_anim.play("Long")
	await get_tree().create_timer(animatronic.jumpscare_length).timeout
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if MultiplayerCore.is_multiplayer and (Globals.office_mode == Globals.OfficeMode.CO_OP or Globals.office_mode == Globals.OfficeMode.VERSUS_TEAMS):
		spectating = true
		player_spectating.emit()
		_register_spectate(multiplayer.get_unique_id())
		player_manager.set_active_player.emit()
		sound.stop()
		animatronic._fail_attack()
	else:
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _jumpscare_save(animatronic: Node3D):
	can_jumpscare = false
	under_desk = false
	animatronic.position = Vector3(0, -0.719, -2.25)
	animatronic.rotation_degrees = Vector3(0, -90, 0)
	var anim: AnimationPlayer = animatronic.get_child(1)
	var sound: AudioStreamPlayer = animatronic.get_child(2)
	var warning: AudioStreamPlayer = animatronic.get_child(4)
	warning.stream = load("res://sounds/dialogue/edamfoxy-save%s.wav" % [randi_range(1, 7)])
	anim.play(animatronic.save_animation_id)
	sound.play()
	var player_cam_anim := p1.get_node("Head/Eyes/AnimationPlayer")
	var player_head = p1.get_node("Head")
	var player_cam = p1.get_node("Head/Eyes")
	var player_anim := p1.get_node("AnimationPlayer")
	var cup = p1.get_node("Head/Eyes/CupHolder")
	if tablet != null:
		tablet.visible = false
	cup.visible = false
	p1_heat = -2
	player_head.rotation_degrees = Vector3.ZERO
	player_cam.rotation_degrees = Vector3.ZERO
	player_anim.play("RESET")
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	player_cam_anim.play("Default")
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
	gamer_in_office = false

#region Sabotages

@rpc("authority","call_local","reliable")
func _send_sabotage(event: Globals.Sabotages):
	if event == Globals.Sabotages.NONE:
		sabotage_end.emit()
		LimboConsole.print_line("Active sabotage set to " + sabotage_name)
		return
	elif event != Globals.Sabotages.NONE:
		active_sabotage = Globals.Sabotages.NONE
		await get_tree().create_timer(0.16).timeout
	active_sabotage = event
	LimboConsole.print_line("Active sabotage set to " + sabotage_name)

func _sabotage_event(event : Globals.Sabotages):
	match event:
		Globals.Sabotages.POWER_OUTAGE:
			sabotage_warning.stream = load("res://sounds/multiplayer/powerdown.wav")
			sabotage_warning.play()
			for light in lights:
				light.visible = false
			temp_closed_entrances = closed_entrances
			await get_tree().create_timer(0.16).timeout #fixes a bug kind of ??
			_set_entrances([]) # We can probably safely ignore jammed entrances
		
		Globals.Sabotages.BALLOON_BOY:
			sabotage_warning.stream = load("res://sounds/multiplayer/balloonboy.wav")
			sabotage_warning.play()
		
		Globals.Sabotages.MUSIC_UNWOUND:
			sabotage_warning.stream = load("res://sounds/multiplayer/jackinthebox.wav")
			sabotage_warning.play()
			music_box_multiplier = 2

		Globals.Sabotages.PIZZA_DELIVERY:
			sabotage_warning.stream = load("res://sounds/multiplayer/doorbell.mp3")
			sabotage_warning.play()

		Globals.Sabotages.EXTREME_THIRST:
			sabotage_warning.stream = load("res://sounds/multiplayer/doorbell.mp3")
			sabotage_warning.play()
		
		Globals.Sabotages.STIFF_NECK:
			sabotage_warning.stream = load("res://sounds/multiplayer/adam_stiff.wav")
			sabotage_warning.play()
		
		Globals.Sabotages.SOFT_SLIPPERS:
			AudioServer.set_bus_effect_enabled(7,0,true)
		
		Globals.Sabotages.SWAP:
			sabotage_warning.stream = load("res://sounds/swipe.wav")
			sabotage_warning.play()
			player_manager.set_active_player.emit()
			_sabotage_event_end()

func _sabotage_event_end():
	match active_sabotage:
		Globals.Sabotages.POWER_OUTAGE:
			for light in lights:
				light.visible = true
			_set_entrances(temp_closed_entrances)

		Globals.Sabotages.BALLOON_BOY:
			sabotage_warning.stream = load("res://sounds/multiplayer/gone.wav")
			sabotage_warning.play()

		Globals.Sabotages.MUSIC_UNWOUND:
			sabotage_warning.stream = load("res://sounds/multiplayer/gone.wav")
			sabotage_warning.play()
			music_box_multiplier = 1

		Globals.Sabotages.PIZZA_DELIVERY:
			sabotage_warning.stream = load("res://sounds/multiplayer/gone.wav")
			sabotage_warning.play()

		Globals.Sabotages.EXTREME_THIRST:
			sabotage_warning.stream = load("res://sounds/multiplayer/gone.wav")
			sabotage_warning.play()
		
		Globals.Sabotages.STIFF_NECK:
			sabotage_warning.stream = load("res://sounds/multiplayer/adam_unstiff.wav")
			sabotage_warning.play()
		
		Globals.Sabotages.SOFT_SLIPPERS:
			AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Footsteps"),0,false)
	
	active_sabotage = Globals.Sabotages.NONE
#endregion

#region Command Logic

func _gamer_filter(node: Node3D):
	if node.game_sensitive:
		return node.animatronic
			

func cmd_jumpscare(arg1: String = "edam_freddy"):
	for i in animatronics.get_children():
		if arg1 == i.animatronic:
			_jumpscare(i)
			LimboConsole.close_console()
			return
	LimboConsole.error("Animatronic not found.")

func cmd_gamer_to_office(arg1: String = "edam_foxy"):
	for i in animatronics.get_children():
		if arg1 == i.animatronic:
			if i.game_sensitive:
				i.cmd_gamer_to_office()
				return
			LimboConsole.error("Animatronic not game sensitive.")
			return
	LimboConsole.error("Animatronic not found.")

func cmd_friendly_edams(arg1: bool):
	edams_friendly = arg1
	for i in animatronics.get_children():
		if i.is_edam_animatronic:
			i.is_friendly = edams_friendly
	if edams_friendly:
		LimboConsole.print_line("Edam animatronics are now friendly.")
	else:
		LimboConsole.print_line("Edam animatronics are no longer friendly.")

func cmd_set_level(arg1: String = "edam_freddy", arg2: int = -1):
	if arg2 < 0:
		for i in animatronics.get_children():
			if arg1 == i.animatronic:
				LimboConsole.print_line(i.animatronic + "'s AI is level " + str(i.level))
				return
	arg2 = clampi(arg2, 0, 20) #Not that it matters too much tbh
	for i in animatronics.get_children():
		if arg1 == i.animatronic:
			i.level = arg2
			LimboConsole.print_line(i.animatronic + "'s AI has been set to level " + str(i.level))
			LimboConsole.add_argument_autocomplete_source("level", 1, func(): return animatronics.get_children().map(func(node): return node.level))
			return
	LimboConsole.error("Animatronic not found.")

func cmd_sabotage(arg1: String = "NONE"):
	var value = Globals.Sabotages.get(arg1.to_upper())
	_send_sabotage.rpc(value)

func cmd_set_time(arg1: int):
	time = clamp(arg1, 0, 6 * TIME_TO_HOUR)

func cmd_set_hour(arg1: int):
	time = clamp(arg1, 0, 6) * TIME_TO_HOUR

func cmd_pause():
	is_paused = !is_paused
	if is_paused:
		LimboConsole.print_line("Gameplay has been paused")
	else:
		LimboConsole.print_line("Gameplay has resumed")

#endregion
