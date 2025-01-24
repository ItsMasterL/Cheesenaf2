extends Node3D

var rng = RandomNumberGenerator.new()
var jumpscare = false
var chance = 250

@onready var sound := $Skeleton3D/RIG_Foxy_Clean_mo_002/RIG_Foxy_Clean_mo_002/AudioStreamPlayer3D
@onready var anim := $AnimationPlayer

func _on_foxy_plush_nose_booped():
	if jumpscare == false:
		var rand = rng.randi() % chance
		if rand < 8 && sound.playing == true:
			jumpscare = true
			match rand:
				0:
					sound.stream = load("res://Sounds/sting1.wav")
				1:
					sound.stream = load("res://Sounds/sting2.wav")
				2:
					sound.stream = load("res://Sounds/sting3.wav")
				3:
					sound.stream = load("res://Sounds/sting4.wav")
				4:
					sound.stream = load("res://Sounds/sting5.wav")
				5:
					sound.stream = load("res://Sounds/sting6.wav")
				6:
					sound.stream = load("res://Sounds/sting7.wav")
				7:
					sound.stream = load("res://Sounds/sting8.wav")
		sound.play()
		if jumpscare == true:
			anim.play(&"stare")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if jumpscare == true && sound.playing == false:
		sound.stream = load("res://Sounds/boop.wav")
		anim.play(&"stare", -1, -1, true)
		jumpscare = false
