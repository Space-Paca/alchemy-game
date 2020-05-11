extends TextureRect

onready var reagent = $MarginContainer/ReagentTexture

export(Texture) var unknown_texture

var reagent_name


func set_reagent(_reagent_name):
	reagent_name = _reagent_name
	if reagent_name == "unknown":
		reagent.texture = unknown_texture
	elif reagent_name:
		reagent.texture = ReagentDB.get_from_name(reagent_name).image
	else:
		reagent.texture = null
