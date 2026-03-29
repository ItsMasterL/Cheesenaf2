extends Node3D


@export var audio : AudioStreamPlayer
@export var anim : AnimationPlayer
@export var laptop : Node
@export var os : Node2D
@export var screen_collider : Node
@export var laptop_collider : Node

@onready var stand = laptop.get_parent()
@onready var root = get_node(^"/root/Map")
@onready var hold = root.p2_laptop_holder
@onready var cursor = root.p2_cursor

func _raycast_event():
	if root.is_p1:
		return
	var temp_parent = laptop.get_parent_node_3d()
	if !root.using_laptop:
		temp_parent.remove_child(laptop)
		hold.add_child(laptop)
		anim.play(&"flip_up", -1, 1, false)
		root.using_laptop = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		cursor.hide()
		audio.play()
	elif screen_collider.is_mouse_inside == false and !root.is_laptop_closed:
		temp_parent.remove_child(laptop)
		stand.add_child(laptop)
		root.using_laptop = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		cursor.show()
		audio.play()

func _unhandled_input(event):
	if event.is_action_pressed("LaptopLid"):
		_laptop_lid(root.is_laptop_closed)
	if event.is_action_released("LaptopLid") and !anim.is_playing() and root.is_laptop_closed:
		_laptop_lid(root.is_laptop_closed)
	if event.is_action_pressed("LaptopHome"):
		os._home()

func _laptop_lid(is_opening: bool):
	if is_opening:
		anim.play_backwards("Close")
		root.using_laptop = false
	else:
		anim.play("Close")
		if get_parent() == hold:
			root.using_laptop = true
	root.is_laptop_closed = !is_opening
