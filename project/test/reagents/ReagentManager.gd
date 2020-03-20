extends Node

const REAGENT = preload("res://test/reagents/Reagent.tscn")
const DB_PATH = "res://database/ReagentsDB.json"
var Data

func ready():
	if not Data:
		get_data()

func get_data():
	var data_file = File.new()
	if data_file.open(DB_PATH, File.READ) != OK:
		push_error("Couldn't open reagents database file")
		assert(false)
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		push_error("Couldn't parse reagents database file")
		assert(false)
	Data = data_parse.result

func create(type):
	if not Data:
		get_data()
		
	var reagent = REAGENT.instance()
	reagent.type = type
	reagent.set_image(Data[type].image)
	return reagent
