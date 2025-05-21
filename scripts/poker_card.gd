extends Sprite2D


enum sprite_id {
	FOXY,
	CHICA,
	BONNIE,
	FREDDY,
	CHEESESTICK,
	AFTON,
	CARD_BACK,
	CARD_BACK_FLIP,
	SIDEWAYS,
}

const CARD_RECTS = [
	Rect2(144, 0, 32, 48), # 0 - Foxy
	Rect2(96, 0, 32, 48), # 1 - Chica
	Rect2(48, 0, 32, 48), # 2 - Bonnie
	Rect2(0, 0, 32, 48), # 3 - Freddy
	Rect2(0, 48, 32, 48), # 4 - Cheesestick
	Rect2(48, 48, 32, 48), # 5 - Afton
	Rect2(96, 48, 32, 48), # 6 - Card Back
	Rect2(128, 48, 16, 48), # 7 - Card Back Flipping (It's really cool like that)
	Rect2(144, 48, 4, 48), # 8 - Card Sideways
]

@export_enum("Foxy", "Chica", "Bonnie", "Freddy", "Cheesestick", "Afton") var card_value:
	set(new_value):
		card_value = new_value
		if Engine.is_editor_hint():
			if face_up:
				self.region_rect = CARD_RECTS[card_value]
@export var face_up = false:
	set(flip):
		face_up = flip
		_flip_card(face_up)

var selected_for_reshuffle: bool
var selectable = false
var hovered = false
var sorting = false

@onready var anim = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	$Button.pressed.connect(_select)

func _select():
	if selectable:
		selected_for_reshuffle = !selected_for_reshuffle
		if selected_for_reshuffle:
			anim.play("selected")
		else:
			anim.play_backwards("selected")

func _flip_card(faceup: bool):
	if faceup == false:
		self.region_rect = CARD_RECTS[card_value]
		await get_tree().create_timer(0.1).timeout
		self.region_rect = Rect2(CARD_RECTS[card_value].position.x + 32, CARD_RECTS[card_value].position.y, CARD_RECTS[card_value].size.x / 2, CARD_RECTS[card_value].size.y)
		await get_tree().create_timer(0.1).timeout
		self.region_rect = CARD_RECTS[sprite_id.SIDEWAYS]
		await get_tree().create_timer(0.1).timeout
		self.region_rect = CARD_RECTS[sprite_id.CARD_BACK_FLIP]
		await get_tree().create_timer(0.1).timeout
		self.region_rect = CARD_RECTS[sprite_id.CARD_BACK]
	else:
		self.region_rect = CARD_RECTS[sprite_id.CARD_BACK]
		await get_tree().create_timer(0.1).timeout
		self.region_rect = CARD_RECTS[sprite_id.CARD_BACK_FLIP]
		await get_tree().create_timer(0.1).timeout
		self.region_rect = CARD_RECTS[sprite_id.SIDEWAYS]
		await get_tree().create_timer(0.1).timeout
		self.region_rect = Rect2(CARD_RECTS[card_value].position.x + 32, CARD_RECTS[card_value].position.y, CARD_RECTS[card_value].size.x / 2, CARD_RECTS[card_value].size.y)
		await get_tree().create_timer(0.1).timeout
		self.region_rect = CARD_RECTS[card_value]
