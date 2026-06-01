extends Node2D

var kills = [0, 0, 0, 0]

var deaths = [0, 0, 0, 0]

@onready var root = $"../.."

func _ready():
	$Home/Music.play()
	$Home/Instruction.text = tr("TANK_TROUBLE_INSTRUCTION").format({"up_key": InputMap.action_get_events("TankForward")[0].as_text().trim_suffix(" (Physical)").to_upper(), "left_key": InputMap.action_get_events("TankLeft")[0].as_text().trim_suffix(" (Physical)").to_upper(), "down_key": InputMap.action_get_events("TankBackward")[0].as_text().trim_suffix(" (Physical)").to_upper(), "right_key": InputMap.action_get_events("TankRight")[0].as_text().trim_suffix(" (Physical)").to_upper(), "shoot_key": InputMap.action_get_events("TankFire")[0].as_text().trim_suffix(" (Physical)").to_upper()})
	if root.is_p1:
		$Home/P1.text = "P1: Adam\nKills: %s Deaths: %s" % [kills[0], deaths[0]]
	else:
		$Home/P1.text = "P1: Psy\nKills: %s Deaths: %s" % [kills[0], deaths[0]]

func _update_scores(this: int, attacker: int):
	deaths[this] += 1
	kills[attacker] += 1
	if root.is_p1:
		$Home/P1.text = "P1: Adam\nKills: %s Deaths: %s" % [kills[0], deaths[0]]
	else:
		$Home/P1.text = "P1: Psy\nKills: %s Deaths: %s" % [kills[0], deaths[0]]
	$Home/P2.text = "P2: Bonnie\nKills: %s Deaths: %s" % [kills[1], deaths[1]]
	$Home/P3.text = "Kills: %s Deaths: %s\nP3: Chica" % [kills[2], deaths[2]]
	$Home/P4.text = "Kills: %s Deaths: %s\nP4: Freddy" % [kills[3], deaths[3]]
	root.sabotage_clear_check.emit(kills[0], Globals.SabotageClearRequirements.SCORE_TANK_TROUBLE)
