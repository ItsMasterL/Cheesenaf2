extends Node3D

var night = 1
var time = 0 as float
var hour = 0
var minute = 0
var fun_multiplier = 1 #Set by minigames in singleplayer to make time go by faster
var time_to_hour = 90
var using_tablet = false
var under_desk = false
# Animatronic AI levels; Animatronics will handle their own paths, timers, etc
var edams_friendly = false
var edam_freddy = 0
var edam_bonnie = 0
var edam_chica = 0
var edam_foxy = 0
var wither_freddy = 0
var wither_bonnie = 0
var wither_chica = 0
var wither_foxy = 0
var cheesestick = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += (delta * fun_multiplier)
	hour = floor(time / time_to_hour)
	minute = floor(lerp(hour * 60, hour * 60 + 60, time / time_to_hour)) as int % 60
