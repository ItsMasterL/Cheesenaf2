extends Sprite2D


func _ready():
	_animate()

func _animate():
	if frame + 1 < vframes:
		frame += 1
	else:
		frame = 0
	await get_tree().create_timer(0.025).timeout
	_animate()
