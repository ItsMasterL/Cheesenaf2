extends Control


signal change_dance
signal paranormal_dance

const SONG_COUNT = 10

@onready var cams = $Background/SubViewport/Cameras
@onready var current_cam := $Background/SubViewport/Cameras/Camera4
@onready var light := $Background/SubViewport/Cameras/Camera4/SpotLight3D
@onready var light_sound := $Light
@onready var cam_sound := $ChangeCam
@onready var root = get_tree().get_root().get_node("Map")
@onready var music_progress := $WindMusicbox/ProgressBar
@onready var wind_sound := $Wind
@onready var music_box := $Musicbox
@onready var cam_buttons = $RoomCams
@onready var vents = false


func _ready():
	if root.p1_vent_cam:
		cams = $Background/SubViewport/VentCameras
		cam_buttons = $VentCams
		$RoomCams.visible = false
		$VentCams.visible = true
		vents = true
	if root.p1_last_cam != null:
		_change_camera(root.p1_last_cam, false)
	# Should be "Animatronics" in office.tscn
	for animatronic in root.animatronics.get_children():
		if animatronic.music_box_sensitive:
			change_dance.connect(animatronic._change_dance)
			paranormal_dance.connect(animatronic._paranormal_dance)
		if animatronic.paranormal:
			animatronic.paranormal_song.connect(_reset_musicbox)
	for button in cam_buttons.get_children() as Array[Button]:
		if button.name.contains("Cam"):
			button.pressed.connect(_change_camera.bind(button.name.trim_prefix("Cam").to_int()))
	
func _process(_delta):
	if root.is_winding:
		if wind_sound.playing == false:
			wind_sound.play()
	music_progress.value = root.music_box
	
	# Randomize music_box
	if root.music_box == 0:
		music_box.stop()
	elif music_box.playing == false:
		if root.paranormal_attacking == false:
			if randi_range(0, 4) >= 2:
				var id = randi_range(1, SONG_COUNT)
				music_box.stream = load("res://sounds/music/music_box%s.mp3" % [id])
				if root.musicbox_ran_out == false || root.edams_friendly:
					change_dance.emit(SONG_COUNT, id)
		else:
			music_box.stream = load("res://sounds/music/cheesestick.mp3")
			paranormal_dance.emit()
		music_box.play()
		
func _unhandled_input(event):
	if event.is_action_pressed(&"Flashlight") && root.using_tablet:
		light.visible = true
		light_sound.play()
	if event.is_action_released(&"Flashlight"):
		light.visible = false
		light_sound.stop()

func _change_camera(cam: int, sound: bool = true):
	current_cam = cams.get_child(cam - 1)
	var light_temp = light.visible
	light.visible = false
	light = current_cam.get_child(1)
	light.visible = light_temp
	current_cam.current = true
	if current_cam.name == "Camera4" && vents == false:
		music_box.volume_db = -15
	else:
		music_box.volume_db = -40
	if sound:
		cam_sound.play()
	root.p1_last_cam = cam
	$CameraLabel.text = str(current_cam.cam_identifier) + "\n" + str(current_cam.cam_name)

func _toggle_vents():
	vents = !vents
	if vents:
		cams = $Background/SubViewport/VentCameras
		cam_buttons = $VentCams
		$RoomCams.visible = false
		$VentCams.visible = true
		cam_sound.play()
		root.p1_vent_cam = true
	else:
		cams = $Background/SubViewport/Cameras
		cam_buttons = $RoomCams
		$RoomCams.visible = true
		$VentCams.visible = false
		cam_sound.play()
		root.p1_vent_cam = false
	for button in cam_buttons.get_children() as Array[Button]:
		if button.name.contains("Cam"):
			button.pressed.connect(_change_camera.bind(button.name.trim_prefix("Cam").to_int()))
	_change_camera(1, false)

func _wind_musicbox(input: bool):
	root.is_winding = input

func _reset_musicbox():
	music_box.stop()
