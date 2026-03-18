extends StaticBody3D


@onready var root = get_node(^"/root/Map")
@onready var stand := $"../.."
@onready var hold = root.p1_cup_holder
@onready var mesh = $".."
# Made to keep cup mechanics identical to how it worked previously
var local_cup_fill = 1

func _raycast_event():
	if !root.is_p1:
		return
	var tablet = get_parent_node_3d()
	var temp_parent = tablet.get_parent_node_3d()
	if stand == temp_parent:
		temp_parent.remove_child(tablet)
		hold.add_child(tablet)
		var audio := tablet.get_child(1)
		var anim := tablet.get_child(2)
		if root.cup_fill > 0 and root.is_p1:
			audio.play()
		anim.play(&"cup_drink")

func _drink_water():
	local_cup_fill = clamp(local_cup_fill - root.p1_thirst, 0, 1)
	_update_water()

func _end_drink():
	var tablet = get_parent_node_3d()
	var temp_parent = tablet.get_parent_node_3d()
	temp_parent.remove_child(tablet)
	stand.add_child(tablet)
	root.cup_fill = clamp(root.cup_fill - root.p1_thirst, 0, 1)
	local_cup_fill = root.cup_fill
	_update_water()
	root.p1_thirst = 0

func _update_water():
	var current_value = snappedf(mesh.get_blend_shape_value(0),0.01)
	if current_value != snappedf(local_cup_fill,0.01):
		if current_value > local_cup_fill:
			mesh.set_blend_shape_value(0,current_value - get_physics_process_delta_time() / 2)
		else:
			mesh.set_blend_shape_value(0,current_value + get_physics_process_delta_time() / 3)
		await get_tree().create_timer(0.016).timeout
		_update_water()
	else:
		mesh.set_blend_shape_value(0,local_cup_fill)
