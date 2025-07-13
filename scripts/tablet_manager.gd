extends Node2D


@export var app_button: PackedScene

var current_process
var using_tablet = false
var fun_multiplier = 1
# Media Player
var playlist: Array[String]
var queued_media: String = ""
var is_media_playing = false
var is_video = false
var volume = 100
var media_player_is_open = false
var is_paused = true # Originally used for the media player, but it loses its place so its currently used just for start/stopped states

@export var standalone_mode = false # For the extras menu option
@onready var home = $Home
@onready var app_home = $Application
@onready var time = $TimeUI/Clock
@onready var root = get_node(^"/root/Map")
@onready var app_container := $Home/GridContainer
# Media Player
@onready var audio_player := $MediaPlayer


func _ready():
	_populate_homescreen()

func _process(_delta):
	if standalone_mode:
		pass
	else:
		if root.hour == 0:
			time.text = "12:%02d AM" % [root.minute]
		else:
			time.text = "%02d:%02d AM" % [root.hour, root.minute]
		# For compatibility
		using_tablet = root.using_tablet
		if using_tablet:
			root.fun_multiplier = fun_multiplier
		else:
			root.fun_multiplier = 1
		#Media Player
		if media_player_is_open == false:
			_media_process(_delta)


func _purchase_app(app: Globals.store_apps_binary):
	Globals._purchase_app(app)
	_populate_homescreen()
	Globals._save()

func _populate_homescreen():
	for child in app_container.get_children():
		child.queue_free()
	
	if standalone_mode == false:
		#Setup default apps
		var camsplus = app_button.instantiate()
		camsplus.app_id = "cams_plus"
		camsplus.text = "Cams PLUS"
		camsplus.icon = load("res://textures/apps/camsplus.png")
		camsplus.pressed.connect(_load_application.bind(camsplus.app_id))
		app_container.add_child(camsplus)

		var store = app_button.instantiate()
		store.app_id = "gameworld"
		store.text = "Gameworld Store"
		store.icon = load("res://textures/apps/gameworld.png")
		store.pressed.connect(_load_application.bind(store.app_id))
		app_container.add_child(store)

		if root.night > 1:
			var vaultmaster = app_button.instantiate()
			vaultmaster.app_id = "vaultmaster"
			vaultmaster.text = "VaultMaster Door Manager"
			vaultmaster.icon = load("res://textures/apps/vaultmaster.png")
			vaultmaster.pressed.connect(_load_application.bind(vaultmaster.app_id))
			app_container.add_child(vaultmaster)
	
	var purchased_apps = 0
	for app in Globals.store_apps_binary:
		var bin = Globals.store_apps_binary[app]
		var value = Globals.store_apps[app]
		if Globals._check_app_purchase(bin):
			purchased_apps += 1
			var button = app_button.instantiate()
			button.app_id = Globals.apps[value].app_id
			button.text = Globals.apps[value].app_name
			button.icon = Globals.apps[value].icon
			button.pressed.connect(_load_application.bind(button.app_id, Globals.apps[value].fun_multiplier))
			app_container.add_child(button)
	if standalone_mode == false:
		root.purchased_apps = purchased_apps

func _load_application(appscene: String, fun: float = fun_multiplier):
	if app_home.get_child_count() > 0:
		app_home.get_child(0).queue_free()
	if ResourceLoader.exists("res://scenes/apps/%s.tscn" % [appscene]) == false:
		print("Scene \"%s\" doesn't exist! Aborting!" % [appscene])
		return
	if app_home.get_child_count() > 0:
		app_home.get_child(0).queue_free()
	current_process = load("res://scenes/apps/%s.tscn" % [appscene])
	if appscene == "cams_plus":
		root.in_cams = true
	var instance = current_process.instantiate()
	app_home.add_child(instance)
	fun_multiplier = fun
	home.hide()

func _home():
	if app_home.get_child_count() > 0:
		app_home.get_child(0).queue_free()
	home.show()
	if standalone_mode == false:
		root.in_cams = false
		fun_multiplier = 1

func _media_process(_delta):
	is_media_playing = audio_player.playing
	if queued_media != "" and is_media_playing == false:
		if queued_media.ends_with(".mp3") and audio_player.stream == null:
			is_video = false
			var file = FileAccess.open(queued_media, FileAccess.READ)
			var sound = AudioStreamMP3.new()
			sound.data = file.get_buffer(file.get_length())
			audio_player.stream = sound
			audio_player.play()
			queued_media = ""
		elif queued_media.ends_with(".wav") and audio_player.stream == null:
			queued_media = ""
			return # They just play back static rn
			is_video = false
			var file = FileAccess.open(queued_media, FileAccess.READ)
			var sound = AudioStreamWAV.new()
			sound.data = file.get_buffer(file.get_length())
			audio_player.play()
			queued_media = ""
		elif queued_media.ends_with(".ogg") and audio_player.stream == null:
			is_video = false
			audio_player.stream = AudioStreamOggVorbis.load_from_file(queued_media)
			audio_player.play()
			queued_media = ""
		elif audio_player.stream == null:
			print("Discarded file %s" % [queued_media])
			queued_media = ""

	elif playlist.size() > 0 and queued_media == "":
		queued_media = playlist[0]
		playlist.remove_at(0)
		#if root.is_paused == false:
		#	audio_player.stop()
		#	audio_player.stream = null
