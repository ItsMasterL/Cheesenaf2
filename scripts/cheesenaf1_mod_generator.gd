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
var bbgs = [syowen, brett, mocha, alan, freddy, bonnie, chica, foxy]

func _ready():
	if Globals.cheesenaf1_seed == 0:
		_generate_seed()
	_create_bbgs()

func _create_bbgs():
	seed(Globals.cheesenaf1_seed)
	bbgs.shuffle()
	syowen.Name = "Syowen"
	syowen.BBGDialogue = ["Oh, hey. I'm Syowen. What's your name?", "Huh. {0}, huh?", "You seem... well, not the person you claim to be.", "Your spirit is... unknown, to us.", "Do you know who we are?", "Do you know what we represent?", "You've come to us for information that we shouldn't know.", "Make sure you understand what you're getting into.", "%s" % alphabet_dict[string_seed[bbgs.find(syowen)]], "You cannot lie to us.", "Welcome back, {0}..."]
	syowen.color = Color(185, 56, 255)
	brett.Name = "Brett"
	brett.BBGDialogue = ["Yo, what up... Why are you wearing a nametag?", "Dude, your name is {0}? That's... not true", "You are not {0}, dude.", "You're freaking Adam Sandler. You've been in like, 6 movies so far, but I haven't been alive to see any of them.", "Actually, you seem a lot older than I thought. Aren't you supposed to be like 28?", "Yeah, dude, I know. Somehow.", "You look like you're in your 50s...", "What's brought you here? Or else, what brought us to you?", "%s" % alphabet_dict[string_seed[bbgs.find(brett)]], "Don't lie to yourself.", "Welcome back, {0}... except, that's not you dude"]
	brett.color = Color(20, 148, 222)
	mocha.Name = "Mocha"
	mocha.BBGDialogue = ["Heyo! I'm Mocha, and you areeee...?", "You said {0}? Cool, nice to meet you!", "Except... you aren't {0}, are you?", "Oh, it's obvious to us.", "I know why you're here.", "Do you know what this is for?", "Do you know what this all means for the actual {0}?", "What will happen to them, when it's all put together?", "%s" % alphabet_dict[string_seed[bbgs.find(mocha)]], "Maybe stopping here is for the best.", "Welcome back, {0}..."]
	mocha.color = Color(20, 148, 222)
	alan.Name = "Alan"
	alan.BBGDialogue = ["Hey there! What's your name?", "Nice to meet you, {0}, I'm Alan!", "Oh wait... oh... that's, not right. You're not {0}.", "I've been here before. I would have known if it were {0}.", "A code? I don't know what you're talking about but I'll come up with one anyway.", "It doesn't have to be like, super specific does it?", "What is it even for?", "Who's orders are you following?", "%s" % alphabet_dict[string_seed[bbgs.find(alan)]], "Oh. okay bye", "Welcome back, {0}..."]
	alan.color = Color(8, 140, 37)

func _generate_seed():
	string_seed = ""
	for i in 8:
		string_seed += alphabet_dict.keys().pick_random()
	print(string_seed + ": " + str(hash(string_seed)))
	Globals.cheesenaf1_seed = hash(string_seed)

func _create_modpack():
	pass

class Splashes:
	var splashtext = ["gather the code.\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"]

class BBG:
	var Name = "Modded"
	var BBGDialogue = ["This is the introductory line", "This is the first line of text after the username input", "This is the line of dialogue that prompts the yes/no choice", "You chose answer 1. The game proceeds.", "This is the first line after the scene change", "This is the first line after this scene's player dialogue", "This line features disgust from pizza usually", "Second disgust dialogue", "This is the final dialogue before the gameplay transition", "You chose answer 2. The game ends.", "This is the welcome back message, when the BBG already has the player name on starting"]
	var PlayerDialogue = ["How did you\nknow?","No, that is\nme.","I'm here for\na code.","...","...","Thank you."]
	var color = Color(185, 56, 255) #Because of how I named the variables in cheesenaf, this has to be capitalized manually in the json. I dont want to make people update for one easter egg that works now lol
	var OverlayExpression = true

class Pack:
	var Description = "Generated and automatically deleted by Cheesenaf 2."
	var GameVersion = "1.1.0"
	var ModVersion = "1.0.0"
