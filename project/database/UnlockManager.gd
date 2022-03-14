extends Node


const PROGRESSIONS = {
	"recipes": [300, 650, 1200, 1800, 2700, 3850, 5000, 7300],
	"artifacts": [500, 1150, 2000, 3200, 4700, 6800, 8900, 11000],
	"misc": [100, 600, 1200, 2000, 3000],
}
const UNLOCKS = {
	"recipes": [
		"cycle",
		"poison-area",
		"draw",
		"poison-plus",
		"dano-omega",
		"draw-plus",
		"dano-omegaplus",
		"draw-plusplus",
	],
	"artifacts": [
		"buff_poison",
		"reveal_map",
		"temp_strength",
		"vulture_mask",
		"strength_plus",
		"full_rest",
		"poisoned_dagger",
		"midas"
	],
	"misc": [
		{
			"type": "MISC",
			"name": "COMPENDIUM",
			"description": "COMPENDIUM_UNLOCK_DESC",
			"texture_path": "res://assets/images/ui/compendium_icon.png",
			"sfx": "unlock_compendium",
		},
		{
			"type": "LOCATION",
			"name": "LABORATORY",
			"description": "LABORATORY_UNLOCK_DESC",
			"texture_path": "res://assets/images/ui/cauldron.png",
			"sfx": "unlock_lab",
		},
		{
			"type": "LOCATION",
			"name": "REAGENT_SMITH",
			"description": "REAGENT_SMITH_UNLOCK_DESC",
			"texture_path": "res://assets/images/map/smith.png",
			"sfx": "unlock_reagent_smith",
		},
		{
			"type": "EVENT",
			"event_id": 18,
			"description": "EVENT_UNLOCK_DESC",
		},
		{
			"type": "EVENT",
			"event_id": 20,
			"description": "EVENT_UNLOCK_DESC",
		}
	]
}


func get_progression(type):
	assert(PROGRESSIONS.has(type), "Not a valid type of progression: " + str(type))
	return PROGRESSIONS[type]


func get_progression_level(type, cur_xp):
	var prog = get_progression(type)
	for i in range(0, prog.size()):
		if prog[i] > cur_xp:
			return i
	return prog.size()


func get_unlock(level, type):
	assert(UNLOCKS.has(type), "Not a valid unlock type: " + str(type))
	if UNLOCKS[type].size() >= level:
		return UNLOCKS[type][level - 1]
	else:
		print("No " + str(type) + " unlocks for this level: " + str(level))
		return {}


func get_unlock_data(type):
	var level = Profile.get_progression_level(type)
	assert(UNLOCKS[type].size() >= level,
			"No " + str(type) + " unlocks for this level: " + str(level))
	
	var data := {}
	
	match type:
		"recipes":
			var recipe_name = get_unlock(level, type)
			var recipe : Recipe = RecipeManager.recipes[recipe_name]
			data["type"] = "RECIPE"
			data["name"] = recipe.name
			data["texture"] = recipe.fav_icon
			data["description"] = RecipeManager.get_description(recipe)
			data["sfx"] = "unlock_recipe"
		"artifacts":
			var artifact_name = get_unlock(level, type)
			var artifact_data = ArtifactDB.get_from_name(artifact_name)
			data["type"] = tr(ArtifactDB.get_rarity_from_name(artifact_name))
			data["name"] = artifact_data.name
			data["texture"] = artifact_data.image
			data["description"] = artifact_data.description
			data["sfx"] = "unlock_artifact"
		"misc":
			data = get_unlock(level, type)
			if data.type == "EVENT":
				var event = EventManager.get_event_by_id(data.event_id)
				data["name"] = event.title
				data["texture"] = EventManager.get_event_image(data.event_id)
				data["sfx"] = "unlock_events"
			else:
				data["texture"] = load(data.texture_path)
	
	data.style = type
	return data


func get_all_unlocked_recipes():
	var level = Profile.get_progression_level("recipes")
	var unlocks = []
	var count = 0
	for recipe in UNLOCKS.recipes:
		if count >= level:
			break
		unlocks.append(recipe)
		count += 1
	return unlocks


func get_all_unlocked_artifacts():
	var level = Profile.get_progression_level("artifacts")
	var unlocks = []
	var count = 0
	for artifact in UNLOCKS.artifacts:
		if count >= level:
			break
		unlocks.append(artifact)
		count += 1
	return unlocks


func get_locked_events():
	var level = Profile.get_progression_level("misc")
	var events = []
	var count = 0
	for data in UNLOCKS.misc:
		if count < level:
			continue
		if data.type == "EVENT":
			events.append(data.event_id)
		count += 1
	return events


func is_misc_unlocked(name):
	var level = Profile.get_progression_level("misc")
	var count = 0
	for data in UNLOCKS.misc:
		if count >= level:
			break
		if data.name == name:
			return true
		count += 1
	return false
