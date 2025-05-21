extends RayCast3D


func _physics_process(delta):
	if Input.is_action_pressed(&"Flashlight") and is_colliding() and get_collider().get_name() == "Eyes":
		if get_collider().get_node("../../../..").has_method("_flash"):
			get_collider().get_node("../../../..")._flash(2 * delta)
