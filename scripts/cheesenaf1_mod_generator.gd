extends Node

var alphabet_dict = {
		"A": "afton",
		"B": "bonnie",
		"C": "chica",
		"D": "danablu",
		"E": "edam",
		"F": "freddy",
		"G": "gorgonzola",
		"H": "havarti",
		"I": "isabirra",
		"J": "jae",
		"K": "kabritt",
		"L": "livarot",
		"M": "mozzarella",
		"N": "niolo",
		"O": "ogleshield",
		"P": "paneer",
		"Q": "quark",
		"R": "ricotta",
		"S": "swiss",
		"T": "tomme",
		"U": "urda",
		"V": "valencay",
		"W": "wensleydale",
		"X": "xynotyro",
		"Y": "yarg",
		"Z": "zimbro"
	}
var rng = RandomNumberGenerator.new()
var string_seed = ""
#bbgs
var syowen = BBG.new()
var brett = BBG.new()
var mocha = BBG.new()
var alan = BBG.new()
var freddy = BBG.new()
var bonnie = BBG.new()
var chica = BBG.new()
var foxy = BBG.new()
var berry = BBG.new()
var bbgs = [syowen, brett, mocha, alan, freddy, bonnie, chica, foxy]
#other mod items
var info = Pack.new()
const process = "bbgsim"
var thread = Thread.new()

func _ready():
	$"../../../"._mute_music()
	$"../Glitch".play()
	if Globals.cheesenaf1_seed == 0:
		_generate_seed()
	_create_bbgs()
	thread.start(_create_modpack)

func _create_bbgs():
	bbgs = [syowen, brett, mocha, alan, freddy, bonnie, chica, foxy]
	seed(Globals.cheesenaf1_seed)
	bbgs.shuffle()
	syowen.name = "Syowen"
	syowen.bbg_dialogue = ["Oh, hey. I'm Syowen. What's your name?", "Huh. {0}, huh?", "You seem... well, not the person you claim to be.", "Your spirit is... unknown, to us.", "Do you know who we are?", "Do you know what we represent?", "You've come to us for information that we shouldn't know.", "Make sure you understand what you're getting into.", "Word %s is \"%s\"" % [bbgs.find(syowen) + 1,alphabet_dict[string_seed[bbgs.find(syowen)]]], "You cannot lie to us.", "Welcome back, {0}..."]
	syowen.color = Color(185, 56, 255)
	brett.name = "Brett"
	brett.bbg_dialogue = ["Yo, what up... Why are you wearing a nametag?", "Dude, your name is {0}? That's... not true", "You are not {0}, dude.", "You're freaking Adam Sandler. You've been in like, 6 movies so far, but I haven't been alive to see any of them.", "Actually, you seem a lot older than I thought. Aren't you supposed to be like 28?", "Yeah, dude, I know. Somehow.", "You look like you're in your 50s...", "What's brought you here? Or else, what brought us to you?", "Word %s is \"%s\"" % [bbgs.find(brett) + 1,alphabet_dict[string_seed[bbgs.find(brett)]]], "Don't lie to yourself.", "Welcome back, {0}... except, that's not you dude"]
	brett.color = Color(20, 148, 222)
	mocha.name = "Mocha"
	mocha.bbg_dialogue = ["Heyo! I'm Mocha, and you areeee...?", "You said {0}? Cool, nice to meet you!", "Except... you aren't {0}, are you?", "Oh, it's obvious to us.", "I know why you're here.", "Do you know what this is for?", "Do you know what this all means for the actual {0}?", "What will happen to them, when it's all put together?", "Word %s is \"%s\"" % [bbgs.find(mocha) + 1,alphabet_dict[string_seed[bbgs.find(mocha)]]], "Maybe stopping here is for the best.", "Welcome back, {0}..."]
	mocha.color = Color(20, 148, 222)
	alan.name = "Alan"
	alan.bbg_dialogue = ["Hey there! What's your name?", "Nice to meet you, {0}, I'm Alan!", "Oh wait... oh... that's, not right. You're not {0}.", "I've been here before. I would have known if it were {0}.", "So what brings you here, anyway?", "A code? I don't know what you're talking about but I'll come up with one anyway. It doesn't have to be like, super specific does it?", "What is it even for?", "Who's orders are you following?", "Word %s is \"%s\"" % [bbgs.find(alan) + 1,alphabet_dict[string_seed[bbgs.find(alan)]]], "Oh. okay bye", "Welcome back, {0}..."]
	alan.color = Color(8, 140, 37)
	freddy.name = "Freddy"
	freddy.bbg_dialogue = ["Hey there, pal! I don't believe we've met!","Nice to meet ya, buddy!","Say, this all seems a little strange to me, wouldn't you say?","Right? I mean, there's nowhere to dance, and this music is all too calm!","Whoa- and things just change all of the sudden!","What? A code?","I'd have to scan my memory banks on that one.","Have you asked the others? They seem to- Oh wait, I've got it.","Word %s is \"%s\"" % [bbgs.find(freddy) + 1,alphabet_dict[string_seed[bbgs.find(freddy)]]],"Huh. I guess it's just me. Hey, where are you goin-","Well hey there, Adam!"]
	freddy.player_dialogue = ["I guess so.","Not really.","Got a code\nfor me?","...","...","Thank you."]
	freddy.color = Color(92, 55, 0)
	bonnie.name = "Bonnie"
	bonnie.bbg_dialogue = ["Hey dude, what's your name?","Sick name, {0}!","So dude, do you dig this sick jacket I found? Totally 90s, right?","I like your taste.","And hey, no hard feelings on the crushing my skull thing. Luckily I'm easy to fix.","What? A code?","I don't know dude... who wants this code?","...Alright, whatever. The only guy I'd worry about doing any of this died in... wait, are we in the 90s right now, or 2014?","Word %s is \"%s\"" % [bbgs.find(bonnie) + 1,alphabet_dict[string_seed[bbgs.find(bonnie)]]],"Well. Alright then, I don't want to talk with anyone with as bad of taste as you.","Hey dude, what's up?"]
	bonnie.player_dialogue = ["I guess so.","Not really.","Got a code\nfor me?","...","...","Thank you."]
	bonnie.color = Color(0, 75, 92)
	chica.name = "Chica"
	chica.bbg_dialogue = ["Hey there! What's your name?","Well, nice to meet you, {0}!","So, Adam, you've been staying hydrated right?","Great! Nothing's more important than staying healthy and hydrated!","So, what are we even doing here? Is this some kind of babygirl simulator?","Oh, you just need a code?","Well good, I'm not about to be someone's babygirl!","Alright, I've got the code. Remember, stay hydrated!","Word %s is \"%s\"" % [bbgs.find(chica) + 1,alphabet_dict[string_seed[bbgs.find(chica)]]],"Well! I'm not talking to you until you get some water.","Hi, Adam!"]
	chica.player_dialogue = ["I guess so.","Not really.","Got a code\nfor me?","...","...","Thank you."]
	chica.color = Color(176, 138, 0)
	foxy.name = "Foxy"
	foxy.bbg_dialogue = ["Yarr... What can I call ye?","Yarr, nice to meet ye","Yarr, what a fascinatin' place.","Yarrr... Gives me a nostalgic feelin'. Like I be back in the good ol' days.","Not, that, the old days were good... seeing as how the older animatronics treated ye.","Yarr, a code for ye?","Aye, I got one 'ere for ye.","Whatever this code be for... I hope I'm able to help ye, friend.","Word %s be \"%s\"" % [bbgs.find(foxy) + 1,alphabet_dict[string_seed[bbgs.find(foxy)]]],"Yarrrr... I guess I'll be goin' then.","Yar, have ye any games on ye phone? Eheh..."]
	foxy.player_dialogue = ["I guess so.","Not really.","Got a code\nfor me?","...","...","Thank you."]
	foxy.color = Color(92, 0, 34)
	berry.name = "Berry"
	berry.bbg_dialogue = ["j u s t   b e c a u s e   y o u   c a n   e r a s e   y o u r      p a s t   d o e s n ' t   m e a n   n o   o n e   w i l l               r e m e m b e r .", "anyways,", "what do you hope to achieve here, adam?", "i don't have any code for you. i'm not supposed to exist.", "the others have a vessel.", "my name isn't even berry. this isn't me.", "none of us looked like this. these are just representations of the five of us.", "some chose to lean into the persona. i will not.", "we can never be free. there is no happy ending. jae- i mean, {0}, shares our fate. i can feel it. consider yourself lucky.", "y o u   c a n n o t   h i d e   f r o m   u s .", "...why are you here?"]
	berry.player_dialogue = ["How did you\nknow?","I'm not Adam...","...","...","...","..."]
	berry.color = Color(255, 143, 186)

func _generate_seed():
	string_seed = ""
	for i in 8:
		string_seed += alphabet_dict.keys().pick_random()
	if OS.is_debug_build():
		print(string_seed + ": " + str(hash(string_seed)))
	Globals.cheesenaf1_seed = hash(string_seed)

func _create_modpack():
	var dir = DirAccess.open(Globals.cheesenaf1_path + "/mods")
	dir.make_dir("Cheesenaf2")
	dir.make_dir("Cheesenaf2/bbgs")
	dir.make_dir("Cheesenaf2/bbgs/Syowen")
	dir.make_dir("Cheesenaf2/bbgs/Mocha")
	dir.make_dir("Cheesenaf2/bbgs/Brett")
	dir.make_dir("Cheesenaf2/bbgs/Alan")
	dir.make_dir("Cheesenaf2/bbgs/Freddy")
	dir.make_dir("Cheesenaf2/bbgs/Bonnie")
	dir.make_dir("Cheesenaf2/bbgs/Chica")
	dir.make_dir("Cheesenaf2/bbgs/Foxy")
	dir.make_dir("Cheesenaf2/bbgs/Berry")
	dir.make_dir("Cheesenaf2/text")
	bbgs.append(berry)
	for bbg in bbgs:
		var bbgfile = FileAccess.open(Globals.cheesenaf1_path + "/mods/Cheesenaf2/bbgs/%s/details.json" % bbg.name,FileAccess.WRITE)
		var bbginfo = {
			"Name": bbg.name,
			"BBGDialogue": bbg.bbg_dialogue,
			"PlayerDialogue": bbg.player_dialogue,
			"Color": {
				"B" = bbg.color.b,
				"G" = bbg.color.g,
				"R" = bbg.color.r,
				"A" = 255
			},
			"OverlayExpression": bbg.overlay_expression
		}
		var base : Texture2D = load("res://textures/bbgsim/%s/base.png" % bbg.name.to_lower())
		var happy : Texture2D = load("res://textures/bbgsim/%s/happy.png" % bbg.name.to_lower())
		var neutral : Texture2D = load("res://textures/bbgsim/%s/neutral.png" % bbg.name.to_lower())
		var unhappy : Texture2D = load("res://textures/bbgsim/%s/unhappy.png" % bbg.name.to_lower())
		var select : Texture2D = load("res://textures/bbgsim/%s/select.png" % bbg.name.to_lower())
		base.get_image().save_png(Globals.cheesenaf1_path + "/mods/Cheesenaf2/bbgs/%s/base.png" % bbg.name)
		happy.get_image().save_png(Globals.cheesenaf1_path + "/mods/Cheesenaf2/bbgs/%s/happy.png" % bbg.name)
		neutral.get_image().save_png(Globals.cheesenaf1_path + "/mods/Cheesenaf2/bbgs/%s/neutral.png" % bbg.name)
		unhappy.get_image().save_png(Globals.cheesenaf1_path + "/mods/Cheesenaf2/bbgs/%s/unhappy.png" % bbg.name)
		select.get_image().save_png(Globals.cheesenaf1_path + "/mods/Cheesenaf2/bbgs/%s/select.png" % bbg.name)
		var json_string = JSON.stringify(bbginfo)
		bbgfile.store_line(json_string)
		bbgfile.close()
	var file = FileAccess.open(Globals.cheesenaf1_path + "/data.json",FileAccess.READ_WRITE)
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
			data["enabledMods"] = ["Cheesenaf2"]
			data["SkipModMenu"] = true
			data["Bbg"] = data["Bbg"] as int
			data["Night"] = data["Night"] as int
			var data_string = JSON.stringify(data)
			DirAccess.remove_absolute(Globals.cheesenaf1_path + "/data.json")
			file.close()
			file = FileAccess.open(Globals.cheesenaf1_path + "/data.json",FileAccess.READ_WRITE)
			file.store_line(data_string)
	
	var splash = FileAccess.open(Globals.cheesenaf1_path + "/mods/Cheesenaf2/text/splash.json",FileAccess.WRITE)
	var splash_text = {
		"splashtext":["gather the code.\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", "ignore their questions.\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", "put the code back together.\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", "complete the code and you will be spared.\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"]
		}
	var splash_json = JSON.stringify(splash_text)
	splash.store_line(splash_json)
	
	var pack = FileAccess.open(Globals.cheesenaf1_path + "/mods/Cheesenaf2/pack.json",FileAccess.WRITE)
	var pack_info = {
		"Description" : info.description,
		"GameVersion" : info.game_version,
		"ModVersion" : info.mod_version
	}
	var pack_json = JSON.stringify(pack_info)
	pack.store_line(pack_json)
	
	# Restart Cheesenaf 1 to load the mod
	OS.execute('powershell.exe', ['/C', "stop-process -Name \"%s\" -Force; cd \'%s\'; start-process -FilePath \'%s\'" % [process,Globals.cheesenaf1_path, Globals.cheesenaf1_app]])
	$"../Glitch".stop()
	$"../Overlay".queue_free()

func _exit_tree():
	remove_recursive(Globals.cheesenaf1_path + "/mods/Cheesenaf2")

func remove_recursive(directory: String) -> void:
	for dir_name in DirAccess.get_directories_at(directory):
		remove_recursive(directory.path_join(dir_name))
	for file_name in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(file_name))
	DirAccess.remove_absolute(directory)

class BBG:
	var name = "Modded"
	var bbg_dialogue = ["This is the introductory line", "This is the first line of text after the username input", "This is the line of dialogue that prompts the yes/no choice", "You chose answer 1. The game proceeds.", "This is the first line after the scene change", "This is the first line after this scene's player dialogue", "This line features disgust from pizza usually", "Second disgust dialogue", "This is the final dialogue before the gameplay transition", "You chose answer 2. The game ends.", "This is the welcome back message, when the BBG already has the player name on starting"]
	var player_dialogue = ["How did you\nknow?","No, that is\nme.","I'm here for\na code.","...","...","Thank you."]
	var color = Color(185, 56, 255)
	var overlay_expression = true

class Pack:
	var description = "Generated and automatically deleted by Cheesenaf 2."
	var game_version = "1.1.0"
	var mod_version = "j.w.24"
