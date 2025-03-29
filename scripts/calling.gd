extends Control

@onready var audio := $Call
@onready var accept := $Notification/Accept
@onready var decline := $Notification/Decline
@onready var notif = $Notification
@onready var root = get_tree().get_root().get_node("Map")
var call_accepted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_start_call()

func _start_call():
	if root.night < 7:
		await get_tree().create_timer(randf_range(3, 7)).timeout
		audio.play()
		notif.visible = true
		get_tree().create_timer(20).timeout
		if call_accepted == false:
			notif.visible = false
			audio.stop()

func _answer():
	audio.stop()
	#TODO: Call icon in top bar
	audio.stream = load("res://sounds/dialogue/c2call%s.wav" % root.night)
	notif.visible = false
	audio.play()

func _decline():
	audio.stop()
	notif.visible = false
