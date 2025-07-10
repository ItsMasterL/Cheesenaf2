extends Sprite2D

var direction: Vector2
var lifetime = 5
var origin: int

func _process(delta):
	global_position += direction * delta
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	if position.x < -50:
		position.x = 1340
	elif position.x > 1340:
		position.x = -50
	if position.y < -50:
		position.y = 850
	elif position.y > 850:
		position.y = -50
	var check = material.get("shader_parameter/pal_swap_1") as Color
	if check.a < 1:
		queue_free()
