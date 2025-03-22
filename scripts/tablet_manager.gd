extends Node2D

var current_process
@onready var home = $Home
@onready var app_home = $Application
@onready var time = $TimeUI/Clock
@onready var root = get_tree().get_root().get_node("Map")
@onready var app_container := $Home/GridContainer
@onready var purchases : int = 0

@export var app_button : PackedScene

enum store_apps {
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

var store_app_ids = {
	store_apps.MEDIAPLAYER: "media_player",
	store_apps.FLAPPYFOXY: "flappy_foxy",
	store_apps.CHICAPOP: "chica_pop",
	store_apps.TANKTROUBLE: "tank_trouble",
	store_apps.SOCCERPHYSICS: "soccer_physics",
	store_apps.POKER: "poker",
	store_apps.DRAWING: "drawing",
	store_apps.ANGRYCHICA: "angry_chica",
	store_apps.BONNIESWOODS: "bonnies_woods",
	store_apps.PODCAST: "podcast"
}

var store_app_names = {
	store_apps.MEDIAPLAYER: "Freddy Fazbear's Media Player",
	store_apps.FLAPPYFOXY: "Flappy Foxy",
	store_apps.CHICAPOP: "Chica Pop",
	store_apps.TANKTROUBLE: "Tank Trouble",
	store_apps.SOCCERPHYSICS: "Soccer Physics",
	store_apps.POKER: "Picture Poker",
	store_apps.DRAWING: "Fazbear's Drawing App",
	store_apps.ANGRYCHICA: "Angry Chica",
	store_apps.BONNIESWOODS: "Bonnie's Woods",
	store_apps.PODCAST: "Stringbonnie's Podcast"
}

func _ready():
	_decode_purchases()
	_populate_homescreen()

func _process(_delta):
	if root.hour == 0:
		time.text = "12:%02d AM" % [root.minute]
	else:
		time.text = "%02d:%02d AM" % [root.hour, root.minute]

func _decode_purchases():
	purchases = Globals.purchased_apps.hex_to_int()

func _purchase_app(app : store_apps):
	purchases |= app
	_populate_homescreen()
	# This converts it to hexadecimal
	Globals.purchased_apps = "%x" % [purchases]
	Globals._save()

func _populate_homescreen():
	for child in app_container.get_children():
		child.queue_free()
	#Setup default apps
	var camsplus = app_button.instantiate()
	camsplus.app_id = "cams_plus"
	camsplus.text = "Cams PLUS"
	camsplus.pressed.connect(_load_application.bind(camsplus.app_id))
	app_container.add_child(camsplus)
	
	var store = app_button.instantiate()
	store.app_id = "gameworld"
	store.text = "Gameworld Store"
	store.pressed.connect(_load_application.bind(store.app_id))
	app_container.add_child(store)
	
	if root.night > 1:
		var vaultmaster = app_button.instantiate()
		vaultmaster.app_id = "vaultmaster"
		vaultmaster.text = "VaultMaster Door Manager"
		vaultmaster.pressed.connect(_load_application.bind(vaultmaster.app_id))
		app_container.add_child(vaultmaster)
	
	for app in store_apps:
		var value = store_apps[app]
		if purchases & value:
			var button = app_button.instantiate()
			button.app_id = store_app_ids[value]
			button.text = store_app_names[value]
			button.pressed.connect(_load_application.bind(button.app_id))
			app_container.add_child(button)

func _load_application(appscene: String):
	if ResourceLoader.exists("res://scenes/%s.tscn" % [appscene]) == false:
		print("Scene \"%s\" doesn't exist! Aborting!" % [appscene])
		return
	if app_home.get_child_count() > 0:
		app_home.get_child(0).queue_free()
	current_process = load("res://scenes/%s.tscn" % [appscene])
	if appscene == "cams_plus":
		root.in_cams = true
	var instance = current_process.instantiate()
	app_home.add_child(instance)
	home.hide()

func _home():
	if app_home.get_child_count() > 0:
		app_home.get_child(0).queue_free()
	home.show()
	root.in_cams = false
