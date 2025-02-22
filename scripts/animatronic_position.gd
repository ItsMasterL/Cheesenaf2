class_name AnimatronicPosition
extends Resource

@export var position : Vector3
@export var rotation : Vector3
@export var scale : Vector3 = Vector3.ONE
## Which position the animatronic will go to next if their movement check succeeds. Can be empty if this position is one considered in the office. If this field has more than one int, they will be picked from at random.
@export var next_position_indexes : Array[int]
## Determines if this location is in a vent. If so, instead of footstep sounds, vent climbing sounds will play.
@export var is_vent : bool
## Which animation to play at this location. Will loop.
@export var animation_id : String
## Is this position considered within the office; Succeeding a check on one of these spaces will jumpscare the player. Failing will either stall or send back to a specific defined space, depending on the scenario.
@export var office_entrance : EntranceProperty
