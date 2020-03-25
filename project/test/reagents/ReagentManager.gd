extends Node

const REAGENT = preload("res://test/reagents/Reagent.tscn")

onready var DB = get_node("/root/DbManager")

const TYPES = ["regular", "special", "harmless", "funky", "powerful", "tasty", \
			   "marvellous"]

func random_type():
	randomize()
	TYPES.shuffle()
	return TYPES[1]

func create(type):
	
	if not TYPES.has(type):
		push_error("Given type of reagent doesn't exist")
		assert(false)
	
	var data = DB.get_data("reagents")
	
	var reagent = REAGENT.instance()
	reagent.type = type
	reagent.set_image(data[type].image)
	return reagent

func create_data(type):
	
	if not TYPES.has(type):
		push_error("Given type of reagent doesn't exist")
		assert(false)
	
	return DB.get_data("reagents")
