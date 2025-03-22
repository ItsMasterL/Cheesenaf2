extends Control
@onready var cams = $Background/SubViewport/Cameras
@onready var current_cam := $Background/SubViewport/Cameras/Camera4
@onready var light := $Background/SubViewport/Cameras/Camera4/SpotLight3D
@onready var lightsound := $Light
@onready var camsound := $ChangeCam
@onready var root = get_tree().get_root().get_node("Map")
@onready var musicprogress := $WindMusicbox/ProgressBar
@onready var windsound := $Wind
@onready var musicbox := $Musicbox
@onready var cambuttons = $RoomCams
@onready var vents = false
var songcount = 10

signal change_dance
signal paranormal_dance

func _ready():
	if root.p1_last_cam != null:
		_change_camera(root.p1_last_cam, false)
	if root.p1_vent_cam:
		cams = $Background/SubViewport/VentCameras
		cambuttons = $VentCams
		$RoomCams.visible = false
		$VentCams.visible = true
	# Should be "Animatronics" in office.tscn
	for animatronic in root.animatronics.get_children():
		if animatronic.music_box_sensitive:
			change_dance.connect(animatronic._change_dance)
			paranormal_dance.connect(animatronic._paranormal_dance)
		if animatronic.paranormal:
			animatronic.paranormal_song.connect(_reset_musicbox)
	for button in cambuttons.get_children() as Array[Button]:
		if button.name.contains("Cam"):
			button.pressed.connect(_change_camera.bind(button.name.trim_prefix("Cam").to_int()))
	

func _change_camera(cam: int, sound: bool = true):
	current_cam = cams.get_child(cam - 1)
	var lighttemp = light.visible
	light.visible = false
	light = current_cam.get_child(1)
	light.visible = lighttemp
	current_cam.current = true
	if current_cam.name == "Camera4" && vents == false:
		musicbox.volume_db = -15
	else:
		musicbox.volume_db = -40
	if sound:
		camsound.play()
	root.p1_last_cam = cam
	$CameraLabel.text = str(current_cam.cam_identifier) + "\n" + str(current_cam.cam_name)

func _toggle_vents():
	vents = !vents
	if vents:
		cams = $Background/SubViewport/VentCameras
		cambuttons = $VentCams
		$RoomCams.visible = false
		$VentCams.visible = true
		camsound.play()
		root.p1_vent_cam = true
	else:
		cams = $Background/SubViewport/Cameras
		cambuttons = $RoomCams
		$RoomCams.visible = true
		$VentCams.visible = false
		camsound.play()
		root.p1_vent_cam = true
	for button in cambuttons.get_children() as Array[Button]:
		if button.name.contains("Cam"):
			button.pressed.connect(_change_camera.bind(button.name.trim_prefix("Cam").to_int()))
	_change_camera(1, false)

func _unhandled_input(event):
	if event.is_action_pressed(&"Flashlight") && root.using_tablet:
		light.visible = true
		lightsound.play()
	if event.is_action_released(&"Flashlight"):
		light.visible = false
		lightsound.stop()

func _process(delta):
	if root.is_winding:
		if windsound.playing == false:
			windsound.play()
	musicprogress.value = root.musicbox
	
	# Randomize musicbox
	if root.musicbox == 0:
		musicbox.stop()
	elif musicbox.playing == false:
		if root.paranormal_attacking == false:
			if randi_range(0,4) >= 2:
				var id = randi_range(1,songcount)
				musicbox.stream = load("res://sounds/music/musicbox%s.mp3" % [id])
				if root.musicbox_ran_out == false:
					change_dance.emit(songcount, id)
		else:
			musicbox.stream = load("res://sounds/music/cheesestick.mp3")
			paranormal_dance.emit()
		musicbox.play()

func _wind_musicbox(input: bool):
	root.is_winding = input

func _reset_musicbox():
	musicbox.stop()
