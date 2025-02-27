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

# Save Data
var save_night = 1
var purchased_app_ids : Array[int]

func _save():
#TODO: If updating Cheesenaf 1 before publishing alongside Cheesenaf 2 on gamejolt/itch, add a BBGSim mod easter egg in Cheesenaf 2 save data
	var data = {
		"night" = save_night,
		"apps" = purchased_app_ids
	}
	var file = FileAccess.open("user://data.json", FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	file.store_line(json_string)

func _load():
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
			save_night = data["night"]
			#purchased_app_ids = data["apps"]

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
			Globals.safety_time = 2.5
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
