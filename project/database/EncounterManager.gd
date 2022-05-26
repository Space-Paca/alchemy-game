extends Node

const PATH := "res://database/encounters/"
const TUTORIAL_ENCOUNTER_NAME := "floor1_1.tres"

var boss_encounters := {}
var elite_encounters := {}
var encounters := {}
var encounter_pool : Array
var encounter_index : int
var elite_encounter_pool : Array
var elite_encounter_index : int
var boss_encounter_pool : Array
var tutorial_encounter

var divider_encounter


func _ready():
	var dir := Directory.new()
	if dir.open(PATH) == OK:
# warning-ignore:return_value_discarded
		dir.list_dir_begin()
		var file_name := dir.get_next() as String
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() == "tres":
				var encounter := load(str(PATH, file_name)) as Encounter
				encounter.resource_name = file_name
				if not Debug.IS_DEMO or encounter.use_on_demo:
					if encounter.is_boss:
						if not boss_encounters.has(encounter.level):
							boss_encounters[encounter.level] = []
						boss_encounters[encounter.level].append(encounter)
					elif encounter.is_elite:
						if not elite_encounters.has(encounter.level):
							elite_encounters[encounter.level] = []
						elite_encounters[encounter.level].append(encounter)
					else:
						if not encounters.has(encounter.level):
							encounters[encounter.level] = []
						encounters[encounter.level].append(encounter)
				
				if encounter.resource_name == TUTORIAL_ENCOUNTER_NAME:
					tutorial_encounter = encounter
				if encounter.resource_name == "floor2_2.tres":
					divider_encounter = encounter
			file_name = dir.get_next()
	else:
		print("EncounterManager: An error occurred when trying to access the path.")

func get_save_data():
	var data = {}
	
	data.encounter_index = encounter_index
	data.encounter_pool = []
	for encounter in encounter_pool:
		data.encounter_pool.append(encounter.resource_name)
	
	data.elite_encounter_index = elite_encounter_index
	data.elite_encounter_pool = []
	for encounter in elite_encounter_pool:
		data.elite_encounter_pool.append(encounter.resource_name)
	
	data.boss_encounter_pool = []
	for encounter in boss_encounter_pool:
		data.boss_encounter_pool.append(encounter.resource_name)
	
	return data


func load_save_data(data):
	encounter_pool = []
	encounter_index = data.encounter_index
	for data_encounter in data.encounter_pool:
		var found = false
		for encounter_level in encounters.values():
			for encounter in encounter_level:
				if encounter.resource_name == data_encounter:
					found = true
					encounter_pool.append(encounter)
					break
			if found:
				break
		assert(found, "Couldn't find normal encounter in database: " + str(data_encounter))
	
	elite_encounter_pool = []
	elite_encounter_index = data.elite_encounter_index
	for data_encounter in data.elite_encounter_pool:
		var found = false
		for encounter_level in elite_encounters.values():
			for encounter in encounter_level:
				if encounter.resource_name == data_encounter:
					found = true
					elite_encounter_pool.append(encounter)
					break
			if found:
				break
		assert(found, "Couldn't find elite encounter in database: " + str(data_encounter))
	
	boss_encounter_pool = []
	for data_encounter in data.boss_encounter_pool:
		var found = false
		for encounter_level in boss_encounters.values():
			for encounter in encounter_level:
				if encounter.resource_name == data_encounter:
					found = true
					boss_encounter_pool.append(encounter)
					break
			if found:
				break
		assert(found, "Couldn't find boss encounter in database: " + str(data_encounter))


func load_resource(resource_name):
	return load(str(PATH, resource_name))


func set_random_encounter_pool(level: int):
	#Regular enemies
	encounter_pool = encounters[level].duplicate()
	encounter_index = 0
	encounter_pool.shuffle()
	
	#Elite enemies
	elite_encounter_pool = elite_encounters[level].duplicate()
	elite_encounter_index = 0
	elite_encounter_pool.shuffle()
	
	#Boss
	boss_encounter_pool = boss_encounters[level].duplicate()
	boss_encounter_pool.shuffle()


func get_tutorial_encounter():
	return tutorial_encounter


func get_random_encounter() -> Encounter:
	if encounter_index >= encounter_pool.size():
		encounter_pool.shuffle()
		encounter_index = 0
	
	var encounter = encounter_pool[encounter_index]
	encounter_index += 1
	return encounter


func get_random_elite_encounter() -> Encounter:
	if elite_encounter_index >= elite_encounter_pool.size():
		elite_encounter_pool.shuffle()
		elite_encounter_index = 0
	
	var encounter = elite_encounter_pool[elite_encounter_index]
	elite_encounter_index += 1
	return encounter


func get_random_boss_encounter() -> Encounter:
	return boss_encounter_pool.pop_front()
