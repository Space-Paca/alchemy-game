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
	reagent.type = type
	reagent.image_path = reagent_data.image
	return reagent


func get_data(type: String):
	return ReagentDB.get_from_name(type)
