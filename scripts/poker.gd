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
	JUNK = 0,
	ONE_PAIR = 2,
	TWO_PAIR = 3,
	THREE_OF_A_KIND = 4,
	FULL_HOUSE = 6,
	FOUR_OF_A_KIND = 8,
	FIVE_OF_A_KIND = 16,
}

const HandRankingString = {
	HandRanking.JUNK: "Junk",
	HandRanking.ONE_PAIR: "One Pair",
	HandRanking.TWO_PAIR: "Two Pairs",
	HandRanking.THREE_OF_A_KIND: "Three of a Kind",
	HandRanking.FULL_HOUSE: "Full House",
	HandRanking.FOUR_OF_A_KIND: "Four of a Kind",
	HandRanking.FIVE_OF_A_KIND: "Five of a Kind"
}


@export var card_scene: PackedScene

var player_score: Array
var player_values: Array
var cpu_score: Array
var cpu_values: Array
var player_card_coords: Array
var cpu_card_coords: Array
var phase = 0
var player_cheese_count = 10
var player_bet = 1
var winstreak = 0

@onready var player_cards = $PlayerCards
@onready var cpu_cards = $CPUCards
@onready var betting_icon = $Table/CheeseBet
@onready var cheese_count_icon = $Table/CheeseCount/Label


# Called when the node enters the scene tree for the first time.
func _ready():
	$Music.play()
	_load()
	cheese_count_icon.text = "x %s" % [player_cheese_count - player_bet]
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
					$CardSounds.stream = load("res://sounds/minigame/card-deal-0%s.wav" % randi_range(1,7))
					$CardSounds.play()
			await get_tree().create_timer(1).timeout
			for card in player_cards.get_children():
				if card.selected_for_reshuffle:
					card.card_value = randi_range(0, CardValue.size() - 1)
					card._flip_card(true)
					card.anim.play("draw")
					$CardSounds.stream = load("res://sounds/minigame/card-deal-0%s.wav" % randi_range(1,7))
					$CardSounds.play()
			await get_tree().create_timer(1).timeout
			await _evaluate()
			await get_tree().create_timer(2).timeout
			for card in player_cards.get_children():
				card.queue_free()
			for card in cpu_cards.get_children():
				card.queue_free()
			phase = 0
			player_bet = 1
			cheese_count_icon.text = "x %s" % [clamp(player_cheese_count - player_bet,0,INF)]
			# Removes all but the first child
			var i = 0
			for child in betting_icon.get_children():
				if i > 0:
					child.queue_free()
				i += 1
			if player_cheese_count > 0:
				$Table/Result.visible = false
				$Table/Type.visible = false
				_start_phase(0)
			else:
				$Table/Result.text = "Game Over!"
				$Table/Type.text = "[shake]You ran out of cheese."
				DirAccess.remove_absolute("user://poker.json")

func _deal_cards(side: Node2D, selectable = false):
	for i in range(5):
		var card = card_scene.instantiate()
		side.add_child(card)
		card.selectable = selectable
		card.card_value = randi_range(0, CardValue.size() - 1)
		card.position = Vector2(200 * i, card.position.y)
		card.anim.play("draw")
		$CardSounds.stream = load("res://sounds/minigame/card-deal-0%s.wav" % randi_range(1,7))
		$CardSounds.play()
		await get_tree().create_timer(0.25).timeout

func _flip_cards(side: Node2D, faceup: bool):
	for child in side.get_children():
		child.face_up = faceup
	$CardSounds.stream = load("res://sounds/minigame/card-flip.wav")
	$CardSounds.play()

func _increase_bet():
	if player_cheese_count - player_bet > 0:
		player_bet = clamp(player_bet + 1, 1, 5)
		cheese_count_icon.text = "x %s" % [player_cheese_count - player_bet]
		if player_bet > betting_icon.get_child_count():
			var bet = betting_icon.get_child(betting_icon.get_child_count() - 1).duplicate()
			bet.position.x += 20
			betting_icon.add_child(bet)
		
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
		card.move_self(player_card_coords[i])
		i += 1
	i = 0
	for card in cpu_score:
		card.move_self(cpu_card_coords[i])
		i += 1
	$CardSounds.stream = load("res://sounds/minigame/card-slide.wav")
	$CardSounds.play()
	await get_tree().create_timer(0.75).timeout
	_flip_cards(cpu_cards, true)
	await get_tree().create_timer(1.5).timeout
	var player_hand = _rank(player_score)
	var cpu_hand = _rank(cpu_score)
	$Table/Result.visible = true
	if player_hand > cpu_hand or (player_hand == cpu_hand and _tie_break(player_hand) == 1):
		$Table/Result.text = "YOU WIN!!"
		$Table/Type.visible = true
		$Table/Type.text = "[rainbow freq=0.1 speed=5][wave amp=50]%s! +%s cheese" % [HandRankingString[player_hand], str(player_bet * player_hand)]
		if player_hand == HandRanking.FIVE_OF_A_KIND:
			$CardSounds.stream = load("res://sounds/minigame/ooh.wav")
		else:
			$CardSounds.stream = load("res://sounds/yay.wav")
		player_cheese_count += player_bet * player_hand
		winstreak += 1
		_save()
	elif cpu_hand > player_hand or (player_hand == cpu_hand and _tie_break(player_hand) == 2):
		$Table/Result.text = "Too bad."
		$Table/Type.visible = true
		$Table/Type.text = "[shake]-%s cheese" % [str(player_bet * cpu_hand)]
		$CardSounds.stream = load("res://sounds/minigame/aww.wav")
		player_cheese_count = clamp(player_cheese_count - player_bet * cpu_hand, 0, INF)
		winstreak = 0
		# Remove this early to prevent cheating/bugs
		if player_cheese_count == 0 and FileAccess.file_exists("user://poker.json"):
			DirAccess.remove_absolute("user://poker.json")
	else:
		$Table/Result.text = "DRAW!"
		$CardSounds.stream = load("res://sounds/boop.wav")
	$CardSounds.play()

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
		_:
			if player_score[0].card_value > cpu_score[0].card_value:
				return 1
			if player_score[0].card_value < cpu_score[0].card_value:
				return 2
			return 0

func _save():
	print("Saving Poker user data")
	var data = {
		"cheese" = player_cheese_count,
		"winstreak" = winstreak
	}
	var file = FileAccess.open("user://poker.json",FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	file.store_line(json_string)

func _load():
	print("Loading Poker user data")
	if FileAccess.file_exists("user://poker.json"):
		var file = FileAccess.open("user://poker.json",FileAccess.READ)
		var json_string = file.get_as_text()

		# Creates the helper class to interact with JSON.
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if parse_result != OK:
			print("JSON Parse Error: ", json.get_error_message())
			return

		# Get the data from the JSON object.
		var data = json.data
		if "cheese" in data and typeof(data["cheese"]) in [TYPE_INT, TYPE_FLOAT]:
			player_cheese_count = floor(data["cheese"]) as int
		if "winstreak" in data and typeof(data["winstreak"]) in [TYPE_INT, TYPE_FLOAT]:
			winstreak = floor(data["winstreak"]) as int
