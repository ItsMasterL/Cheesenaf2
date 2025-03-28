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
var purchased_apps : String = "0x0000"
var money : int = 0
var saw_foxy : bool = false
var saw_foxy_night_1 : bool = false

# Applications
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
	}
enum store_apps_binary {
	MEDIAPLAYER = 0b0000000001,
	FLAPPYFOXY = 0b0000000010,
	CHICAPOP = 0b0000000100,
	TANKTROUBLE = 0b0000001000,
	SOCCERPHYSICS = 0b0000010000,
	POKER = 0b0000100000,
	DRAWING = 0b0001000000,
	ANGRYCHICA = 0b0010000000,
	BONNIESWOODS = 0b0100000000,
	PODCAST = 0b1000000000
	}
var apps : Array[TabletApp] = [
	TabletApp.new("Freddy Fazbear's Media Player", "Play your favorite tunes from your own device, while Freddy Fazbear himself dances along!", "media_player", load("res://textures/icons/edam freddy.png"), 0.00, store_apps_binary.MEDIAPLAYER),
	TabletApp.new("Flappy Foxy", "Make Foxy jump up and down between the Brick%s brand ovens! Touching the floor or the ovens will cause Foxy to die. painfully." % String.chr(8482), "flappy_foxy", load("res://textures/apps/flappyfoxy.png"), 0.00, store_apps_binary.FLAPPYFOXY, 1.25),
	TabletApp.new("Chica Pop", "Tap the screen to make her go pop! Try for the biggest number!! My high score is 4", "chica_pop", load("res://textures/icons/edam chica.png"), 0.00, store_apps_binary.CHICAPOP, 1.25),
	TabletApp.new("Tank Trouble", "Navigate your tank through a simple maze to shoot the opponent's tank! Boy, are these tanks causing some trouble. Wait... say that again...", "tank_trouble", PlaceholderTexture2D.new(), 4.99, store_apps_binary.TANKTROUBLE, 1.5),
	TabletApp.new("Soccer Physics", "Ever wanted to play soccer, but only being able to kick while jumping? Well, now you can! Beat the enemy team!", "soccer_physics", PlaceholderTexture2D.new(), 4.99, store_apps_binary.SOCCERPHYSICS, 1.5),
	TabletApp.new("Freddy's Picture Poker", "The classic game where thousands of children learned to gamble. Oh, not from us though. From the folks over at Nintendo.", "poker", PlaceholderTexture2D.new(), 9.99, store_apps_binary.POKER, 1.75),
	TabletApp.new("Foxy's Paintin' Location", "Turns out, Foxy is quite the artist, and wants to share his art tools with you! Makes sense, I mean, he is a furry after all. You gotta wonder how he can afford so much booty. That, being treasure, you know. (What, is that quote too overdone?)", "drawing", PlaceholderTexture2D.new(), 9.99, store_apps_binary.DRAWING, 1.75),
	TabletApp.new("Angry Chica", "Those bad piggies have taken Chica's cupcake! (Based on a true story!) Help her get it back! (Unfortunately, not based on the true story.)", "angry_birds", PlaceholderTexture2D.new(), 9.99, store_apps_binary.ANGRYCHICA, 1.75),
	TabletApp.new("Bonnie's Woods", "Millions of years ago, Bonnie created the concept of trees. (Not really). You play as Stewart, a mouse who wants to get the Cheese from Bonnie, the CEO of Cheese LLC in the year this takes place, 1792.", "warios_woods", PlaceholderTexture2D.new(), 19.99, store_apps_binary.BONNIESWOODS, 2),
	TabletApp.new("Stringbonnie's Podcast", "A collection of recordings found in the back room of the previous Freddy's location. We don't know who made them, or what they mean. They were found next to the Stringbonnie suit. We believe these stories to be fully fictional.", "podcast", PlaceholderTexture2D.new(), 19.99, store_apps_binary.PODCAST)
]
var purchases : int

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

func _check_app_purchase(app : store_apps_binary) -> bool:
	return purchases & app
func _purchase_app(app : store_apps_binary):
	purchases |= app
