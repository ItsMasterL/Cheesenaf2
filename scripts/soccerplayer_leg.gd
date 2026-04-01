extends RigidBody2D

@onready var player = get_parent()

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if player.facing == player.DIRECTION.LEFT:
		rotation_degrees = clamp(rotation_degrees, 0, 105)
	else:
		rotation_degrees = clamp(rotation_degrees, -105, 0)
