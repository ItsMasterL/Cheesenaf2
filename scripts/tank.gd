extends Sprite2D

@export var is_player = false
@export var id: int
@export var bullet: PackedScene
@export var body_color: Color
@export var outline_color: Color
@onready var root = $"../../../.."
const SPEED = 55
var animation_frame = 0
var iframes = 1
var spawn: Vector2
var move_dir = 0 #-1 backwards, 1 forwards
#CPU
var target: Node2D
var cooldown = 0

func _ready():
	spawn = global_position

func _process(delta):
	var local_up = global_transform.basis_xform(Vector2.UP)
	var local_down = global_transform.basis_xform(Vector2.DOWN)
	var animation_speed = 0
	move_dir = 0

	if is_player:
		if root.using_tablet:
			if Input.is_action_pressed("TankForward"):
				global_position = Vector2(global_position.x + (local_up.x * delta * SPEED), global_position.y + (local_up.y * delta * SPEED))
				animation_speed += 10
				move_dir = 1
			elif Input.is_action_pressed("TankBackward"):
				global_position = Vector2(global_position.x + (local_down.x * delta * SPEED), global_position.y + (local_down.y * delta * SPEED))
				animation_speed += 10
				move_dir = -1
			if Input.is_action_pressed("TankLeft"):
				rotation_degrees -= 120 * delta
				animation_speed += 5
			elif Input.is_action_pressed("TankRight"):
				rotation_degrees += 120 * delta
				animation_speed += 5

			if Input.is_action_just_pressed("TankFire"):
				_fire()
	else:
		if target == null:
			_find_target()
		elif target.iframes > 0:
			_find_target()
		var goal
		if target != null:
			goal = global_position.direction_to(target.global_position).angle() + PI / 2
		else:
			goal = global_position.direction_to(Vector2(randi_range(0,1280),randi_range(0,800))).angle() + PI / 2

		rotation = rotate_toward(rotation,goal,0.0075)
		if target != null:
			if global_position.distance_to(target.global_position) > 250 and global_position.distance_to(target.global_position) < 700:
					global_position = Vector2(global_position.x + (local_up.x * delta * SPEED), global_position.y + (local_up.y * delta * SPEED))
					animation_speed += 10
					move_dir = 1
					if randi_range(0,200) == 17:
						_fire()
						cooldown = randf_range(0.25,1.2)
			elif global_position.distance_to(target.global_position) <= 250:
				if cooldown == 0:
					_fire()
					cooldown = randf_range(0.25,1.6)
			else:
				_find_target()
			cooldown = clamp(cooldown - delta, 0, 2)
	
	if position.x < -50:
		position.x = 1340
	elif position.x > 1340:
		position.x = -50
	if position.y < -50:
		position.y = 850
	elif position.y > 850:
		position.y = -50

	

	animation_frame += animation_speed * delta
	frame = floor(animation_frame) as int % 2
	
	if iframes > 0:
		material.set("shader_parameter/pal_swap_1", body_color * ((sin(iframes * 20)/3) + 0.5))
		material.set("shader_parameter/pal_swap_2", outline_color * ((sin(iframes * 20)/3) + 0.5))
		iframes = clamp(iframes - delta, 0, 1)
	else:
		material.set("shader_parameter/pal_swap_1", body_color * 1)
		material.set("shader_parameter/pal_swap_2", outline_color * 1)

func _fire():
		if iframes > 0:
			return
		var local_up = global_transform.basis_xform(Vector2.UP)
		var cannonball = bullet.instantiate()
		var mod = 0
		if move_dir > 0:
			mod = SPEED
		elif move_dir < 0:
			mod = -SPEED
		cannonball.position = global_position + local_up * 8
		cannonball.direction = local_up * (120 + mod)
		cannonball.material = material
		cannonball.origin = id
		$"../..".add_child(cannonball)
		get_child(1).play()

func _death(collider):
	if iframes > 0:
		return
	if collider.get_parent().origin != id:
		global_position = spawn
		iframes = 1
		$"../.."._update_scores(id,collider.get_parent().origin)
		collider.get_parent().queue_free()
		get_child(2).play()
		target = null

func _find_target():
		var tanks = $"..".get_children()
		tanks.remove_at(tanks.find(self))
		tanks.sort_custom(target_sorting)
		while tanks.size() > 0 and tanks[0].iframes > 0:
			tanks.remove_at(0)
		if tanks.size() > 0:
			target = tanks[0]

func target_sorting(target1, target2):
	var distance1 = target1.position.distance_squared_to(global_position)
	var distance2 = target2.position.distance_squared_to(global_position)
	return distance1 <= distance2
