extends Slot

onready var reagent_hint = $MarginContainer/ReagentHint


func set_hint(reagent_name):
	if reagent_name:
		reagent_hint.texture = load(ReagentDB.get_from_name(reagent_name).image)
	else:
		reagent_hint.texture = null
