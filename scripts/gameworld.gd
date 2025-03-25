extends Node2D

@export var listing_template : PackedScene
@onready var os = $"../../"
@onready var app_container = $ScrollContainer/Appcontainer

func _ready():
	$Music.play()
	for app in Globals.apps:
		var listing = listing_template.instantiate()
		listing.app_name = app.app_name
		listing.app_description = app.app_description
		listing.price = app.price
		listing.icon = app.icon
		listing.id = app.global_id
		listing.get_child(0).get_child(3).pressed.connect(_buy.bind(listing))
		app_container.add_child(listing)

func _buy(listing : Control):
	if Globals.money >= listing.price:
		Globals.money -= listing.price
		os._purchase_app(listing.id)
		listing._purchase()
