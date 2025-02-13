extends Node3D

var time = 0 as float
var hour = 0
var minute = 0
var funMultiplier = 1 #Set by minigames in singleplayer to make time go by faster
var timeToHour = 90

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += (delta * funMultiplier)
	hour = floor(time / timeToHour)
	minute = floor(lerp(hour * 60, hour * 60 + 60, time / timeToHour)) as int % 60
