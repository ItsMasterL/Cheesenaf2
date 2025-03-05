extends Control
@onready var cams = $Background/SubViewport/Cameras
@onready var current_cam := $Background/SubViewport/Cameras/Camera4
@onready var light := $Background/SubViewport/Cameras/Camera4/SpotLight3D
@onready var lightsound := $Light
@onready var camsound := $ChangeCam
@onready var root = get_tree().get_root().get_node("Map")
@onready var musicprogress := $Button/ProgressBar
@onready var windsound := $Wind
@onready var musicbox := $Musicbox
var songcount = 10

signal change_dance

func _ready():
	if root.p1_last_cam != null:
		_change_camera(root.p1_last_cam, false)
	# Should be "Animatronics" in office.tscn
	for animatronic in root.get_child(8).get_children():
		if animatronic.music_box_sensitive:
			change_dance.connect(animatronic._change_dance)
	

func _change_camera(cam: int, sound: bool = true):
	current_cam = cams.get_child(cam)
	var lighttemp = light.visible
	light.visible = false
	light = current_cam.get_child(1)
	light.visible = lighttemp
	current_cam.current = true
	if current_cam.name == "Camera4":
		musicbox.volume_db = -15
	else:
		musicbox.volume_db = -40
	if sound:
		camsound.play()
	root.p1_last_cam = cam

func _unhandled_input(event):
	if event.is_action_pressed(&"Flashlight") && root.using_tablet:
		light.visible = true
		lightsound.play()
	if event.is_action_released(&"Flashlight"):
		light.visible = false
		lightsound.stop()

func _process(delta):
	if root.is_winding:
		root.musicbox = clamp(root.musicbox + 1, 0, 2000)
		if windsound.playing == false:
			windsound.play()
	musicprogress.value = root.musicbox
	
	# Randomize musicbox
	if root.musicbox == 0:
		musicbox.stop()
	elif musicbox.playing == false:
		if randi_range(0,4) >= 2:
			var id = randi_range(1,songcount)
			musicbox.stream = load("res://sounds/music/musicbox%s.mp3" % [id])
			change_dance.emit(songcount, id)
		musicbox.play()

func _wind_musicbox(input: bool):
	root.is_winding = input
