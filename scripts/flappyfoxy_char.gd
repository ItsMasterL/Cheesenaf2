extends CharacterBody2D


signal died

const JUMP_VELOCITY = -800.0

var can_jump = true
var gravity = false

@onready var jump_sound := $Jump
@onready var root = $"../../.."


func _physics_process(delta):
	# Add the gravity.
	if gravity:
		velocity += get_gravity() * delta * 3
	
	# Handle jump.
	if Input.is_action_just_pressed("Interact") && can_jump && root.using_tablet:
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
	
	rotation_degrees = clampf(0 + velocity.y / 25, -90, 90)
	
	var collision_info = move_and_slide()
	# Gravity check due to bug where dying lead to dying on the reset
	if collision_info && can_jump && gravity == true:
		can_jump = false
		jump_sound.stream = load("res://sounds/flappybird-03.wav")
		velocity += get_gravity() * delta * 3
		jump_sound.play()
		died.emit()
		$CollisionShape2D.disabled = true
		await get_tree().create_timer(2).timeout
		$".."._reset()

func _start_game():
	gravity = true
