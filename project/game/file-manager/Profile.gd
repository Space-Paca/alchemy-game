extends Node

const WINDOW_SIZES = [Vector2(1920, 1080), Vector2(1600, 900),
		Vector2(1366, 768), Vector2(1280, 720)]
const MAX_MEMORIZATION_LEVEL = 4
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
	"master_volume": 0.7,
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


var stats = {
	"times_finished": {
		"alchemist": 0,
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
	FileManager.save_profile()


func reset_known_recipes():
	known_recipes.clear()
	for recipe_id in RecipeManager.recipes.keys():
		known_recipes[recipe_id] = {
			"amount": -1,
		}


func get_save_data():
	var data = {
		"version": Debug.VERSION,
		"tutorials": tutorials,
		"options": options,
		"controls": controls,
		"known_recipes": known_recipes,
		"progression": progression,
		"stats": stats,
	}
	
	return data


func set_save_data(data):
	if data.version != Debug.VERSION:
		#Handle version diff here.
		push_warning("Different save version for profile. Its version: " + str(data.version) + " Current version: " + str(Debug.VERSION)) 
		push_warning("Properly updating to new save version")
		if data.stats.has("times_finished_alchemist"):
			data.stats["times_finished"] = {
				"alchemist": data.stats.times_finished_alchemist
			}
		push_warning("Profile updated!")#ヽ(*￣▽￣*)ノミ
	
	if known_recipes.empty():
		reset_known_recipes()
	
	set_data(data, "tutorials", tutorials)
	set_data(data, "options", options)
	set_data(data, "controls", controls)
	set_data(data, "known_recipes", known_recipes)
	set_data(data, "progression", progression)
	set_data(data, "stats", stats)
	
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
	
	#Update received data with missing default values
	for key in default_values.keys():
		if not data[name].has(key):
			data[name][key] = default_values[key]
			push_warning("Adding new profile entry '" + str(key) + str("' for " + str(name)))
		elif typeof(default_values[key]) == TYPE_DICTIONARY:
			set_data(data[name], key, default_values[key])
			
	for key in data[name].keys():
		#Ignore deprecated values
		if default_values.has(key):
			default_values[key] = data[name][key]
		else:
			data[name].erase(key)
			push_warning("Removing deprecated value '" + str(key) + str("' for " + str(name)))


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
	FileManager.save_profile()

func get_control(name):
	assert(controls.has(name), "Not a valid control action: " + str(name))
	return controls[name]


func set_control(name: String, value):
	assert(controls.has(name), "Not a valid control action: " + str(name))
	controls[name] = value
	edit_control_action(name, value)
	FileManager.save_profile()


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


func get_memorized_thresholds(recipe_id: String) -> Array:
	var recipe = RecipeManager.recipes[recipe_id]
	var threshold_v = min(12, 18 - recipe.reagents.size() - 3*recipe.destroy_reagents.size() - recipe.grid_size*recipe.grid_size)
	threshold_v = max(threshold_v, 3)
	var thresholds = [2*threshold_v, 3*threshold_v, 5*threshold_v, 8*threshold_v]
	return thresholds


func get_recipe_memorized_level(name):
	assert(known_recipes.has(name), "Not a valid recipe name: "+str(name))
	var thresholds = get_memorized_thresholds(name)
	for i in range(thresholds.size()-1, -1, -1):
		if known_recipes[name].amount >= thresholds[i]:
			return i + 1
	return 0


func is_max_level(prog_type):
	var prog = UnlockManager.get_progression(prog_type)
	if Debug.IS_DEMO:
		return get_progression_level(prog_type) >= 3
	else:
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


func get_stat(type):
	assert(stats.has(type), "Not a valid stat: "+str(type))
	return stats[type]


func set_stat(type, value):
	assert(stats.has(type), "Not a valid stat: "+str(type))
	stats[type] = value
	FileManager.save_profile()
