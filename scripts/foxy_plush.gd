extends Node3D


var rng = RandomNumberGenerator.new()
var jumpscare = false
var chance = 250

@onready var sound := $Skeleton3D/RIG_Foxy_Clean_mo_002/RIG_Foxy_Clean_mo_002/AudioStreamPlayer
@onready var anim := $AnimationPlayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if jumpscare == true && sound.playing == false:
		sound.stream = load("res://sounds/boop.wav")
		anim.play(&"stare", -1, -1, true)
		jumpscare = false

func _on_foxy_plush_nose_booped():
	if jumpscare == false:
		var rand = rng.randi() % chance
		if rand < 8 && sound.playing == true:
			jumpscare = true
			sound.stream = load("res://sounds/sting%s.wav" % [rand + 1])
		sound.play()
		if jumpscare == true:
			anim.play(&"stare")
