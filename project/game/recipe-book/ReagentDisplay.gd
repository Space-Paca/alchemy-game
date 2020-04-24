extends TextureRect

onready var reagent = $MarginContainer/ReagentTexture

var reagent_name


func set_reagent(_reagent_name):
	reagent_name = _reagent_name
	if reagent_name:
		reagent.texture = load(ReagentDB.get_from_name(reagent_name).image)
	else:
		reagent.texture = null
