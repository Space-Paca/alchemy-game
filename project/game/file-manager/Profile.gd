extends Node

var tutorials = {
	"first_battle": false,
	"recipe_book": false,
	"map": false,
}


func get_save_data():
	var data = {
		"version": Debug.VERSION,
		"tutorials": tutorials,
	}
	
	return data


func set_save_data(data):
	if data.version != Debug.VERSION:
		#Handle version diff here. For now, just print a warning.
		push_warning("WARNING! Different save version for profile. It's version: " + str(data.version) + " Current version: " + str(Debug.VERSION)) 
	tutorials = data.tutorials


func get_tutorial(name):
	assert(tutorials.has(name), "Not a valid tutorial: " + str(name))
	return tutorials[name]

func set_tutorial(name: String, value: bool):
	assert(tutorials.has(name), "Not a valid tutorial: " + str(name))
	tutorials[name] = value


func reset_tutorials():
	for keys in tutorials.keys():
		tutorials[keys] = false
