extends Node

const REAGENT = preload("res://game/reagents/Reagent.tscn")


func random_type():
	var types = ReagentDB.get_types()
	randomize()
	types.shuffle()
	return types[1]


func create_object(type: String):
	var reagent_data = ReagentDB.get_from_name(type)
	var reagent = REAGENT.instance()
	
	#Duplicate material so shader parameters only affect this object
	var mat_override = reagent.get_node("Image").get_material().duplicate()
	reagent.get_node("Image").set_material(mat_override)
	
	reagent.type = type
	reagent.set_image(reagent_data.image)
	return reagent

func get_data(type: String):
	return ReagentDB.get_from_name(type)

func randomize_reagent(reagent):
	var type = random_type()
	var reagent_data = ReagentDB.get_from_name(type)
	reagent.type = type
	reagent.set_image(reagent_data.image)

func get_tooltip(type: String, upgraded:= false, unstable:= false, burned:= false):
	var data = get_data(type)
	var text
	
	if not upgraded:
		text = data.tooltip % data.effect.value
	else:
		text = data.tooltip % data.effect.upgraded_value + " Boost " + \
			   data.effect.upgraded_boost.type + " recipes by " + str(data.effect.upgraded_boost.value) + "."
	if unstable:
		text += " It's unstable."
	if burned:
		text += " It's on fire."
	var tooltip = {"title": data.name, "text": text, \
				   "title_image": data.image.get_path()}
	
	return tooltip
