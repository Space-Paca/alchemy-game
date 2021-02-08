extends Node

#Default tutorial flags
var tutorials = {
	"first_battle": false,
	"recipe_book": false,
	"clicked_recipe": false,
	"map": false,
}

var options = {
	"bgm_volume": 1.0,
	"sfx_volume": 1.0,
}

func get_save_data():
	var data = {
		"version": Debug.VERSION,
		"tutorials": tutorials,
		"options": options,
	}
	
	return data


func set_save_data(data):
	if data.version != Debug.VERSION:
		#Handle version diff here. For now, just print a warning.
		push_warning("WARNING! Different save version for profile. It's version: " + str(data.version) + " Current version: " + str(Debug.VERSION)) 
	
	set_data(data, "tutorials", tutorials)
	set_data(data, "options", options)
	AudioManager.set_bus_volume("bgm", options.bgm_volume)
	AudioManager.set_bus_volume("sfx", options.sfx_volume)


func set_data(data, name, default_values):
	if not data.has(name):
		return
	
	#Update received data with missing default values
	for key in default_values.keys():
		if not data[name].has(key):
			data[name][key] = default_values[key]
			
	for key in data[name].keys():
		default_values[key] = data[name][key]


func get_tutorial(name):
	assert(tutorials.has(name), "Not a valid tutorial: " + str(name))
	return tutorials[name]


func set_tutorial(name: String, value: bool):
	assert(tutorials.has(name), "Not a valid tutorial: " + str(name))
	tutorials[name] = value
	FileManager.save_profile()


func get_option(name):
	assert(options.has(name), "Not a valid option: " + str(name))
	return options[name]


func set_option(name: String, value: float):
	assert(options.has(name), "Not a valid option: " + str(name))
	options[name] = value


func reset_tutorials():
	for keys in tutorials.keys():
		tutorials[keys] = false
