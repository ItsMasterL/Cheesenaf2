extends RayCast3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_colliding():
		var hit = get_collider()
		if Input.is_action_just_pressed("LeftClick"):
			hit._raycast_event()
