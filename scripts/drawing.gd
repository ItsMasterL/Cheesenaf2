extends Node2D

@onready var lines: Node2D = $Lines

var current_line: Line2D
var line_color = Color.BLACK
var line_width = 4
var pressed = false

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		pressed = event.is_action_pressed(&"Interact")

		if pressed:
			current_line = Line2D.new()
			current_line.default_color = line_color
			current_line.width = line_width
			current_line.antialiased = true
			lines.add_child(current_line)
			current_line.add_point(event.position)
	
	elif event is InputEventMouseMotion and pressed:
		current_line.add_point(event.position)
