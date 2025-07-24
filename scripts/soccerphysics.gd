extends Node2D

enum EFFECTS
{
	NONE, #Normal
	BIG_BALL, #Ball is bigger and heavier
	TINY_BALL, #Ball is smaller and floatier
	BIG_GOAL, #Goal is bigger
	TINY_GOAL, #Goal is smaller
	#BIG_PLAYERS, #Players are bigger and slower
	#TINY_PLAYERS, #Players are smaller and faster
	BIG_KICKS, #Kicks send players spinning
	SLIPPERY, #Every object loses friction
	ANTI_GRAVITY, #Nothing has gravity and players can jump in the air. Also they spin more and have less powerful jumps
	THE_WORLD_ENDS #Joke - Final hours music plays, the ball is replaced with a majora's mask moon, which falls slowly, has insane mass, and resets the game after crashing (rare)
}#																			   vv "Big Players", "Tiny Players",
const EFFECT_NAMES = ["None", "Big Ball", "Tiny Ball", "Big Goal", "Tiny Goal", "Big Kicks", "Slippery", "Anti-Gravity", "your world is ending."]

@export var players: Array[Node2D]
@export var goals: Array[Node2D]
@export var ball: Node2D
@export var player_pos: Array[Vector2]
@export var ball_pos: Vector2
@onready var text_display = $Display
@onready var root = $"../.."
var selected_effect: EFFECTS = EFFECTS.NONE
var player_score = 0
var cpu_score = 0

func _ready():
	$Home/Music.play()
	_setup(false)

func _process(delta):
	if selected_effect as int == EFFECTS.THE_WORLD_ENDS:
		_world_ending(delta)

func _player_scores(_area):
	player_score += 1
	_setup()

func _cpu_scores(_area):
	cpu_score += 1
	_setup()

func _out_of_bounds(_area):
	_setup()

func _world_ending(delta):
	for i in get_children():
		if i != $Cover:
			i.modulate = lerp(i.modulate, Color.hex(0x7c0032FF), delta/60)
	ball.position.y += delta * 2.555
	ball.rotation_degrees = 0
	if ball.position.y > -120:
		$Cover.modulate = lerp($Cover.modulate, Color.WHITE, delta/5)
	if ball.position.y > -90:
		root._home()



func _setup(random_effect = true):
	if random_effect == true:
		selected_effect = EFFECTS[EFFECTS.keys()[randi_range(0,EFFECTS.size() - 2)]]
		if randi_range(0,1792) == 1792:
			selected_effect = EFFECTS.THE_WORLD_ENDS
			print("It's happening again.")
	else:
		selected_effect = EFFECTS.NONE

	text_display.text = "%s-%s\nCurrent Effect: %s" % [cpu_score, player_score, EFFECT_NAMES[selected_effect as int]]

	var p_grav = 1
	var p_mass = 1
	var p_frict = 1
	var p_bounc = 0
	var b_pos = ball_pos
	var b_vel = Vector2.ZERO
	var b_grav = 1
	var b_mass = 1
	var b_frict = 0.5
	var b_bounc = 0.8
	for i in players:
		i.jump_strength = 600
		i.kick = 1
	for i in goals:
		i.scale = Vector2(2.65,2.65)
	ball.get_child(0).shape.radius = 29
	ball.get_child(1).scale = Vector2(2,2)

	match selected_effect:
		EFFECTS.BIG_BALL:
			ball.get_child(0).shape.radius = 80
			ball.get_child(1).scale = Vector2(5.6,5.6)
			b_grav = 0.25
			b_mass = 2
			b_bounc = 1

		EFFECTS.TINY_BALL:
			ball.get_child(0).shape.radius = 11
			ball.get_child(1).scale = Vector2(0.75,0.75)
			b_grav = 3
			b_mass = 0.33
			b_bounc = 0.4
		EFFECTS.BIG_GOAL:
			for i in goals:
				i.scale = Vector2(5,5)
		EFFECTS.TINY_GOAL:
			for i in goals:
				i.scale = Vector2(1.5,1.5)
		#EFFECTS.BIG_PLAYERS:
		#	p_scale = Vector2(2,2)
		#	p_grav = 0.25
		#	p_mass = 2
		#	for i in players:
		#		i.jump_strength = 300
		#EFFECTS.TINY_PLAYERS:
		#	p_scale = Vector2(0.25,0.25)
		#	p_grav = 0.25
		#	p_mass = 2
		#	p_frict = 0.8
		#	for i in players:
		#		i.jump_strength = 800
		EFFECTS.BIG_KICKS:
			for i in players:
				i.kick = 8
		EFFECTS.SLIPPERY:
			b_frict = 0
			p_frict = 0
		EFFECTS.ANTI_GRAVITY:
			p_grav = 0.1
			b_grav = 0.1
			b_vel = Vector2(0,-1)
			for i in players:
				i.kick = 2
				i.jump_strength = 100
		EFFECTS.THE_WORLD_ENDS:
			$Home/Music.stop()
			$Home/Music.stream = load("res://sounds/music/game_over.mp3")
			$Home/Music.play()
			root.fun_multiplier = 0
			ball.get_child(0).shape.radius = 710
			ball.get_child(1).scale = Vector2(50,50)
			ball.z_index = 2
			ball.collision_layer = 8
			ball.collision_mask = 8
			ball.set_deferred("freeze", true)
			b_grav = 0
			b_mass = 1000
			b_bounc = 0
			b_frict = 0
			b_pos = Vector2(ball_pos.x, -700)
	
	var ii = 0
	for i in players:
		_set_phys(i,player_pos[ii],Vector2.ZERO,i.angular_velocity,p_grav,p_mass,p_frict,p_bounc)
		i.leg.angular_velocity = 0
		ii += 1
	_set_phys(ball,b_pos,b_vel,0,b_grav,b_mass,b_frict,b_bounc)

	
func _set_phys(object: RigidBody2D,pos = object.global_position, linear_velocity = object.linear_velocity, angular_velocity = object.angular_velocity, gravity = object.gravity_scale, mass = object.mass, friction = object.physics_material_override.friction, bounce = object.physics_material_override.bounce):
	var id = object.get_rid()
	object.global_transform = Transform2D.IDENTITY.translated(pos)
	PhysicsServer2D.body_set_state(id,PhysicsServer2D.BODY_STATE_TRANSFORM,Transform2D.IDENTITY.translated(pos))
	object.linear_velocity = linear_velocity
	PhysicsServer2D.body_set_state(id,PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY,linear_velocity)
	object.angular_velocity = angular_velocity
	PhysicsServer2D.body_set_state(id,PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY,angular_velocity)
	object.gravity_scale = gravity
	PhysicsServer2D.body_set_param(id,PhysicsServer2D.BODY_PARAM_GRAVITY_SCALE,gravity)
	object.mass = mass
	PhysicsServer2D.body_set_param(id,PhysicsServer2D.BODY_PARAM_MASS,mass)
	object.physics_material_override.friction = friction
	PhysicsServer2D.body_set_param(id,PhysicsServer2D.BODY_PARAM_FRICTION,friction)
	object.physics_material_override.bounce = bounce
	PhysicsServer2D.body_set_param(id,PhysicsServer2D.BODY_PARAM_BOUNCE,bounce)
