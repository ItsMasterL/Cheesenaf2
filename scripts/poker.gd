extends Node2D


enum CardValue {
	FOXY,
	CHICA,
	BONNIE,
	FREDDY,
	CHEESESTICK,
	AFTON,
}

enum HandRanking {
	JUNK,
	ONE_PAIR,
	TWO_PAIR,
	THREE_OF_A_KIND,
	FULL_HOUSE,
	FOUR_OF_A_KIND,
	FIVE_OF_A_KIND,
}

@export var card_scene: PackedScene

var player_score: Array
var player_values: Array
var cpu_score: Array
var cpu_values: Array
var player_card_coords: Array
var cpu_card_coords: Array
var phase = 0

@onready var player_cards = $PlayerCards
@onready var cpu_cards = $CPUCards


# Called when the node enters the scene tree for the first time.
func _ready():
	$Music.play()
	_start_phase(0)

func _process(_delta):
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
					card.card_value = randi_range(0, CardValue.size() - 1)
					card._flip_card(true)
					card.anim.play("draw")
			await get_tree().create_timer(1).timeout
			await _evaluate()
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
		card.card_value = randi_range(0, CardValue.size() - 1)
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
	player_values.clear()
	cpu_values.clear()
	player_card_coords.clear()
	cpu_card_coords.clear()
	for card in player_cards.get_children():
		player_score.append(card)
		player_values.append(card.card_value)
		player_card_coords.append(card.position)
	for card in cpu_cards.get_children():
		cpu_score.append(card)
		cpu_values.append(card.card_value)
		cpu_card_coords.append(card.position)
	player_score.sort_custom(_card_compare_player)
	cpu_score.sort_custom(_card_compare_cpu)
	var i = 0
	for card in player_score:
		card.position = player_card_coords[i]
		i += 1
	i = 0
	for card in cpu_score:
		card.position = cpu_card_coords[i]
		i += 1
	await get_tree().create_timer(1).timeout
	_flip_cards(cpu_cards, true)
	await get_tree().create_timer(1).timeout
	var player_hand = _rank(player_score)
	var cpu_hand = _rank(cpu_score)
	$Table/Result.visible = true
	if player_hand > cpu_hand || (player_hand == cpu_hand && _tie_break(player_hand) == 1):
		$Table/Result.text = "YOU WIN!!"
	elif cpu_hand > player_hand || (player_hand == cpu_hand && _tie_break(player_hand) == 2):
		$Table/Result.text = "Too bad."
	else:
		$Table/Result.text = "DRAW!"

func _card_compare_player(a, b):
	if player_values.count(a.card_value) > player_values.count(b.card_value):
		return true
	elif player_values.count(a.card_value) < player_values.count(b.card_value):
		return false
	else:
		return a.card_value > b.card_value

func _card_compare_cpu(a, b):
	if cpu_values.count(a.card_value) > cpu_values.count(b.card_value):
		return true
	elif cpu_values.count(a.card_value) < cpu_values.count(b.card_value):
		return false
	else:
		return a.card_value > b.card_value

func _rank(cards):
	if cards[0].card_value == cards[1].card_value:
		if cards[1].card_value == cards[2].card_value:
			if cards[3].card_value == cards[2].card_value:
				if cards[4].card_value == cards[3].card_value:
					return HandRanking.FIVE_OF_A_KIND
				return HandRanking.FOUR_OF_A_KIND
			if cards[3].card_value == cards[4].card_value:
				return HandRanking.FULL_HOUSE
			return HandRanking.THREE_OF_A_KIND
		if cards[2].card_value == cards[3].card_value:
			return HandRanking.TWO_PAIR
		return HandRanking.ONE_PAIR
	return HandRanking.JUNK

func _tie_break(ranking: HandRanking):
	match ranking:
		_:
			if player_score[0].card_value > cpu_score[0].card_value:
				return 1
			if player_score[0].card_value < cpu_score[0].card_value:
				return 2
			return 0
		HandRanking.TWO_PAIR:
			if player_score[0].card_value > cpu_score[0].card_value:
				return 1
			if player_score[2].card_value > cpu_score[2].card_value:
				return 1
			if player_score[0].card_value < cpu_score[0].card_value:
				return 2
			if player_score[2].card_value < cpu_score[2].card_value:
				return 2
			return 0
		HandRanking.FULL_HOUSE:
			if player_score[0].card_value > cpu_score[0].card_value:
				return 1
			if player_score[3].card_value > cpu_score[3].card_value:
				return 1
			if player_score[0].card_value < cpu_score[0].card_value:
				return 2
			if player_score[3].card_value < cpu_score[3].card_value:
				return 2
			return 0
