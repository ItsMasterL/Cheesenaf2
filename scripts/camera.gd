@tool
extends Camera3D

@export var first_rotation : Vector3
@export var second_rotation : Vector3
@export var cam_name : String = "???"
@export var cam_identifier : String = "Camera #"
@onready var parent = $".."

func _process(delta):
	var x = lerpf(first_rotation.x, second_rotation.x, parent.camera_value)
	var y = lerpf(first_rotation.y, second_rotation.y, parent.camera_value)
	var z = lerpf(first_rotation.z, second_rotation.z, parent.camera_value)
	rotation_degrees = Vector3(x,y,z)
