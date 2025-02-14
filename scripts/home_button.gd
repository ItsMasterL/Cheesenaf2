extends Area3D

var is_mouse_inside = false

func _on_mouse_exited():
	is_mouse_inside = false

func _on_mouse_entered():
	is_mouse_inside = true
