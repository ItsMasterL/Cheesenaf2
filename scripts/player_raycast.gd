extends RayCast3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if Input.is_action_just_pressed(&"Interact") && is_colliding() && get_collider().has_method("_raycast_event"):
		get_collider()._raycast_event()

func _manual_raycast():
	if is_colliding() && get_collider().has_method("_raycast_event"):
		get_collider()._raycast_event()
