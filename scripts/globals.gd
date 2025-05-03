extends Node

# Office
var night = 0
var edams_friendly = true
var edam_freddy = 0
var edam_bonnie = 0
var edam_chica = 0
var edam_foxy = 0
var wither_freddy = 0
var wither_bonnie = 0
var wither_chica = 0
var wither_foxy = 0
var cheesestick = 0
var safety_time = 2.5
var office_mode = 0 # 0 - Singleplayer, 1 - Co-op, 2 - 1v1 vs, 3 - 2v2 vs
var game_time = 0

# Cheesenaf Code
var cheesenaf1_app = ""
var cheesenaf1_path = ""
var cheesenaf1_code = ""
var cheesenaf1_seed : int

# Multiplayer #TODO: Actually implement multiplayer
var local_playername = ""
var remote_playernames: Array[String]
var is_host = false
var host_ip = "127.0.0.1"

# Save Data
var save_night: int = 1
var purchased_apps: String = "0x0000"
var money: float = 0
var saw_foxy: bool = false
var saw_foxy_night_1: bool = false

# User Settings
var mouse_sensitivity: float = 1.0
var master_volume: float = 1
var sfx_volume: float = 1
var voice_volume: float = 1
var music_volume: float = 1
var tablet_volume: float = 1
var ambient_volume: float = 1
var jumpscare_volume: float = 1
var fullscreen = false
var language = 0
var languages = ["en", "es", "tr"]

#region Applications
enum store_apps {
	MEDIAPLAYER,
	FLAPPYFOXY,
	CHICAPOP,
	TANKTROUBLE,
	SOCCERPHYSICS,
	POKER,
	DRAWING,
	ANGRYCHICA,
	BONNIESWOODS,
	PODCAST,
	FNWF,
}

enum store_apps_binary {
	MEDIAPLAYER = 0b0000_0000_0001,
	FLAPPYFOXY = 0b0000_0000_0010,
	CHICAPOP = 0b0000_0000_0100,
	TANKTROUBLE = 0b0000_0000_1000,
	SOCCERPHYSICS = 0b0000_0001_0000,
	POKER = 0b0000_0010_0000,
	DRAWING = 0b0000_0100_0000,
	ANGRYCHICA = 0b0000_1000_0000,
	BONNIESWOODS = 0b0001_0000_0000,
	PODCAST = 0b0010_0000_0000,
	FNWF = 0b0100_0000_0000,
}

var apps: Array[TabletApp] = [
	TabletApp.new("Freddy Fazbear's Media Player", "MEDIA_DESC", "media_player", load("res://textures/apps/mediaplayer.png"), 0.00, store_apps_binary.MEDIAPLAYER),
	TabletApp.new("Flappy Foxy", "FLAPPY_FOXY_DESC", "flappy_foxy", load("res://textures/apps/flappyfoxy.png"), 0.00, store_apps_binary.FLAPPYFOXY, 1.25),
	TabletApp.new("Chica Pop", "CHICA_POP_DESC", "chica_pop", load("res://textures/apps/chicapopicon.png"), 0.00, store_apps_binary.CHICAPOP, 1.25),
	TabletApp.new("Tank Trouble", "TANK_TROUBLE_DESC", "tank_trouble", load("res://textures/apps/tanktrouble.png"), 4.99, store_apps_binary.TANKTROUBLE, 1.5, false),
	TabletApp.new("Soccer Physics", "SOCCER_PHYS_DESC", "soccer_physics", load("res://textures/apps/soccerphysics.png"), 4.99, store_apps_binary.SOCCERPHYSICS, 1.5, false),
	TabletApp.new("Freddy's Picture Poker", "POKER_DESC", "poker", load("res://textures/apps/poker.png"), 9.99, store_apps_binary.POKER, 1.75),
	TabletApp.new("Foxy's Paintin' Location", "DRAWING_DESC", "drawing", load("res://textures/apps/foxypaint.png"), 9.99, store_apps_binary.DRAWING, 1.75, false),
	TabletApp.new("Angry Chica", "ANGRY_CHICA_DESC", "angry_birds", load("res://textures/apps/angrychica.png"), 9.99, store_apps_binary.ANGRYCHICA, 1.75, false),
	TabletApp.new("Bonnie's Woods", "BONNIE_WOODS_DESC", "warios_woods", load("res://textures/apps/bonnieswoods.png"), 19.99, store_apps_binary.BONNIESWOODS, 2, false),
	TabletApp.new("Stringbonnie's Podcast", "PODCAST_DESC", "podcast", load("res://textures/apps/stringbonnie.png"), 19.99, store_apps_binary.PODCAST),
	TabletApp.new("Five Nights With Freddy (18+)", "FNWF_DESC", "fnwf", load("res://textures/apps/fnwf.png"), 29.99, store_apps_binary.FNWF)
]
#endregion
var purchases: int

func _ready():
	match randi_range(0, 3):
		0:
			if OS.get_name() == "Windows":
				DisplayServer.set_native_icon("res://textures/icons/edam bonnie.ico")
			else:
				DisplayServer.set_icon(load("res://textures/icons/edam bonnie.png"))
		1:
			if OS.get_name() == "Windows":
				DisplayServer.set_native_icon("res://textures/icons/edam chica.ico")
			else:
				DisplayServer.set_icon(load("res://textures/icons/edam chica.png"))
		2:
			if OS.get_name() == "Windows":
				DisplayServer.set_native_icon("res://textures/icons/edam foxy.ico")
			else:
				DisplayServer.set_icon(load("res://textures/icons/edam foxy.png"))

#region Saving/Loading
func _save():
	# This converts app purchases to hexadecimal
	purchased_apps = "%x" % [purchases]
	var data = {
		"night" = save_night,
		"apps" = purchased_apps,
		"money" = money,
		"foxy" = saw_foxy,
		"foxyn1" = saw_foxy_night_1
	}
	var file = FileAccess.open("user://data.json", FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	file.store_line(json_string)

func _load():
	print("Loading user data")
	if FileAccess.file_exists("user://data.json"):
		var file = FileAccess.open("user://data.json", FileAccess.READ)
		while file.get_position() < file.get_length():
			var json_string = file.get_line()

		# Creates the helper class to interact with JSON.
			var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
			var parse_result = json.parse(json_string)
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue

		# Get the data from the JSON object.
			var data = json.data
			if "night" in data && (typeof(data["night"]) == TYPE_INT || typeof(data["night"]) == TYPE_FLOAT):
				save_night = data["night"]
			if "money" in data && (typeof(data["money"]) == TYPE_INT || typeof(data["money"]) == TYPE_FLOAT):
				money = data["money"]
			if "foxy" in data && typeof(data["foxy"]) == TYPE_BOOL:
				saw_foxy = data["foxy"]
			if "foxyn1" in data && typeof(data["foxyn1"]) == TYPE_BOOL:
				saw_foxy_night_1 = data["foxyn1"]
			if "apps" in data && typeof(data["apps"]) == TYPE_STRING:
				purchased_apps = data["apps"]
				purchases = purchased_apps.hex_to_int()

func _save_settings():
	var data = {
		"mouse_sensitivity" = mouse_sensitivity,
		"master_volume" = master_volume,
		"sfx_volume" = sfx_volume,
		"voice_volume" = voice_volume,
		"music_volume" = music_volume,
		"tablet_volume" = tablet_volume,
		"ambient_volume" = ambient_volume,
		"jumpscare_volume" = jumpscare_volume,
		"fullscreen" = fullscreen,
		"language" = language
	}
	var file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	file.store_line(json_string)

func _load_settings():
	print("Loading user settings")
	if FileAccess.file_exists("user://settings.json"):
		var file = FileAccess.open("user://settings.json", FileAccess.READ)
		while file.get_position() < file.get_length():
			var json_string = file.get_line()

		# Creates the helper class to interact with JSON.
			var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
			var parse_result = json.parse(json_string)
			if not parse_result == OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				continue

		# Get the data from the JSON object.
			var data = json.data
			if "mouse_sensitivity" in data && (typeof(data["mouse_sensitivity"]) == TYPE_FLOAT):
				mouse_sensitivity = data["mouse_sensitivity"]
			if "master_volume" in data && (typeof(data["master_volume"]) == TYPE_INT || typeof(data["master_volume"]) == TYPE_FLOAT):
				master_volume = data["master_volume"]
			if "sfx_volume" in data && (typeof(data["sfx_volume"]) == TYPE_INT || typeof(data["sfx_volume"]) == TYPE_FLOAT):
				sfx_volume = data["sfx_volume"]
			if "voice_volume" in data && (typeof(data["voice_volume"]) == TYPE_INT || typeof(data["voice_volume"]) == TYPE_FLOAT):
				voice_volume = data["voice_volume"]
			if "music_volume" in data && (typeof(data["music_volume"]) == TYPE_INT || typeof(data["music_volume"]) == TYPE_FLOAT):
				music_volume = data["music_volume"]
			if "tablet_volume" in data && (typeof(data["tablet_volume"]) == TYPE_INT || typeof(data["tablet_volume"]) == TYPE_FLOAT):
				tablet_volume = data["tablet_volume"]
			if "ambient_volume" in data && (typeof(data["ambient_volume"]) == TYPE_INT || typeof(data["ambient_volume"]) == TYPE_FLOAT):
				ambient_volume = data["ambient_volume"]
			if "jumpscare_volume" in data && (typeof(data["jumpscare_volume"]) == TYPE_INT || typeof(data["jumpscare_volume"]) == TYPE_FLOAT):
				ambient_volume = data["jumpscare_volume"]
			if "fullscreen" in data && typeof(data["fullscreen"]) == TYPE_BOOL:
				fullscreen = data["fullscreen"]
			if "language" in data && typeof(data["language"]) == TYPE_INT || typeof(data["language"]) == TYPE_FLOAT:
				language = clamp(floor(data["language"]),0,2)
		AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
		AudioServer.set_bus_volume_db(1, linear_to_db(sfx_volume))
		AudioServer.set_bus_volume_db(2, linear_to_db(voice_volume))
		AudioServer.set_bus_volume_db(3, linear_to_db(music_volume))
		AudioServer.set_bus_volume_db(4, linear_to_db(ambient_volume))
		AudioServer.set_bus_volume_db(5, linear_to_db(ambient_volume))
		AudioServer.set_bus_volume_db(6, linear_to_db(tablet_volume))
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		TranslationServer.set_locale(languages[language])
#endregion

func _set_night(set_night: int):
	match set_night:
		1:
			Globals.night = 1
			Globals.edams_friendly = true
			Globals.edam_freddy = 3
			Globals.edam_bonnie = 7
			Globals.edam_chica = 7
			Globals.edam_foxy = 7
			Globals.wither_freddy = 0
			Globals.wither_bonnie = 0
			Globals.wither_chica = 0
			Globals.wither_foxy = 0
			Globals.cheesestick = 0
			Globals.safety_time = 5
		2:
			Globals.night = 2
			Globals.edams_friendly = true
			Globals.edam_freddy = 5
			Globals.edam_bonnie = 15
			Globals.edam_chica = 5
			Globals.edam_foxy = 8
			Globals.wither_freddy = 2
			Globals.wither_bonnie = 3
			Globals.wither_chica = 0
			Globals.wither_foxy = 0
			Globals.cheesestick = 0
			Globals.safety_time = 5
		3:
			Globals.night = 3
			Globals.edams_friendly = false
			Globals.edam_freddy = 7
			Globals.edam_bonnie = 0
			Globals.edam_chica = 3
			Globals.edam_foxy = 6
			Globals.wither_freddy = 5
			Globals.wither_bonnie = 3
			Globals.wither_chica = 3
			Globals.wither_foxy = 2
			Globals.cheesestick = 0
			Globals.safety_time = 3
		4:
			Globals.night = 4
			Globals.edams_friendly = false
			Globals.edam_freddy = 8
			Globals.edam_bonnie = 0
			Globals.edam_chica = 9
			Globals.edam_foxy = 4
			Globals.wither_freddy = 8
			Globals.wither_bonnie = 6
			Globals.wither_chica = 5
			Globals.wither_foxy = 6
			Globals.cheesestick = 0
			Globals.safety_time = 2.8
		5:
			Globals.night = 5
			Globals.edams_friendly = false
			Globals.edam_freddy = 9
			Globals.edam_bonnie = 0
			Globals.edam_chica = 9
			Globals.edam_foxy = 2
			Globals.wither_freddy = 9
			Globals.wither_bonnie = 8
			Globals.wither_chica = 6
			Globals.wither_foxy = 7
			Globals.cheesestick = 1
			Globals.safety_time = 2.5
		6:
			Globals.night = 6
			Globals.edams_friendly = false
			Globals.edam_freddy = 10
			Globals.edam_bonnie = 8
			Globals.edam_chica = 10
			Globals.edam_foxy = 7
			Globals.wither_freddy = 10
			Globals.wither_bonnie = 8
			Globals.wither_chica = 7
			Globals.wither_foxy = 8
			Globals.cheesestick = 3
			Globals.safety_time = 2

func _check_app_purchase(app: store_apps_binary) -> bool:
	return purchases & app
	
func _purchase_app(app: store_apps_binary):
	purchases |= app
