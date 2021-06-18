extends Node

const WINDOW_SIZES = [Vector2(1280, 720), Vector2(1366, 768),
		Vector2(1600, 900), Vector2(1920, 1080)]

const LANGUAGES = [
	{"locale":"en", "name": "English"},
	{"locale":"pt_BR", "name": "Português"},
]

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
	"window_size": 3,
	"auto_end_turn": false,
	"show_timer": false,
	"locale": 1,
}

var controls = {
	"show_recipe_book": KEY_TAB,
	"combine": KEY_SPACE,
	"end_turn": KEY_E,
	"toggle_fullscreen": KEY_F4 
}

var progression = {
	"recipes": {
		"name": "Recipes",
		"cur_xp": 9,
		"level_progression": [4, 6, 8, 10],
	},
	"artifacts": {
		"name": "Artifacts",
		"cur_xp": 201,
		"level_progression": [10, 20, 40, 60, 80, 100, 120, 200],
	},
	"misc": {
		"name": "The World",
		"cur_xp": 118,
		"level_progression": [10, 20, 40, 60, 80, 100, 120, 2000],
	}
}

var known_recipes = {}

func _ready():
	if known_recipes.empty():
		reset_known_recipes()
	update_translation()


func update_translation():
	TranslationServer.set_locale(LANGUAGES[Profile.get_option("locale")].locale)


func reset_progression():
	for category in progression:
		progression[category].cur_xp = 0


func reset_known_recipes():
	known_recipes.clear()
	for recipe in RecipeManager.recipes.values():
		known_recipes[recipe.name] = {
			"memorized_threshold": memorized_threshold(recipe.name),
			"amount": -1,
			"memorized": false,
		}


func get_save_data():
	var data = {
		"version": Debug.VERSION,
		"tutorials": tutorials,
		"options": options,
		"controls": controls,
		"known_recipes": known_recipes,
		"progression": progression,
	}
	
	return data


func set_save_data(data):
	if data.version != Debug.VERSION:
		#Handle version diff here. For now, just print a warning.
		push_warning("WARNING! Different save version for profile. Its version: " + str(data.version) + " Current version: " + str(Debug.VERSION)) 
	
	set_data(data, "tutorials", tutorials)
	set_data(data, "options", options)
	set_data(data, "controls", controls)
	set_data(data, "known_recipes", known_recipes)
	set_data(data, "progression", progression)
	
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
	
	#Update received data with missing default values, only checking for 1 depth
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


func reset_compendium():
	reset_known_recipes()
	FileManager.save_profile()


func memorized_threshold(recipe_name: String) -> int:
	var recipe = RecipeManager.recipes[recipe_name]
	var threshold = min(10, 18 - recipe.reagents.size() - 3*recipe.destroy_reagents.size() - 2*recipe.grid_size)
	threshold = 3*max(threshold, 2)
	return threshold


func is_recipe_memorized(name):
	assert(known_recipes.has(name), "Not a valid recipe name: "+str(name))
	return known_recipes[name].memorized


func memorize_recipe(name):
	assert(known_recipes.has(name), "Not a valid recipe name: "+str(name))
	known_recipes[name].memorized = true
	known_recipes[name].amount = known_recipes[name].memorized_threshold


func get_progression(type):
	assert(progression.has(type), "Not a valid progression type: "+str(type))
	return progression[type]


func get_progression_xp(type):
	assert(progression.has(type), "Not a valid progression type: "+str(type))
	return progression[type].cur_xp


func increase_progression(type, amount):
	assert(progression.has(type), "Not a valid progression type: "+str(type))
	progression[type].cur_xp += amount


func set_progression_xp(type, value):
	assert(progression.has(type), "Not a valid progression type: "+str(type))
	progression[type].cur_xp = value
