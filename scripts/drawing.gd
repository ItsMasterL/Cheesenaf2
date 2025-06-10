extends Node2D

@onready var lines = $Lines
@onready var ui_bar = $Home/UIBar/AnimationPlayer
@onready var menu_button = $Home/UIBar/MenuButton

var current_line: Line2D
var line_color = Color.BLACK
var line_width = 4
var pressed = false
var menu_open = false

func _ready() -> void:
	$Music.play()

func _input(event: InputEvent):
	if menu_open:
		return
	
	if event is InputEventMouseButton:
		pressed = event.is_action_pressed(&"Interact")

		if pressed and event.position.y > 100:
			current_line = Line2D.new()
			current_line.default_color = line_color
			current_line.width = line_width
			current_line.antialiased = true
			lines.add_child(current_line)
			current_line.add_point(event.position)
	
	elif event is InputEventMouseMotion and pressed and event.position.y > 100:
		current_line.add_point(event.position)

func _set_color(color: Color):
	line_color = color

func _toggle_menu():
	menu_open = !menu_open
	if menu_open:
		ui_bar.play("OpenMenu")
		menu_button.text = "Close\nMenu"
	else:
		ui_bar.play_backwards("OpenMenu")
		menu_button.text = "Open\nMenu"

func _toggle_music():
	$Music.playing = !$Music.playing

func _undo():
	if lines.get_child_count() > 0:
		lines.get_child(-1).queue_free()
		current_line = lines.get_child(-1)
