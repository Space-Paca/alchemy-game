extends Node

const WINDOW_SIZES = [Vector2(1920, 1080), Vector2(1600, 900),
		Vector2(1366, 768), Vector2(1280, 720)]

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
	"first_shop": false,
	"first_smith": false,
}

var options = {
	"master_volume": 1.0,
	"bgm_volume": 1.0,
	"sfx_volume": 1.0,
	"fullscreen": true,
	"borderless": false,
	"window_size": 0,
	"auto_end_turn": false,
	"show_timer": false,
	"screen_shake": true,
	"locale": 0,
	"choose_language": false,
	"disable_map_fog": false,
}

var controls = {
	"show_recipe_book": KEY_TAB,
	"combine": KEY_SPACE,
	"end_turn": KEY_E,
	"toggle_fullscreen": KEY_F4 
}

var progression = {
	"recipes": {
		"name": "RECIPES",
		"cur_xp": 0,
	},
	"artifacts": {
		"name": "ARTIFACTS",
		"cur_xp": 0,
	},
	"misc": {
		"name": "THE_WORLD",
		"cur_xp": 0,
	}
}

var known_recipes = {}

func _ready():
	if known_recipes.empty():
		reset_known_recipes()
	update_translation()


func get_locale_idx(locale):
	var idx = 0
	for lang in Profile.LANGUAGES:
		if lang.locale == locale:
			return idx
		idx += 1
	push_error("Couldn't find given locale: " + str(locale))


func update_translation():
	TranslationServer.set_locale(LANGUAGES[Profile.get_option("locale")].locale)


func reset_progression():
	for category in progression:
		progression[category].cur_xp = 0


func reset_known_recipes():
	known_recipes.clear()
	for recipe_id in RecipeManager.recipes.keys():
		known_recipes[recipe_id] = {
			"memorized_threshold": memorized_threshold(recipe_id),
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
		push_warning("Different save version for profile. Its version: " + str(data.version) + " Current version: " + str(Debug.VERSION)) 
		push_warning("Properly updating to new save version") #Lol ||ヽ(*￣▽￣*)ノミ
		
	set_data(data, "tutorials", tutorials)
	set_data(data, "options", options)
	set_data(data, "controls", controls)
	set_data(data, "known_recipes", known_recipes)
	set_data(data, "progression", progression)
	
	AudioManager.set_bus_volume(AudioManager.MASTER_BUS, options.master_volume)
	AudioManager.set_bus_volume(AudioManager.BGM_BUS, options.bgm_volume)
	AudioManager.set_bus_volume(AudioManager.SFX_BUS, options.sfx_volume)
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


func memorized_threshold(recipe_id: String) -> int:
	var recipe = RecipeManager.recipes[recipe_id]
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


func is_max_level(prog_type):
	var prog = UnlockManager.get_progression(prog_type)
	return get_progression_level(prog_type) == prog.size()


func get_progression(type):
	assert(progression.has(type), "Not a valid progression type: "+str(type))
	return progression[type]


func get_progression_level(type):
	var prog = get_progression(type)
	return UnlockManager.get_progression_level(type, prog.cur_xp)


func get_progression_xp(type):
	assert(progression.has(type), "Not a valid progression type: "+str(type))
	return progression[type].cur_xp


func increase_progression(type, amount):
	assert(progression.has(type), "Not a valid progression type: "+str(type))
	progression[type].cur_xp += amount


func set_progression_xp(type, value):
	assert(progression.has(type), "Not a valid progression type: "+str(type))
	progression[type].cur_xp = value
