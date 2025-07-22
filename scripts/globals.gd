extends Node

enum OfficeMode {
	SINGLEPLAYER,
	CO_OP,
	ONE_VS_ONE,
	TWO_VS_TWO,
}

const NIGHT_DATA = {
	1: {"edams_friendly": true, "edam_freddy": 3, "edam_bonnie": 7, "edam_chica": 7, "edam_foxy": 7, "wither_freddy": 0, "wither_bonnie": 0, "wither_chica": 0, "wither_foxy": 0, "cheesestick": 0, "safety_time": 5},
	2: {"edams_friendly": true, "edam_freddy": 5, "edam_bonnie": 15, "edam_chica": 5, "edam_foxy": 8, "wither_freddy": 2, "wither_bonnie": 3, "wither_chica": 0, "wither_foxy": 0, "cheesestick": 0, "safety_time": 5},
	3: {"edams_friendly": false, "edam_freddy": 7, "edam_bonnie": 0, "edam_chica": 3, "edam_foxy": 6, "wither_freddy": 5, "wither_bonnie": 3, "wither_chica": 3, "wither_foxy": 2, "cheesestick": 0, "safety_time": 3},
	4: {"edams_friendly": false, "edam_freddy": 8, "edam_bonnie": 0, "edam_chica": 9, "edam_foxy": 4, "wither_freddy": 8, "wither_bonnie": 6, "wither_chica": 5, "wither_foxy": 6, "cheesestick": 0, "safety_time": 2.8},
	5: {"edams_friendly": false, "edam_freddy": 9, "edam_bonnie": 0, "edam_chica": 9, "edam_foxy": 2, "wither_freddy": 9, "wither_bonnie": 8, "wither_chica": 6, "wither_foxy": 7, "cheesestick": 1, "safety_time": 2.5},
	6: {"edams_friendly": false, "edam_freddy": 10, "edam_bonnie": 8, "edam_chica": 10, "edam_foxy": 7, "wither_freddy": 10, "wither_bonnie": 8, "wither_chica": 7, "wither_foxy": 8, "cheesestick": 3, "safety_time": 2},
}

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
var office_mode: OfficeMode = OfficeMode.SINGLEPLAYER
var game_time = 0

# Cheesenaf Code
var cheesenaf1_app = ""
var cheesenaf1_path = ""
var cheesenaf1_code = ""
var cheesenaf1_seed: int

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
	TabletApp.new("Tank Trouble", "TANK_TROUBLE_DESC", "tank_trouble", load("res://textures/apps/tanktrouble.png"), 4.99, store_apps_binary.TANKTROUBLE, 1.5),
	TabletApp.new("Soccer Physics", "SOCCER_PHYS_DESC", "soccer_physics", load("res://textures/apps/soccerphysics.png"), 4.99, store_apps_binary.SOCCERPHYSICS, 1.5),
	TabletApp.new("Freddy's Picture Poker", "POKER_DESC", "poker", load("res://textures/apps/poker.png"), 9.99, store_apps_binary.POKER, 1.75),
	TabletApp.new("Foxy's Paintin' Location", "DRAWING_DESC", "drawing", load("res://textures/apps/foxypaint.png"), 9.99, store_apps_binary.DRAWING, 1.75),
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
	print("Saving user data")
	# This converts app purchases to hexadecimal
	purchased_apps = "%x" % [purchases]
	var data = {
		"night" = save_night,
		"apps" = purchased_apps,
		"money" = money,
		"foxy" = saw_foxy,
		"foxyn1" = saw_foxy_night_1,
		"code" = cheesenaf1_code,
		"seed" = cheesenaf1_seed
	}
	var file = FileAccess.open("user://data.json", FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	file.store_line(json_string)

func _load():
	print("Loading user data")
	if FileAccess.file_exists("user://data.json"):
		var file = FileAccess.open("user://data.json", FileAccess.READ)
		var json_string = file.get_as_text()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if parse_result != OK:
			print("JSON Parse Error: ", json.get_error_message())
			return

		# Get the data from the JSON object.
		var data = json.data
		if "night" in data and typeof(data["night"]) in [TYPE_INT, TYPE_FLOAT]:
			save_night = data["night"]
		if "money" in data and typeof(data["money"]) in [TYPE_INT, TYPE_FLOAT]:
			money = data["money"]
		if "foxy" in data and typeof(data["foxy"]) == TYPE_BOOL:
			saw_foxy = data["foxy"]
		if "foxyn1" in data and typeof(data["foxyn1"]) == TYPE_BOOL:
			saw_foxy_night_1 = data["foxyn1"]
		if "code" in data and typeof(data["code"]) == TYPE_STRING:
			cheesenaf1_code = data["code"]
		if "seed" in data and typeof(data["seed"]) in [TYPE_INT, TYPE_FLOAT]:
			cheesenaf1_seed = data["seed"]
		if "apps" in data and typeof(data["apps"]) == TYPE_STRING:
			purchased_apps = data["apps"]
			purchases = purchased_apps.hex_to_int()

func _save_settings():
	print("Saving user settings")
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
		var json_string = file.get_as_text()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if parse_result != OK:
			print("JSON Parse Error: ", json.get_error_message())
		else:
			# Get the data from the JSON object.
			var data = json.data
			if "mouse_sensitivity" in data and typeof(data["mouse_sensitivity"]) == TYPE_FLOAT:
				self.mouse_sensitivity = data["mouse_sensitivity"]
			if "master_volume" in data and typeof(data["master_volume"]) in [TYPE_INT, TYPE_FLOAT]:
				self.master_volume = data["master_volume"]
			if "sfx_volume" in data and typeof(data["sfx_volume"]) in [TYPE_INT, TYPE_FLOAT]:
				self.sfx_volume = data["sfx_volume"]
			if "voice_volume" in data and typeof(data["voice_volume"]) in [TYPE_INT, TYPE_FLOAT]:
				self.voice_volume = data["voice_volume"]
			if "music_volume" in data and typeof(data["music_volume"]) in [TYPE_INT, TYPE_FLOAT]:
				self.music_volume = data["music_volume"]
			if "tablet_volume" in data and typeof(data["tablet_volume"]) in [TYPE_INT, TYPE_FLOAT]:
				self.tablet_volume = data["tablet_volume"]
			if "ambient_volume" in data and typeof(data["ambient_volume"]) in [TYPE_INT, TYPE_FLOAT]:
				self.ambient_volume = data["ambient_volume"]
			if "jumpscare_volume" in data and typeof(data["jumpscare_volume"]) in [TYPE_INT, TYPE_FLOAT]:
				self.ambient_volume = data["jumpscare_volume"]
			if "fullscreen" in data and typeof(data["fullscreen"]) == TYPE_BOOL:
				self.fullscreen = data["fullscreen"]
			if "language" in data and typeof(data["language"]) == TYPE_INT or typeof(data["language"]) == TYPE_FLOAT:
				self.language = clamp(floor(data["language"]), 0, 2)
		AudioServer.set_bus_volume_db(0, linear_to_db(self.master_volume))
		AudioServer.set_bus_volume_db(1, linear_to_db(self.sfx_volume))
		AudioServer.set_bus_volume_db(2, linear_to_db(self.voice_volume))
		AudioServer.set_bus_volume_db(3, linear_to_db(self.music_volume))
		AudioServer.set_bus_volume_db(4, linear_to_db(self.ambient_volume))
		AudioServer.set_bus_volume_db(5, linear_to_db(self.ambient_volume))
		AudioServer.set_bus_volume_db(6, linear_to_db(self.tablet_volume))
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		TranslationServer.set_locale(languages[language])
#endregion

func _set_night(night_number: int):
	var data = NIGHT_DATA[night_number]
	self.night = night_number
	self.edams_friendly = data["edams_friendly"]
	self.edam_freddy = data["edam_freddy"]
	self.edam_bonnie = data["edam_bonnie"]
	self.edam_chica = data["edam_chica"]
	self.edam_foxy = data["edam_foxy"]
	self.wither_freddy = data["wither_freddy"]
	self.wither_bonnie = data["wither_bonnie"]
	self.wither_chica = data["wither_chica"]
	self.wither_foxy = data["wither_foxy"]
	self.cheesestick = data["cheesestick"]
	self.safety_time = data["safety_time"]

func _check_app_purchase(app: store_apps_binary) -> bool:
	return purchases & app
	
func _purchase_app(app: store_apps_binary):
	purchases |= app
