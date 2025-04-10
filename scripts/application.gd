class_name TabletApp
extends Resource


var app_name: String = "APPNAME"
var app_description: String = "DESCRIPTION"
var app_id: String
var icon: Texture2D = PlaceholderTexture2D.new()
var price: float = 0
var global_id: Globals.store_apps
var fun_multiplier: float = 1
var available: bool = true


func _init(_app_name: String, _app_description: String, _app_id: String, _icon: Texture2D, _price: float, _global_id, _fun_multiplier: float = 1, _available: bool = true):
	app_name = _app_name
	app_description = _app_description
	app_id = _app_id
	icon = _icon
	price = _price
	global_id = _global_id
	fun_multiplier = _fun_multiplier
	available = _available
