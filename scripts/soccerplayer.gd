extends RigidBody2D

enum DIRECTION
{
	LEFT = 1,
	RIGHT = -1
}

@onready var ground = $GroundCheck
@onready var leg = $Leg
@onready var sfx = $Jump
@onready var ball = $"../Ball"
@onready var root = $"../../.."
@export var is_player = true
@export var facing : DIRECTION = DIRECTION.LEFT
@export var attachment : Node2D
@export var attachment_location : Vector2
@export var attachment_range : Vector2
var wiggle = 0
var cpu_cooldown = 0
var kick = 1
var jump_strength = 600

func _physics_process(delta):
	var local = global_transform.basis_xform(Vector2.UP)
	ground.rotation_degrees = -rotation_degrees
	leg.global_position = global_position
	if facing == DIRECTION.LEFT:
		leg.rotation_degrees = clamp(leg.rotation_degrees, 0, 105)
	else:
		leg.rotation_degrees = clamp(leg.rotation_degrees, -105, 0)
	if is_player:
		if root.using_tablet:
			if ground.is_colliding() or gravity_scale == 0:
				if gravity_scale != 0:
					angular_velocity += (0.01 * -rotation_degrees)
				if Input.is_action_just_pressed("Interact"):
					sfx.play()
					linear_velocity += Vector2(local.x,-jump_strength)
					angular_velocity += kick * facing
					leg.angular_velocity = 0
			if Input.is_action_pressed("Interact"):
				leg.angular_velocity = 18 * facing
			else:
				leg.angular_velocity = -7 * facing
			if Input.is_action_just_released("Interact"):
				leg.angular_velocity = 0
	else:
		if ground.is_colliding() or gravity_scale == 0:
			if gravity_scale != 0:
				angular_velocity += (0.01 * -rotation_degrees)
			leg.angular_velocity = -7 * facing
			if (position.distance_to(ball.position) < 120 or randi_range(0,100) == 92) and cpu_cooldown == 0:
				sfx.play()
				linear_velocity += Vector2(local.x,-jump_strength)
				angular_velocity += kick * facing
				leg.angular_velocity = 0
				cpu_cooldown = 10
		else:
			leg.angular_velocity = 18 * facing
		cpu_cooldown = clamp(cpu_cooldown - 1, 0, 10)
	
	leg.angular_velocity = clamp(leg.angular_velocity, -20, 20)


	
	if attachment != null:
		wiggle += delta
		attachment.global_position = global_position + attachment_location
		if facing == DIRECTION.LEFT:
			attachment.global_rotation_degrees = clamp(global_rotation_degrees + lerp(attachment_range.x, attachment_range.y, sin(wiggle)/ 2 + 0.5), attachment_range.x + global_rotation_degrees, attachment_range.y + global_rotation_degrees)
		else:
			attachment.global_rotation_degrees = clamp(global_rotation_degrees + lerp(attachment_range.y, attachment_range.x, sin(wiggle)/ 2 + 0.5), attachment_range.y + global_rotation_degrees, attachment_range.x + global_rotation_degrees)
