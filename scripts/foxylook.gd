extends RayCast3D


var foxy: Array[Node3D]
var last_look

@onready var root = get_tree().get_root().get_node("Map")


func _ready():
	for animatronic in root.animatronics.get_children():
		if animatronic.game_sensitive:
			foxy.append(animatronic)

func _physics_process(_delta):
	if is_colliding() && get_collider() && get_collider() != last_look:
		if get_collider().get_name() == "friend": # On Foxy's head. Making eye contact
			for fella in foxy:
				fella.object_of_interest = $"../.."
		else:
			for fella in foxy:
				fella.object_of_interest = get_collider()
		last_look = get_collider()
