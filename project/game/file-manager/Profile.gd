extends Node

const WINDOW_SIZES = [Vector2(1280, 720), Vector2(1366, 768),
		Vector2(1600, 900), Vector2(1920, 1080)]

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
	"fullscreen": true,
	"borderless": false,
	"window_size": 3
}

var controls = {
	"show_recipe_book": KEY_TAB,
	"combine": KEY_SPACE,
	"end_turn": KEY_E,
	"toggle_fullscreen": KEY_F4 
}

func get_save_data():
	var data = {
		"version": Debug.VERSION,
		"tutorials": tutorials,
		"options": options,
		"controls": controls
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
	OS.window_fullscreen = options.fullscreen
	OS.window_borderless = options.borderless
	OS.window_size = WINDOW_SIZES[options.window_size]
	
	for action in controls.keys():
		edit_control_action(action, controls[action])


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


func set_option(name: String, value):
	assert(options.has(name), "Not a valid option: " + str(name))
	options[name] = value


func get_control(name):
	assert(controls.has(name), "Not a valid control action: " + str(name))
	return controls[name]


func set_control(name: String, value):
	assert(controls.has(name), "Not a valid control action: " + str(name))
	controls[name] = value
	edit_control_action(name, value)


func edit_control_action(action: String, scancode:int):
	assert(InputMap.has_action(action), "Action not in InputMap: " + str(action))
	var key = InputEventKey.new()
	key.pressed = true
	key.scancode = scancode
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, key)


func reset_tutorials():
	for keys in tutorials.keys():
		tutorials[keys] = false
	FileManager.save_profile()
