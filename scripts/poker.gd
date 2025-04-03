extends Node2D

@export var card_scene : PackedScene
@onready var player_cards = $PlayerCards
@onready var cpu_cards = $CPUCards
var player_score : Array[int]
var cpu_score : Array[int]
enum values {
	Foxy,Chica,Bonnie,Freddy,Cheesestick,Afton
}
var phase = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Music.play()
	_start_phase(0)

func _process(delta):
	if phase == 1:
		$Table/Draw.text = "HOLD"
		for card in player_cards.get_children():
			if card.selected_for_reshuffle:
				$Table/Draw.text = "DRAW"

func _start_phase(p: int):
	match p:
		0:
			await _deal_cards(cpu_cards)
			await _deal_cards(player_cards, true)
			_flip_cards(player_cards, true)
			await get_tree().create_timer(0.25).timeout
			phase = 1
			$Table/Draw.visible = true
		2:
			$Table/Draw.visible = false
			for card in player_cards.get_children():
				if card.selected_for_reshuffle:
					card._flip_card(false)
					card.anim.play("sent")
			await get_tree().create_timer(1).timeout
			for card in player_cards.get_children():
				if card.selected_for_reshuffle:
					card.card_value = randi_range(0,values.size() - 1)
					card._flip_card(true)
					card.anim.play("draw")
			await get_tree().create_timer(1).timeout
			_flip_cards(cpu_cards, true)
			await get_tree().create_timer(1).timeout
			_evaluate()
			await get_tree().create_timer(2).timeout
			for card in player_cards.get_children():
				card.queue_free()
			for card in cpu_cards.get_children():
				card.queue_free()
			phase = 0
			$Table/Result.visible = false
			_start_phase(0)

func _deal_cards(side: Node2D, selectable = false):
	for i in 5:
		var card = card_scene.instantiate()
		side.add_child(card)
		card.selectable = selectable
		card.card_value = randi_range(0,values.size() - 1)
		card.position = Vector2(200 * i, card.position.y)
		card.anim.play("draw")
		#TODO: Add sound effects
		await get_tree().create_timer(0.25).timeout

func _flip_cards(side: Node2D, faceup: bool):
	for child in side.get_children():
		child.face_up = faceup

func _evaluate():
	player_score.clear()
	cpu_score.clear()
	for card in player_cards.get_children():
		player_score.append(card.card_value)
	for card in cpu_cards.get_children():
		cpu_score.append(card.card_value)
	var player_previous_highest = 0
	var player_highest_count = 0
	var player_previous_highest_value = 0
	var player_highest_count_value = 0
	var cpu_previous_highest = 0
	var cpu_highest_count = 0
	var cpu_previous_highest_value = 0
	var cpu_highest_count_value = 0
	for i in values.size():
		var count = player_score.count(i)
		if count > player_highest_count:
			player_previous_highest = player_highest_count
			player_previous_highest_value = player_highest_count_value
			player_highest_count = count
			player_highest_count_value = i
		elif count == player_highest_count:
			if player_highest_count_value < i:
				player_previous_highest = player_highest_count
				player_previous_highest_value = player_highest_count_value
				player_highest_count = count
				player_highest_count_value = i
			elif player_previous_highest_value < i:
				player_previous_highest = count
				player_previous_highest_value = i
	for i in values.size():
		var count = cpu_score.count(i)
		if count > cpu_highest_count:
			cpu_previous_highest = cpu_highest_count
			cpu_previous_highest_value = cpu_highest_count_value
			cpu_highest_count = count
			cpu_highest_count_value = i
		elif count == cpu_highest_count:
			if cpu_highest_count_value < i:
				cpu_previous_highest = cpu_highest_count
				cpu_previous_highest_value = cpu_highest_count_value
				cpu_highest_count = count
				cpu_highest_count_value = i
			elif cpu_previous_highest_value < i:
				cpu_previous_highest = count
				cpu_previous_highest_value = i
	print(str(player_highest_count) + " and " + str(player_previous_highest) + " vs " + str(cpu_highest_count) + " and " + str(cpu_previous_highest))
	print(str(player_highest_count_value) + " and " + str(player_previous_highest_value) + " vs " + str(cpu_highest_count_value) + " and " + str(cpu_previous_highest_value))
	if player_highest_count > cpu_highest_count:
		$Table/Result.visible = true
		$Table/Result.text = "YOU WIN!!"
	elif player_highest_count == cpu_highest_count && player_previous_highest > 1 && player_previous_highest > cpu_previous_highest:
		$Table/Result.visible = true
		$Table/Result.text = "YOU WIN!!"
	elif player_highest_count == cpu_highest_count && player_previous_highest == cpu_previous_highest && player_highest_count_value > cpu_highest_count_value:
		$Table/Result.visible = true
		$Table/Result.text = "YOU WIN!!"
	elif player_highest_count == cpu_highest_count && player_previous_highest == cpu_previous_highest && player_previous_highest_value > cpu_previous_highest:
		$Table/Result.visible = true
		$Table/Result.text = "YOU WIN!!"
	elif player_highest_count == cpu_highest_count && player_previous_highest == cpu_previous_highest:
		$Table/Result.visible = true
		$Table/Result.text = "DRAW!"
	else:
		$Table/Result.visible = true
		$Table/Result.text = "Too bad."
