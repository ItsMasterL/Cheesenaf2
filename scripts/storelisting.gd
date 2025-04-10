extends Control


var app_name: String
var app_description: String
var price: float
var icon: Texture2D
var id: Globals.store_apps_binary
var purchased: bool = false
var available: bool = true

@onready var button = $Bg/Get


func _ready():
	$Bg/AppName.text = app_name
	$Bg/Description.text = app_description
	$Bg/Icon/TextureRect.texture = icon
	if available:
		if price == 0:
			button.text = "GET FREE"
		else:
			button.text = "BUY %1.2f" % price
	else:
		button.text = "COMING SOON"
		button.disabled = true
	if Globals._check_app_purchase(id):
		_purchase()

func _purchase():
	purchased = true
	button.disabled = true
	button.text = "DOWNLOADED"
