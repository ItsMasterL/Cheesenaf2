extends Node2D


@export var app_button: PackedScene

var current_process
var using_tablet = false
var fun_multiplier = 1

@onready var home = $Home
@onready var app_home = $Application
@onready var time = $TimeUI/Clock
@onready var root = get_node(^"/root/Map")
@onready var app_container := $Home/GridContainer


func _ready():
	_populate_homescreen()

func _process(_delta):
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

func _purchase_app(app: Globals.store_apps_binary):
	Globals._purchase_app(app)
	_populate_homescreen()
	Globals._save()

func _populate_homescreen():
	for child in app_container.get_children():
		child.queue_free()
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
	root.in_cams = false
	fun_multiplier = 1
