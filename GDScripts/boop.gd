extends StaticBody3D
var rng = RandomNumberGenerator.new()
var jumpscare = false
var chance = 250
@onready var sound := get_parent_node_3d().get_node("AudioStreamPlayer3D") as AudioStreamPlayer3D

func _raycast_event():
	var anim = get_parent_node_3d().get_parent_node_3d().get_parent_node_3d().get_parent_node_3d().get_node("AnimationPlayer") as AnimationPlayer
	if jumpscare == false:
		if rng.randi_range(0,chance) == 1 && sound.playing == true:
			sound.stream = load("res://Sounds/sting1.wav")
			jumpscare = true
		elif rng.randi_range(0,chance) == 2 && sound.playing == true:
			sound.stream = load("res://Sounds/sting2.wav")
			jumpscare = true
		elif rng.randi_range(0,chance) == 3 && sound.playing == true:
			sound.stream = load("res://Sounds/sting3.wav")
			jumpscare = true
		elif rng.randi_range(0,chance) == 4 && sound.playing == true:
			sound.stream = load("res://Sounds/sting4.wav")
			jumpscare = true
		elif rng.randi_range(0,chance) == 5 && sound.playing == true:
			sound.stream = load("res://Sounds/sting5.wav")
			jumpscare = true
		elif rng.randi_range(0,chance) == 6 && sound.playing == true:
			sound.stream = load("res://Sounds/sting6.wav")
			jumpscare = true
		elif rng.randi_range(0,chance) == 7 && sound.playing == true:
			sound.stream = load("res://Sounds/sting7.wav")
			jumpscare = true
		elif rng.randi_range(0,chance) == 8 && sound.playing == true:
			sound.stream = load("res://Sounds/sting8.wav")
			jumpscare = true
		sound.play(0)
		if jumpscare == true:
			anim.play("stare")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if jumpscare == true && sound.playing == false:
		var anim = get_parent_node_3d().get_parent_node_3d().get_parent_node_3d().get_parent_node_3d().get_node("AnimationPlayer") as AnimationPlayer
		sound.stream = load("res://Sounds/boop.wav")
		anim.play("stare", -1, -1, true)
		jumpscare = false
