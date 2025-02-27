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
@export_category("Special Animatronics")
## If true, the animatronic will be stunned if the cameras are looked at.
@export var camera_sensitive : bool
## If true, the animatronic will only succeed a jumpscare attempt if the player's cup isn't empty. Otherwise, they will refill the drink and leave.
@export var drink_sensitive : bool
## If true, the animatronic will only succeed a jumpscare attempt if the player does not have the tablet, has no installed games, or shakes their head no to the animatronic's voice line requesting to watch you play. It will stay in the last index of it's position array until either a hidden timer expires (1-2 in game hours) or until another animatronic attempts to jumpscare the player, in which case the animatronic will jumpscare the player itself, play an apology voice line, then return to position index 0 for the rest of the night
@export var game_sensitive : bool
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


var current_position = 0
# Usually used to disable movement checks during jumpscares
var can_move = true
var camera_cooldown = 0
@onready var timer = check_frequency
@onready var level = root._get_ai(animatronic)
@onready var stepsound := $Step
@onready var anim := $AnimationPlayer

func _ready() -> void:
	position = positions[0].position
	rotation_degrees = positions[0].rotation
	scale = positions[0].scale
	anim.play(positions[0].animation_id)
	if is_friendly == false: # In case someone wants an always friendly animatronic.
		is_friendly = is_edam_animatronic && root.edams_friendly

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Camera sensitivity
	if root.in_cams && root.using_tablet && camera_sensitive:
		camera_cooldown = randf_range(0,21 - level)
	if camera_cooldown > 0 && camera_sensitive:
		camera_cooldown -= delta
		can_move = false
	# If not in the office
	elif camera_sensitive && positions[current_position].office_entrance == null:
		can_move = true
	#Music Box
	if music_box_sensitive && root.is_winding == false:
		root.musicbox = clamp(root.musicbox - (level * delta) * root.fun_multiplier, 0, 2000)
	
	if timer > 0:
		#Make it easier on lower levels when they're in the office
		if level <= 5 && positions[current_position].office_entrance != null:
			timer -= (delta / 3) * root.fun_multiplier
		elif level <= 10 && positions[current_position].office_entrance != null:
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
			#If bonnie is in the office, play the warning and TODO: teleport Withered Bonnie to the vent
			if vent_checker && root.night == 2:
				var warning := $Warning
				warning.play()
				timer = check_frequency * 2 #Wait 2 checks before repeating
			#If chica is in the office, refill the drink
			elif drink_sensitive:
				root.cup_fill = 1
				_fail_attack()
			#If foxy is in the office, ask if he can watch you play games (If you have games)
			elif game_sensitive:
				pass #TODO: Foxy mechanics
			else:
				_fail_attack()
		# If the animatronic is not a friendly edam and checks for your drink
		elif drink_sensitive:
			if root.cup_fill > 0.25:
				can_move = false
				root._jumpscare(self)
			else:
				root.cup_fill = 1
				_fail_attack()
				return
		# Desk hiding
		elif positions[current_position].office_entrance.search_under_desk == false && root.p1_safety_time > 0 && root.under_desk:
				_fail_attack()
		#All jumpscare exceptions/defenses are down. game over :3
		else:
			can_move = false
			root._jumpscare(self)
	
	#AI check
	elif randi_range(1, 20) <= level:
		# Move to one of the next spaces if it exists
		if positions[current_position].next_position_indexes.is_empty() == false:
			# If the next space is an office space, but the office limit is reached, wait if not friendly
			if positions[current_position].office_entrance != null && root.animatronics_in_office >= positions[current_position].office_entrance.office_animatronic_limit && is_friendly == false:
				return
			# Move to the next space
			current_position = positions[current_position].next_position_indexes.pick_random()
			# If it's an office space, register as such NOTE: Friendly animatronics do not count, nor does Edam Foxy while he's hanging out with you
			if positions[current_position].office_entrance != null && is_friendly == false:
				root.animatronics_in_office += 1
			_move_animatronic(current_position)

func _move_animatronic(pos: int):
	position = positions[current_position].position
	rotation_degrees = positions[current_position].rotation
	scale = positions[current_position].scale
	anim.play(positions[current_position].animation_id)
	if positions[current_position].is_vent:
		stepsound.stream = load("res://sounds/ventwalk" + str(randi_range(1,2)) + ".wav")
	else:
		stepsound.stream = load("res://sounds/walk" + str(randi_range(1,5)) + ".wav")
	stepsound.play()
	print(str(animatronic) + " moved to " + str(current_position))

func _fail_attack():
	# Friendly animatronics don't count towards this as they cannot harm you
	if is_friendly == false:
		root.animatronics_in_office -= 1
	current_position = positions[current_position].office_entrance.fail_position_index
	_move_animatronic(current_position)
