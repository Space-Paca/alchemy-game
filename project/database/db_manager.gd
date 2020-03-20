extends Node

const PATHS = {"reagents": "res://database/ReagentsDB.json"}

var Datas = {}

func get_data(type):
	#Tries to find a local resource of data
	if Datas.has(type):
		return Datas[type]
	
	#If it doesn't have a local data of resource available, open the DB and creates one
	if not PATHS.has(type):
		push_error("Invalid type of database to access: " + str(type))
		assert(false)
	var data_file = File.new()
	if data_file.open(PATHS[type], File.READ) != OK:
		push_error("Couldn't open database file for type " + str(type))
		assert(false)
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		push_error("Couldn't parse database file for type " + str(type))
		assert(false)
	Datas[type] = data_parse.result
	return data_parse.result
