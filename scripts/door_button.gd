extends Area3D

@export var affected_door: EntranceProperty.Entrances
@export var opposing_door: EntranceProperty.Entrances

@onready var root = get_node(^"/root/Map")
@onready var error = get_node("DoorButtonError")

func _raycast_event():
	if root.is_p1:
		return
	var entrances: Array[int]
	for i in root.closed_entrances:
		entrances.append(i)
	if affected_door in entrances:
		# Opening door
		if affected_door in entrances:
			entrances.erase(affected_door)
	else:
		if opposing_door in entrances:
			error.play()
			return
		entrances.append(affected_door)
	root._set_entrances.rpc(entrances)
