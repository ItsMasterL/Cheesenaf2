extends Node2D

var kills = [0, 0, 0, 0]

var deaths = [0, 0, 0, 0]


func _ready():
	$Home/Music.play()

func _update_scores(this: int, attacker: int):
	deaths[this] += 1
	kills[attacker] += 1
	$Home/P1.text = "P1: Adam\nKills: %s Deaths: %s" % [kills[0], deaths[0]]
	$Home/P2.text = "P2: Bonnie\nKills: %s Deaths: %s" % [kills[1], deaths[1]]
	$Home/P3.text = "Kills: %s Deaths: %s\nP3: Chica" % [kills[2], deaths[2]]
	$Home/P4.text = "Kills: %s Deaths: %s\nP4: Freddy" % [kills[3], deaths[3]]
