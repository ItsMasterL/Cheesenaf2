@tool
extends Node3D

@export var root : Node3D
@export_category("General Animatronic")
## The name of the animatronic, example: "edam_bonnie" or "wither_bonnie"
@export var animatronic : String
## Wherever the animatronic can appear, including position, rotation, animation, and more.
@export var positions : Array[AnimatronicPosition]
## How often a check is performed. Varying this number on each animatronic will make gameplay more interesting. Lower is faster.
@export var check_frequency : float = 5
## The time in seconds for this animatronic to play its jumpscare. Animations can be longer than this time, mainly useful if `game_sensitive` below is enabled for an apology animation.
@export var jumpscare_length : float = 0.6667
@export var jumpscare_animation_id : String = "Jumpscare"
@export var jumpscare_position : Vector3 = Vector3(0, -0.719, -2.25)
@export var jumpscare_rotation : Vector3 = Vector3(0, -90, 0)
@export_category("Special Animatronics")
## If true, the animatronic will be stunned if the cameras are looked at.
@export var camera_sensitive : bool
## If true, the animatronic will only succeed a jumpscare attempt if the player's cup isn't empty. Otherwise, they will refill the drink and leave.
@export var drink_sensitive : bool
## If true, the animatronic doesn't make any footstep sounds, and affects the music box song
@export var paranormal : bool
@export_subgroup("Save ignore")
## If true, the jumpscare will overwrite a game sensitive animatronic's save
@export var ignore_save : bool
## The animation ID to play on a save ignore. This plays on both this and the saving animatronic, so make sure they both have the animation and are synced. However, if it is the same as the jumpscare animation ID, it only plays on this animatronic.
@export var save_jumpscare_id : String = "SaveInterrupt"
@export var save_ignore_jumpscare_position : Vector3 = Vector3(0, -0.719, -2.25)
@export var save_ignore_jumpscare_rotation : Vector3 = Vector3(0, -90, 0)
@export_subgroup("Game sensitive")
## If true, the animatronic will only succeed a jumpscare attempt if the player does not have the tablet, has no installed games, or shakes their head no to the animatronic's voice line requesting to watch you play. It will stay in the last index of it's position array until either a hidden timer expires (1-2 in game hours) or until another animatronic attempts to jumpscare the player, in which case the animatronic will jumpscare the player itself, play an apology voice line, then return to position index 0 for the rest of the night
@export var game_sensitive : bool
@export var save_animation_id : String
## How long in seconds before a voiceline plays
@export var save_voiceline_delay : float
## How long in seconds before the player regains control
@export var save_player_free : float
@export_subgroup("Music Box")
## If true, the animatronic will not move until the music box has run out. Restarting the music box afterwards will not reset them. This animatronic's AI level will affect the music box's winding down speed.
@export var music_box_sensitive : bool
## If `music_box_sensitive` is true, whenever the music box changes music the below list will be checked. If an index matches with the song's index, that animation will play. If not, an animation will be picked at random from this list.
@export var music_box_dances : Array[String]
## If this and `music_box_sensitive` are true, always randomize the music box dance regardless of matching arrays.
@export var always_random_dance : bool
@export_subgroup("Friendly Animatronics")
## If true, the animatronic will be friendly in singleplayer/co-op nights 1 and 2 and will never be able to jumpscare the player.
@export var is_edam_animatronic : bool
## If true, the animatronic will warn of other animatronics entering the office vents when friendly, and will be killed on night 2 in singleplayer/co-op.
@export var vent_checker : bool
## Set by combo of is_edam_animatronic and office's edams_friendly. Can be set in the editor. These animatronics will never jumpscare the player.
@export var is_friendly : bool

@export_category("Editor")
@export var test_jumpscare = false:
	set(jumpscare_test):
		if jumpscare_test == true && Engine.is_editor_hint():
			test_jumpscare = false
			position = jumpscare_position
			rotation_degrees = jumpscare_rotation
			$AnimationPlayer.play(jumpscare_animation_id)
			if jumpscare_length > 0.7:
				$"../../Player/Head/Eyes/AnimationPlayer".play("Long")
			else:
				$"../../Player/Head/Eyes/AnimationPlayer".play("Default")
@export var test_save_ignore_jumpscare = false:
	set(jumpscare_test):
		if jumpscare_test == true && Engine.is_editor_hint():
			test_save_ignore_jumpscare = false
			position = save_ignore_jumpscare_position
			rotation_degrees = save_ignore_jumpscare_rotation
			$AnimationPlayer.play(save_jumpscare_id)
			if jumpscare_length > 0.7:
				$"../../Player/Head/Eyes/AnimationPlayer".play("Long")
			else:
				$"../../Player/Head/Eyes/AnimationPlayer".play("Default")
@export var current_position = 0: #Also used normally
	set(new_position):
		current_position = new_position
		if Engine.is_editor_hint():
			position = positions[current_position].position
			rotation_degrees = positions[current_position].rotation
			scale = positions[current_position].scale
			$AnimationPlayer.play(positions[current_position].animation_id)
			$"../../Player/Head/Eyes/AnimationPlayer".play("RESET")

# Usually used to disable movement checks during jumpscares
var can_move = true
# Used only for game sensitive animatronics
var guarding = false
var camera_cooldown = 0
var flashlight = 0
var safety_timer

@onready var timer = check_frequency
@onready var level = root._get_ai(animatronic)
@onready var stepsound := $Step
@onready var anim := $AnimationPlayer

# For game sensitive animatronics to look at the things the player does
@onready var skeleton = $"Edam Endo/Skeleton3D"
var object_of_interest
var new_rotation = Vector3.ZERO
var rotx = 0
var roty = 0

signal paranormal_song

func _ready() -> void:
	if Engine.is_editor_hint() == false:
		safety_timer = Globals.safety_time
		position = positions[0].position
		rotation_degrees = positions[0].rotation
		scale = positions[0].scale
		anim.play(positions[0].animation_id)
		if is_friendly == false: # In case someone wants an always friendly animatronic.
			is_friendly = is_edam_animatronic && root.edams_friendly
		if game_sensitive:
			root.game_sensitive.append(self)
		# Keep friendly dancers on stage
		if is_friendly && music_box_sensitive:
			can_move = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# Camera sensitivity
	if root.in_cams && root.using_tablet && camera_sensitive && positions[current_position].office_entrance == null:
		camera_cooldown = randf_range(2,23 - level)
	if camera_cooldown > 0 && camera_sensitive:
		camera_cooldown -= delta
		can_move = false
	# If not in the office
	elif camera_sensitive && positions[current_position].office_entrance == null:
		can_move = true
	# Safety Timer
	if positions[current_position].office_entrance != null && root.under_desk == false:
		safety_timer = clamp(safety_timer - delta, 0, safety_timer)
		print(animatronic + ": " + str(safety_timer))
	else:
		safety_timer = clamp(safety_timer + delta, 0, root.safety_time)
	# Light sensitivity
	if flashlight > 0:
		flashlight = clamp(flashlight - delta/2, 0, 5)
	#Music Box
	if music_box_sensitive && root.is_winding == false:
		root.musicbox = clamp(root.musicbox - (level * delta) * root.fun_multiplier, 0, 2000)
	
	#Look at stuff
	if game_sensitive && guarding && object_of_interest != null:
		_look_at_object(delta)
	# Debug - Summon to player
	if OS.is_debug_build() && game_sensitive && guarding == false && Input.is_key_pressed(KEY_BACKSPACE):
		current_position = positions.size() - 2
		_game_check()
	
	if timer > 0:
		#Make it easier on lower levels when they're in the office (But they leave faster with flashlight)
		if level <= 5 && positions[current_position].office_entrance != null && flashlight == 0:
			timer -= (delta / 3) * root.fun_multiplier
		elif level <= 10 && positions[current_position].office_entrance != null && flashlight == 0:
			timer -= (delta / 2) * root.fun_multiplier
		else:
			timer -= delta * root.fun_multiplier
	else:
		timer = check_frequency
		# After, so check_frequency can be changed by edam bonnie
		_movement_check()

func _movement_check():
	# If the animatronic can't move, don't move.
	if can_move == false:
		return
	# Don't let music box characters roam until the music box has run out
	if music_box_sensitive && root.musicbox_ran_out == false:
		return
	# If the animatronic is in the office (Any doorway or vent), always act
	if positions[current_position].office_entrance != null:
		#Fail if entryway is blocked
		if root.closed_entrances.has(positions[current_position].office_entrance.entrance):
			_fail_attack()
			return
		#If friendly edams
		if is_edam_animatronic && is_friendly:
			#If bonnie is in the office, play the warning and teleport Withered Bonnie/Chica to the vent
			if vent_checker && root.night == 2:
				var warning := $Warning
				warning.play()
				timer = check_frequency * 2 #Wait 3 checks before repeating (Including below line)
				await get_tree().create_timer(check_frequency).timeout
				if randi_range(0,1) == 1:
					# Sorry, but this is going to be very hardcoded for the sake of time
					if current_position == 8:
						root.animatronics.get_child(4).current_position = 9
						root.animatronics.get_child(4)._move_animatronic(9)
						root.animatronics.get_child(4).timer = root.animatronics.get_child(4).check_frequency
					elif current_position == 9:
						root.animatronics.get_child(4).current_position = 12
						root.animatronics.get_child(4)._move_animatronic(12)
						root.animatronics.get_child(4).timer = root.animatronics.get_child(4).check_frequency
					else:
						root.animatronics.get_child(5).current_position = 14
						root.animatronics.get_child(5)._move_animatronic(14)
						root.animatronics.get_child(5).timer = root.animatronics.get_child(5).check_frequency
			#If chica is in the office, refill the drink
			elif drink_sensitive:
				root.cup_fill = 1
				_fail_attack()
			#If fox is in the office and player has games, sit him down
			elif game_sensitive:
				_game_check()
			else:
				_fail_attack()
		# If the animatronic is not a friendly edam and checks for your drink
		elif drink_sensitive:
			if root.cup_fill > 0.25:
				# Waits for you to exit the desk, unless it can search under desks
				if root.under_desk && positions[current_position].office_entrance.search_under_desk == false:
					return
				root._jumpscare(self)
			else:
				root.cup_fill = 1
				_fail_attack()
				return
		#If foxy is in the office, ask if he can watch you play games (If you have games)
		elif game_sensitive:
			_game_check()
		# Tablet taking
		elif music_box_sensitive && root.p1_has_tablet:
			root._take_tablet()
			_fail_attack()
		# Desk hiding
		elif positions[current_position].office_entrance.search_under_desk == false && safety_timer > 0 && root.under_desk:
			_fail_attack()
		# Flashlight sensitivity
		elif positions[current_position].office_entrance.flashlight_weakness && flashlight > 0:
			_fail_attack()
		#All jumpscare exceptions/defenses are down. game over :3
		else:
			root._jumpscare(self)
	
	#AI check
	elif randi_range(1, 20) <= level:
		# Move to one of the next spaces if it exists
		var old_position = current_position
		if positions[current_position].next_position_indexes.is_empty() == false:
			# Move to the next space
			current_position = positions[current_position].next_position_indexes.pick_random()
			# If the next space is an office space, but the office limit is reached, wait if not friendly. (If 0, office must be empty)
			if positions[current_position].office_entrance != null && root.animatronics_in_office > positions[current_position].office_entrance.office_animatronic_limit && is_friendly == false:
				current_position = old_position
				return
			# Queue movement for camera use if paranormal
			if paranormal:
				root.paranormal_attacking = true
				root.paranormal_attacker = self
				paranormal_song.emit()
				timer = 99
				current_position = positions[current_position].next_position_indexes.pick_random()
				return
			if positions[current_position].office_entrance != null:
				# If the door is closed and this animatronic checks before entering, immediately reset
				if positions[current_position].office_entrance.check_before_entering && root.closed_entrances.has(positions[current_position].office_entrance.entrance):
					current_position = positions[current_position].office_entrance.fail_position_index
			if positions[current_position].office_entrance != null: # Check again in case they left before entering
				# If it's an office space, register as such NOTE: Friendly animatronics do not count, nor does Edam Foxy while he's hanging out with you
				if is_friendly == false:
					root.animatronics_in_office += 1
				if game_sensitive:
					var warning := $Warning
					if Globals.saw_foxy:
						warning.stream = load("res://sounds/dialogue/edamfoxy-enter%s.wav" % randi_range(1,4))
					else:
						warning.stream = load("res://sounds/dialogue/edamfoxy-night1-1.wav")
					warning.play()
				if check_frequency < 1: # Withered Foxy nerf
					timer = check_frequency * 1.75
			_move_animatronic()

func _move_animatronic():
	position = positions[current_position].position
	rotation_degrees = positions[current_position].rotation
	scale = positions[current_position].scale
	anim.play(positions[current_position].animation_id)
	if paranormal == false:
		if positions[current_position].is_vent:
			if check_frequency < 1.5:
				stepsound.stream = load("res://sounds/ventwalk_run.wav")
			else:
				stepsound.stream = load("res://sounds/ventwalk" + str(randi_range(1,2)) + ".wav")
		elif check_frequency < 1.5:
			stepsound.stream = load("res://sounds/walk_run.wav")
		else:
			stepsound.stream = load("res://sounds/walk" + str(randi_range(1,5)) + ".wav")
		stepsound.play()
	print(str(animatronic) + " moved to " + str(current_position))

func _fail_attack():
	# Friendly animatronics don't count towards this as they cannot harm you
	if is_friendly == false:
		root.animatronics_in_office -= 1
	if paranormal:
		root.paranormal_attacking = false
		root.paranormal_primed = false
		root.paranormal_attacker = null
		paranormal_song.emit()
	current_position = positions[current_position].office_entrance.fail_position_index
	_move_animatronic()

func _change_dance(count : int, id : int = 0):
	anim.play("Reset")
	if always_random_dance || music_box_dances.size() < count:
		anim.play(music_box_dances.pick_random())
	else:
		anim.play(music_box_dances[id - 1])

func _set_dance(dance : String):
	anim.play("Reset")
	anim.play(dance)

func _paranormal_dance():
	anim.play("Reset")
	anim.play("Cheesestick")

func _stop_dance():
	anim.stop()
	anim.play(positions[current_position].animation_id)

func _flash(value : float):
	flashlight = clamp(flashlight + value, 0, 5)

func _kill_vent_checker():
	if can_move == false || positions[current_position].office_entrance == null:
		return
	if root.closed_entrances.has(positions[current_position].office_entrance.entrance):
		var warning := $Warning
		anim.play("Death")
		warning.stream = load("res://sounds/animatronic_death.wav")
		warning.play()
		can_move = false
		root.jammed_entrances.append(positions[current_position].office_entrance.entrance)

func _leave_doorway_check():
	if root.night == 2 && vent_checker:
		return
	if positions[current_position].office_entrance != null:
		if positions[current_position].office_entrance.check_before_entering:
			if root.closed_entrances.has(positions[current_position].office_entrance.entrance):
				_fail_attack()

func _game_check():
	if root.p1_has_tablet && root.purchased_apps > 0:
		root.gamer_in_office = true
		current_position = positions[current_position].next_position_indexes.pick_random()
		_move_animatronic()
		if is_friendly == false: # If Foxy is mad, but still a chill guy
			root.animatronics_in_office -= 1
		var warning := $Warning
		if Globals.saw_foxy:
			warning.stream = load("res://sounds/dialogue/edamfoxy-sit%s.wav" % randi_range(1,4))
		else:
			warning.stream = load("res://sounds/dialogue/edamfoxy-night1-2.wav")
		warning.play()
		guarding = true
		can_move = false
		Globals.saw_foxy = true
		if root.night == 1:
			Globals.saw_foxy_night_1 = true
	# If no games, Foxy is sad
	elif is_friendly == true:
		_fail_attack()
	# If no games, Foxy is mad
	else:
		if root.under_desk && positions[current_position].office_entrance.search_under_desk == false:
			_fail_attack()
		else:
			root._jumpscare(self)

func _look_at_object(delta):
	var neck = $"Edam Endo/Skeleton3D/Neck/LookAt"
	var neckbone = skeleton.find_bone("Head")
	neck.look_at(object_of_interest.global_position, Vector3.UP, true)
	var degrees = neck.rotation_degrees
	degrees.x = clamp(degrees.x, -45, 50)
	degrees.y = clamp(degrees.y, -90, 90)
	rotx = lerp_angle(rotx, deg_to_rad(degrees.x), delta * 5)
	roty = lerp_angle(roty, deg_to_rad(degrees.y), delta * 5)
	new_rotation = Quaternion.from_euler(Vector3(rotx, roty, 0))
	skeleton.set_bone_pose_rotation(neckbone, new_rotation)
