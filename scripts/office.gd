extends Node3D

var time = 0 as float
var hour = 0
var minute = 0
var fun_multiplier = 1 #Set by minigames in singleplayer to make time go by faster
var time_to_hour = 90

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += (delta * fun_multiplier)
	hour = floor(time / time_to_hour)
	minute = floor(lerp(hour * 60, hour * 60 + 60, time / time_to_hour)) as int % 60
