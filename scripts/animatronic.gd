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


var current_position = 0
@onready var timer = check_frequency
@onready var level = root._get_ai(animatronic)
@onready var stepsound := $Step
@onready var anim := $AnimationPlayer

func _ready() -> void:
	print("Initial transform: " + str(get_transform()))
	position = positions[0].position
	rotation = positions[0].rotation
	scale = positions[0].scale
	print("New transform: " + str(get_transform()))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer > 0:
		timer -= delta
	else:
		_movement_check()
		timer = check_frequency

func _movement_check():
	#AI check
	if randi_range(1, 20) <= level:
		# If the animatronic is in the office (Any doorway or vent)
		if positions[current_position].office_entrance != null:
			#Fail if entryway is blocked
			if root.closed_entrances.has(positions[current_position].office_entrance.entrance):
				current_position = positions[current_position].office_entrance.fail_position_index
				_move_animatronic(current_position)
				return
			#If friendly edams
			if is_edam_animatronic && root.edams_friendly:
				#If bonnie is in the office, play the warning and TODO: teleport Withered Bonnie to the vent
				if vent_checker && root.night == 2:
					var warning := $Warning
					warning.play()
				#If chica is in the office, refill the drink
				elif drink_sensitive:
					root.cup_fill = 1
					current_position = positions[current_position].office_entrance.fail_position_index
					_move_animatronic(current_position)
				#If foxy is in the office, ask if he can watch you play games (If you have games)
				elif game_sensitive:
					pass #TODO: Foxy mechanics
				else:
					current_position = positions[current_position].office_entrance.fail_position_index
					_move_animatronic(current_position)
			# If the animatronic is not a friendly edam and checks for your drink
			elif drink_sensitive:
				if root.cup_fill > 0.1:
					root._jumpscare(self)
				else:
					root.cup_fill = 1
					current_position = positions[current_position].office_entrance.fail_position_index
					_move_animatronic(current_position)
					return
			#All jumpscare exceptions/defenses are down. game over :3
			else:
				root._jumpscare(self)
		elif positions[current_position].next_position_indexes.is_empty() == false:
			if positions[current_position].office_entrance != null && root.animatronics_in_office >= positions[current_position].office_entrance.office_animatronic_limit:
				return
			current_position = positions[current_position].next_position_indexes.pick_random()
			if positions[current_position].office_entrance != null:
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
