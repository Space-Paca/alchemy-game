extends Node

const UNLOCKS = {
	"recipes": [
		"test",
	],
	"artifacts": [
		"test",
	],
	"misc": [
		{
			"type": "node",
			"name": "laboratory",
		},
		{
			"type": "node",
			"name": "blacksmith",
		},
		{
			"type": "event",
			"name": "event1",
		},
		{
			"type": "event",
			"name": "event2",
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
		if data.type == "event":
			unlocks.append(data.name)
		count += 1
	return unlocks


func is_misc_unlocked(level, name):
	var unlocks = []
	var count = 0
	for data in UNLOCKS.misc:
		if count >= level:
			break
		if data.name == "name":
			return true
		count += 1
	return false
