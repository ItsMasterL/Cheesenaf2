extends Sprite2D

var waittime = 0.025
@onready var sprite := get_node(".") as Sprite2D
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if waittime > 0:
		waittime -= delta
	elif sprite.frame + 1 < sprite.vframes:
		sprite.frame += 1
		waittime = 0.025
	else:
		sprite.frame = 0
		waittime = 0.025
