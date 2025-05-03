extends Node2D


var anim_timer: float
var anim_offset = false
var score = 0

@onready var chica := $Chica
@onready var score_display := $Chica/Score
@onready var root = $"../.."


func _ready():
	$Music.play()

func _process(delta):
	anim_timer += delta
	if anim_timer > 0.3:
		anim_timer = 0
		anim_offset = !anim_offset
	
	if Input.is_action_pressed("Interact") && root.using_tablet:
		chica.frame = 2
	else:
		chica.frame = 0
	if anim_offset:
		chica.frame += 1
	
	if Input.is_action_just_pressed("Interact") && root.using_tablet:
		score += 1
		$Pop.play()
		score_display.text = str(score)
	if Input.is_action_just_released("Interact") && root.using_tablet:
		$Unpop.play()
