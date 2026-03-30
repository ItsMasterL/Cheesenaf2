extends CharacterBody3D


const RAY_LENGTH = 1000.0

@export var is_p1: bool
@export var authority_items: Array[Node]

@onready var head := $Head
@onready var camera := $Head/Eyes
@onready var root = get_node(^"/root/Map")
@onready var breathing := $Head/Breathing
@onready var moving := $Head/MoveUnderDesk
var flashlight
var flashlight_sound
var anim

var sensitivity_sabotage = 1

func _ready():
	root.sabotage_begin.connect(_sabotage_event)
	root.sabotage_end.connect(_sabotage_event_end)
	if is_p1:
		flashlight = $Head/Eyes/SpotLight3D
		flashlight_sound = $Head/Eyes/SpotLight3D/FlashlightClick
		anim = $AnimationPlayer

func _unhandled_input(event):
	if root.spectating:
		return
	if root.is_p1 and is_p1:
		if root.p1_can_action:
			if event.is_action_pressed(&"Flashlight") and root.using_tablet == false:
				if root.active_sabotage != Globals.Sabotages.BALLOON_BOY:
					flashlight.visible = true
				flashlight_sound.play()
			if event.is_action_released(&"Flashlight"):
				flashlight.visible = false
				if root.using_tablet == false and root.active_sabotage != Globals.Sabotages.BALLOON_BOY:
					flashlight_sound.play()
			if event.is_action_pressed(&"HideUnderDesk") and anim.is_playing() == false and root.under_desk == false:
				_sync_animation.rpc(false)
				moving.play()
			if event.is_action_released(&"HideUnderDesk") and anim.is_playing() == false and root.under_desk:
				_sync_animation.rpc(true)
				moving.play()
		if event.is_action_pressed(&"Interact") and root.using_tablet == false:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif event.is_action_pressed(&"ui_cancel"):
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and root.using_tablet == false:
				get_tree().change_scene_to_file("res://scenes/title.tscn")
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				head.rotate_y(-event.relative.x * (0.005 * Globals.mouse_sensitivity * sensitivity_sabotage))
				camera.rotate_x(-event.relative.y * (0.005 * Globals.mouse_sensitivity * sensitivity_sabotage))
				camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	elif !root.is_p1 and !is_p1:
		if root.p2_can_action:
			pass
		if event.is_action_pressed(&"Interact") and root.using_laptop == false:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif event.is_action_pressed(&"ui_cancel"):
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and root.using_laptop == false:
				get_tree().change_scene_to_file("res://scenes/title.tscn")
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				head.rotate_y(-event.relative.x * (0.005 * Globals.mouse_sensitivity * sensitivity_sabotage))
				camera.rotate_x(-event.relative.y * (0.005 * Globals.mouse_sensitivity * sensitivity_sabotage))
				camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

@rpc("authority","call_local","unreliable")
func _sync_animation(reverse: bool):
	if reverse:
		anim.play(&"desk_hide", -1, -1, true)
	else:
		anim.play(&"desk_hide")

func _hidden(state: bool):
	root.under_desk = state

func _breathe():
	breathing.play()

func _stop_breathe():
	breathing.stop()

func _sabotage_event(event: Globals.Sabotages):
	if event == Globals.Sabotages.BALLOON_BOY:
		flashlight_sound.stream = load("res://sounds/error.wav")
		flashlight.visible = false
	if event == Globals.Sabotages.STIFF_NECK:
		sensitivity_sabotage = 0.05

func _sabotage_event_end():
	flashlight_sound.stream = load("res://sounds/flashlight.wav")
	sensitivity_sabotage = 1
