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

# Multiplayer #TODO: Actually implement multiplayer
var local_playername = ""
var remote_playernames : Array[String]
var is_host = false
var host_ip = "127.0.0.1"

# Save Data
var save_night : int = 1
var purchased_apps : int = 0
var money : int = 0
var saw_foxy : bool = false
var saw_foxy_night_1 : bool = false

func _ready():
	match randi_range(0,3):
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

func _save():
#TODO: If updating Cheesenaf 1 before publishing alongside Cheesenaf 2 on gamejolt/itch, add a BBGSim mod easter egg in Cheesenaf 2 save data
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
			if "apps" in data && typeof(data["apps"]) == TYPE_INT:
				purchased_apps = data["apps"]
			print(data["night"])

func _set_night(night: int):
	match night:
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
