extends Node2D


signal start_game

var speed = 400
var game_started = false
var score = 0
var died = false

@onready var OvenA = $OvenA
@onready var OvenB = $OvenB
@onready var root = $"../.."


func _ready():
	$Music.play()

func _process(delta):
	if Input.is_action_just_pressed("LeftClick") && game_started == false && root.using_tablet:
		game_started = true
		start_game.emit()
	
	if game_started:
		OvenA.position -= Vector2(delta * speed, 0)
		OvenB.position -= Vector2(delta * speed, 0)
		speed += delta * 5
	
	if OvenA.position.x < -150:
		OvenA.position = Vector2(1500, randi_range(210, 600))
		if died == false:
			$"Pass sound".play()
			score += 1
			$Home/Score.text = str(score)
	if OvenB.position.x < -150:
		OvenB.position = Vector2(1500, randi_range(210, 600))
		if died == false:
			$"Pass sound".play()
			score += 1
			$Home/Score.text = str(score)

func _reset():
	root._load_application("flappy_foxy")

func _death():
	died = true
