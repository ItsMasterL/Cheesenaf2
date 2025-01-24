extends StaticBody3D

signal booped

func _raycast_event():
	booped.emit()
