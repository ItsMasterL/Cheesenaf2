extends StaticBody3D


signal booped

@onready var root = get_node(^"/root/Map")

func _raycast_event():
	if !root.is_p1:
		return
	booped.emit()
