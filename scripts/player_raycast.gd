extends RayCast3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if Input.is_action_just_pressed(&"LeftClick") && is_colliding():
		get_collider()._raycast_event()
