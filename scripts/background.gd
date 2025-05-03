extends Sprite2D

@export var time_between_frames = 0.015
var wait_time = 0.015
@export var uses_vframes = true
@export var randomize = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if wait_time > 0:
		wait_time -= delta
	else:
		if randomize:
			if uses_vframes:
				frame = randi_range(0, vframes - 1)
			else:
				frame = randi_range(0, hframes - 1)
		else:
			if (frame + 1 < vframes && uses_vframes) || (frame + 1 < hframes && uses_vframes == false):
				frame += 1
			else:
				frame = 0
		wait_time = time_between_frames
		if randomize:
			wait_time += randf_range(-0.100,0.100)
