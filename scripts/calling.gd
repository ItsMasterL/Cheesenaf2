extends Control


var call_accepted

@onready var audio := $Call
@onready var accept := $Notification/Accept
@onready var decline := $Notification/Decline
@onready var notif = $Notification
@onready var root


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().standalone_mode == false:
		root = get_node(^"/root/Map")
		_start_call()
	else:
		set_process(false)

func _process(_delta):
	audio.position = root.tablet.position

func _start_call():
	if root.night < 7 and Globals.office_mode == Globals.OfficeMode.SINGLEPLAYER:
		await get_tree().create_timer(randf_range(3, 7)).timeout
		audio.play()
		notif.visible = true
		await get_tree().create_timer(20).timeout
		if call_accepted == false:
			notif.visible = false
			audio.stop()

func _answer():
	audio.stop()
	#TODO: Call icon in top bar
	if Globals.night == 2 or Globals.night == 3:
		if Globals.saw_foxy_night_1:
			audio.stream = load("res://sounds/dialogue/c2call%sa.wav" % root.night)
		else:
			audio.stream = load("res://sounds/dialogue/c2call%sb.wav" % root.night)
	else:
		audio.stream = load("res://sounds/dialogue/c2call%s.wav" % root.night)
	notif.visible = false
	audio.volume_db = 10
	audio.play()

func _decline():
	audio.stop()
	notif.visible = false
