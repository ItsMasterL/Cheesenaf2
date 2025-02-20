extends StaticBody3D

@onready var fananim := $"../../ENV_MOD_Desk_Fan_Fanblade_ENV_MOD_Desk_Fan_Fanblade_001/AnimationPlayer"
@onready var fansound := $"../../ENV_MOD_Desk_Fan_Fanblade_ENV_MOD_Desk_Fan_Fanblade_001/AudioStreamPlayer3D"
@onready var clicksound := $"../../ENV_MOD_Desk_Fan_Fanblade_ENV_MOD_Desk_Fan_Fanblade_001/FanClick"
var power = true
var speed = 1

func _ready():
	fananim.play(&"spin")

func _raycast_event():
	power = !power
	if fansound.playing == false:
		fansound.play()
	clicksound.play()

func _process(delta):
	if power:
		speed += delta * 0.25
	else:
		speed -= delta * 0.25
	speed = clamp(speed, 0, 1)
	fananim.speed_scale = speed
	if speed == 0:
		fansound.stop()
		fansound.pitch_scale = 0.1
	else:
		fansound.pitch_scale = speed
		fansound.volume_db = (1 - speed) * -40
