extends Node

const PATHS = {"reagents": "res://database/ReagentsDB.tres"}


func get_data(type):
	
	if not PATHS.has(type):
		push_error("Invalid type of database to access: " + str(type))
		assert(false)
		
	return load(PATHS[type])
