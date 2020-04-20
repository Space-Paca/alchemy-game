extends TextureRect

onready var reagent = $MarginContainer/ReagentTexture


func set_reagent(reagent_name):
	if reagent_name:
		reagent.texture = load(ReagentDB.get_from_name(reagent_name).image)
