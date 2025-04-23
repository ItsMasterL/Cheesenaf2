extends StaticBody3D


var power = true
var speed = 1

@onready var fan_anim := $"../../ENV_MOD_Desk_Fan_Fanblade_ENV_MOD_Desk_Fan_Fanblade_001/AnimationPlayer"
@onready var fan_sound := $"../../ENV_MOD_Desk_Fan_Fanblade_ENV_MOD_Desk_Fan_Fanblade_001/AudioStreamPlayer3D"
@onready var click_sound := $"../../ENV_MOD_Desk_Fan_Fanblade_ENV_MOD_Desk_Fan_Fanblade_001/FanClick"
@onready var root = $"../.."


func _ready():
	fan_anim.play(&"spin")

func _process(delta):
	if power:
		speed += delta * 0.25
	else:
		speed -= delta * 0.25
	speed = clamp(speed, 0, 1)
	fan_anim.speed_scale = speed
	if speed == 0:
		fan_sound.stop()
		fan_sound.pitch_scale = 0.1
	else:
		fan_sound.pitch_scale = speed
		fan_sound.volume_db = (1 - speed) * -40

func _raycast_event():
	power = !power
	if fan_sound.playing == false:
		fan_sound.play()
	click_sound.play()
	root.fan_powered = power
