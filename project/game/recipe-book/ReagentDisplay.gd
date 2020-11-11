extends TextureRect

onready var reagent = $MarginContainer/ReagentTexture

const HAND_TEXTURE = preload("res://assets/images/ui/book/recipebook_slot_hand.png")
const GRID_TEXTURE = preload("res://assets/images/ui/book/recipebook_grid_slot.png")

export(Texture) var unknown_texture

var reagent_name


func set_mode(mode : String):
	if mode == "hand":
		texture = HAND_TEXTURE
	elif mode == "grid":
		texture = GRID_TEXTURE
	elif mode == "blank":
		texture = null
	else:
		assert(false, "Not a valid mode for reagent display:" + str(mode))


func set_reagent(_reagent_name):
	reagent_name = _reagent_name
	if reagent_name == "unknown":
		reagent.texture = unknown_texture
	elif reagent_name:
		reagent.texture = ReagentDB.get_from_name(reagent_name).image
	else:
		reagent.texture = null
