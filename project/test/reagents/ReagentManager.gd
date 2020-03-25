extends Node

const REAGENT = preload("res://test/reagents/Reagent.tscn")
const REAGENT_DB = preload("res://database/ReagentsDB.tres")

const TYPES = ["regular", "special", "harmless", "funky", "powerful", "tasty", \
			   "marvellous"]

func random_type():
	randomize()
	TYPES.shuffle()
	return TYPES[1]

func create_object(type):
	
	if not TYPES.has(type):
		push_error("Given type of reagent doesn't exist")
		assert(false)
	
	var reagent_data = REAGENT_DB.get(type)
	
	var reagent = REAGENT.instance()
	reagent.type = type
	reagent.set_image(reagent_data.image)
	return reagent

func get_data(type):
	
	if not TYPES.has(type):
		push_error("Given type of reagent doesn't exist")
		assert(false)
	
	var data = REAGENT_DB.get_data("reagents")
	
	return data.get(type)
