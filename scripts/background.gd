extends Sprite2D

var wait_time = 0.015

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if wait_time > 0:
		wait_time -= delta
	else:
		if frame + 1 < vframes:
			frame += 1
		else:
			frame = 0
		wait_time = 0.015
