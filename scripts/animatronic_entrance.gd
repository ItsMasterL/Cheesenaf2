class_name EntranceProperty
extends Resource

@export_category("Office Properties")
## If there are more animatronics in the office than this number, the movement check to enter will always fail.
@export var office_animatronic_limit: int
## If true, the animatronic can jumpscare the player while they are under the desk if their movement check passes while they are in the office.
@export var search_under_desk: bool
## If true, the animatronic will be driven away from the player's flashlight.
@export var flashlight_weakness: bool
## Which entrance the animatronic will appear from. Needed for entrance blocks, which always fail the animatronic if the entrance they're in is blocked off.
@export_enum("Front Door", "Back Door", "Left Vent", "Right Vent", "Ceiling Vent") var entrance: int
## Which position as defined in the above field, "Positions", the animatronic will be sent to if their attack check fails from the player hiding under a desk or from a flashlight.
@export var fail_position_index: int
## Check to see if the entryway is blocked before moving to the space - Useful for animatronics that clip/go past the doorway
@export var check_before_entering: bool
