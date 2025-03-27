extends Sprite2D

var rotate_value : float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_value += delta * 10
	rotation_degrees = floor(rotate_value)
