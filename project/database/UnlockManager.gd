extends Node

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
			"name": "compendium",
			"description": "Lalalalal",
			"texture_path": "res://assets/images/ui/compendium_icon.png"
		},
		{
			"type": "LOCATION",
			"name": "LABORATORY",
			"description": "Popopopop",
			"texture_path": "res://assets/images/ui/cauldron.png"
		},
		{
			"type": "LOCATION",
			"name": "REAGENT_SMITH",
			"description": "Pipipipip",
			"texture_path": "res://assets/images/map/smith.png"
		},
		{
			"type": "EVENT",
			"name": 21,
			"description": "Evento 21",
		},
		{
			"type": "EVENT",
			"id": 22,
			"description": "Evento 22",
		}
	]
}


func get_unlock(level, type):
	assert(UNLOCKS.has(type), "Not a valid unlock type: " + str(type))
	if UNLOCKS[type].size() <= level:
		return UNLOCKS[type][level - 1]
	else:
		print("No " + str(type) + " unlocks for this level: " + str(level))
		return false


func get_unlock_data(level, type):
	assert(UNLOCKS.has(type), "Not a valid unlock type: " + str(type))
	assert(UNLOCKS[type].size() <= level,
			"No " + str(type) + " unlocks for this level: " + str(level))
	
	var data := {}
	
	match type:
		"recipes":
			var recipe_name = get_unlock(level, type)
			var recipe : Recipe = RecipeManager.recipes[recipe_name]
			data["type"] = "RECIPE"
			data["name"] = recipe.name
			data["texture"] = recipe.fav_icon
			data["description"] = RecipeManager.get_description(recipe.name)
		"artifacts":
			var artifact_name = get_unlock(level, type)
			var artifact_data = ArtifactDB.get_from_name(artifact_name)
			data["type"] = str(ArtifactDB.get_rarity_from_name(artifact_name),
					" ARTIFACT")
			data["name"] = artifact_data.name
			data["texture"] = artifact_data.image
			data["description"] = artifact_data.description
		"misc":
			data = get_unlock(level, type)
			if data.type == "EVENT":
				var event = EventManager.get_event_by_id(data.event_id)
				data["name"] = event.title
				data["texture"] = EventManager.IMAGES[event.type]
			else:
				data["texture"] = load(data.texture_path)
	
	return data


func get_all_unlocked_recipes(level):
	var unlocks = []
	var count = 0
	for recipe in UNLOCKS.recipes:
		if count >= level:
			break
		unlocks.append(recipe)
		count += 1
	return unlocks


func get_all_unlocked_artifacts(level):
	var unlocks = []
	var count = 0
	for artifact in UNLOCKS.artifacts:
		if count >= level:
			break
		unlocks.append(artifact)
		count += 1
	return unlocks


func get_all_unlocked_events(level):
	var unlocks = []
	var count = 0
	for data in UNLOCKS.misc:
		if count >= level:
			break
		if data.type == "EVENT":
			unlocks.append(data.name)
		count += 1
	return unlocks


func is_misc_unlocked(level, name):
	var count = 0
	for data in UNLOCKS.misc:
		if count >= level:
			break
		if data.name == name:
			return true
		count += 1
	return false
