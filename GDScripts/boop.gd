extends StaticBody3D

func _raycast_event() -> void:
	var sound = get_parent_node_3d().get_node("AudioStreamPlayer3D") as AudioStreamPlayer3D
	sound.play(0)
