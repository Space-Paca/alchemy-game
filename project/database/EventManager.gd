extends Node

signal left_event
signal spawned_rest
signal spawned_battle(encounter)

const FLOORS = [1, 2, 3]

const IMAGES = [preload("res://assets/images/events/event_luck.png"),
		preload("res://assets/images/events/event_challenge.png"),
		preload("res://assets/images/events/event_tradeoff.png"),
		preload("res://assets/images/events/event_positive.png"),
		preload("res://assets/images/events/event_quest.png")]

# Event constants
const HOLE_MAX_CHANCE = .8

var events_by_id := {}
var event_ids_by_floor := {1: [], 2: [], 3: []}
var dummy_battle_event : Event
var dummy_leave_event : Event
var dummy_rest_event : Event
var current_quest : Event
var current_event : Event


func _ready():
	var dir := Directory.new()
	var path := "res://database/events/"
	if dir.open(path) == OK:
# warning-ignore:return_value_discarded
		dir.list_dir_begin()
		var file_name := dir.get_next() as String
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() == "tres":
				var event := load(str(path, file_name)) as Event
				events_by_id[event.id] = event
			file_name = dir.get_next()
	else:
		print("EventManager: An error occurred when trying to access the path.")
	
	dummy_battle_event = events_by_id[-1]
	dummy_leave_event = events_by_id[-2]
	dummy_rest_event = events_by_id[-3]


func reset_events():
	for f in FLOORS:
		event_ids_by_floor[f].clear()
	
	for event in events_by_id.values():
		for f in FLOORS:
			if event.floor_appearance[f] and\
			   not UnlockManager.get_locked_events().has(event.id) and\
			   (not Debug.is_demo or event.use_on_demo):
				event_ids_by_floor[f].append(event.id)
	
	for f in FLOORS:
		event_ids_by_floor[f].shuffle()
	
	# Reset event 4 (hole) chances and reward
	events_by_id[4].options[0]["args"] = events_by_id[3].options[0]["args"]
	# Reset event 13 (blood font) amount of times payed
	events_by_id[13].options[0]["args"] = events_by_id[12].options[0]["args"]
	# Reset event 15 (blood sacrifice) options
	events_by_id[15].options = events_by_id[14].options.duplicate(true)
	# Reset event 19 (boneyard) amount of times searched
	events_by_id[19].options[0]["args"][0] = 0


func reward_random_artifact(player: Player, artifacts: Array) -> void:
	artifacts.shuffle()
	for artifact in artifacts:
		if not player.has_artifact(artifact):
			player.add_artifact(artifact)
			return
	
	assert(false, "Couldn't reward random artifact")


func get_random_event(current_floor: int) -> Event:
	## For testing purposes
	if not event_ids_by_floor[current_floor].size():
		dummy_leave_event.title = "No event to show"
		dummy_leave_event.text = str("Not enough events for floor ", current_floor)
		return dummy_leave_event
	
	var id : int
	
	assert(event_ids_by_floor[current_floor].size())
	id = event_ids_by_floor[current_floor].pop_front()
	
	for f in FLOORS:
		event_ids_by_floor[f].erase(id)
	
	return get_event_by_id(id)


func get_event_by_id(id: int) -> Event:
	current_event = events_by_id[id]
	return current_event


func get_event_image(id: int) -> Texture:
	return events_by_id[id].image

####### SAVE/LOAD METHODS #######

func get_save_data():
	var data = {
		"events_ids_by_floor": event_ids_by_floor.duplicate(true),
	}
	return data


func load_save_data(data):
	event_ids_by_floor = {1: [], 2: [], 3: []}
	
	#Manually setting events since data labels are all strings
	for f in data.events_ids_by_floor:
		event_ids_by_floor[int(f)] = data.events_ids_by_floor[f]
	


####### GENERAL EVENT CALLBACKS #######

func none(_event_display, _player):
	assert(false, "No callback set for this option")


func battle(_event_display, _player, encounter):
	emit_signal("spawned_battle", encounter)


func leave(_event_display, _player):
	emit_signal("left_event")


func rest(_event_display, _player):
	emit_signal("spawned_rest")


func leave_option(event_display, player):
	load_leave_event(event_display, player, current_event.leave_text_4)


func load_battle_event(event_display, player, text: String, encounter: Encounter,
		title := "", type := -1):
	dummy_battle_event.text = tr(text)
	dummy_battle_event.title = tr(current_event.title if title == "" else title)
	dummy_battle_event.type = current_event.type if type == -1 else type
	dummy_battle_event.options[0].args[0] = encounter
	dummy_battle_event.image = current_event.image
	load_new_event(event_display, player, dummy_battle_event.id)


func load_leave_event(event_display, player, text: String, title := "", type := -1):
	dummy_leave_event.text = tr(text)
	dummy_leave_event.title = tr(current_event.title if title == "" else title)
	dummy_leave_event.type = current_event.type if type == -1 else type
	dummy_leave_event.image = current_event.image
	load_new_event(event_display, player, dummy_leave_event.id)


func load_rest_event(event_display, player, text: String, title := "", type := -1):
	dummy_rest_event.text = tr(text)
	dummy_rest_event.title = tr(current_event.title if title == "" else title)
	dummy_rest_event.type = current_event.type if type == -1 else type
	load_new_event(event_display, player, dummy_rest_event.id)


func load_new_event(event_display, player, new_event_id: int,
		override_text : String = ""):
	event_display.load_event(events_by_id[new_event_id], player, override_text)
	current_event = events_by_id[new_event_id]


####### SPECIFIC EVENT CALLBACKS #######

#1
func bet(event_display, player, amount: int):
	if not player.spend_gold(amount):
		AudioManager.play_sfx("error")
		return
	
	if randf() > .5:
		player.add_gold(2 * amount)
		var text : String = current_event.leave_text_1
		text = tr(text)
		text = text.replace("<amount>", str(2 * amount))
		load_leave_event(event_display, player, text)
	else:
		load_leave_event(event_display, player, current_event.leave_text_2)

#2
func well(event_display, player, amount: int):
	if not player.spend_gold(amount):
		AudioManager.play_sfx("error")
		return
	
	var won = false
	if amount == 50:
		var rand = randf()
		if rand < .5:
			won = true
		elif rand < .9:
			var artifacts : Array = ArtifactDB.get_artifacts("uncommon")
			reward_random_artifact(player, artifacts)
			load_leave_event(event_display, player, current_event.leave_text_2)
			return
	else:
		var chance = {5: .1, 10: .25, 30: .8}
		won = randf() < chance[amount]
	
	if won:
		var reward = 100
		player.add_gold(reward)
		var text = tr(current_event.leave_text_1)
		text = text.replace("<amount>", str(reward))
		load_leave_event(event_display, player, text)
	else:
		load_leave_event(event_display, player, current_event.leave_text_3)

#3 / 4
func hole(event_display, player, chance, reward):
	if randf() < chance:
		player.set_hp(int(ceil(player.hp / 2.0)))
		player.add_gold(reward)
		var text = tr(current_event.leave_text_1)
		text = text.replace("<amount>", str(reward))
		load_leave_event(event_display, player, text)
	else:
		player.add_gold(reward)
		
		# Increase next attempt's chance of failure and reward
		events_by_id[4].options[0]["args"][0] *= 2
		if events_by_id[4].options[0]["args"][0] > HOLE_MAX_CHANCE:
			events_by_id[4].options[0]["args"][0] = HOLE_MAX_CHANCE
		events_by_id[4].options[0]["args"][1] *= 2
		
		var text = tr(events_by_id[4].text)
		text = text.replace("<amount>", str(reward))
		
		load_new_event(event_display, player, 4, text)

# 5
# Troca até 3 reagentes do jogador por um número igual de reagentes aleatórios


#6 / 7
func artifact_battle(event_display, player, artifact_rarity: String,
		encounter_type: String, chance: float):
	var encounter : Encounter
	reward_random_artifact(player, ArtifactDB.get_artifacts(artifact_rarity))
	
	if encounter_type == "normal":
		encounter = EncounterManager.get_random_encounter()
	elif encounter_type == "elite":
		encounter = EncounterManager.get_random_elite_encounter()
	
	if randf() < chance:
		load_battle_event(event_display, player, current_event.leave_text_2,
				encounter)
	else:
		load_leave_event(event_display, player, current_event.leave_text_1)

#8
func boss_2_battle(event_display, player, chance: float):
	var encounter : Encounter = EncounterManager.boss_encounters[2].front()
	reward_random_artifact(player, ArtifactDB.get_artifacts("rare"))
	
	if randf() < chance:
		load_battle_event(event_display, player, current_event.leave_text_2,
				encounter)
	else:
		load_leave_event(event_display, player, current_event.leave_text_1)

#9
func take_pearls(event_display, player):
	var amount : int = 2 if randf() < .5 else 3
	var text = tr(current_event.leave_text_1)
	text = text.replace("<amount>", str(amount))
	player.add_pearls(amount)
	player.add_artifact("cursed_pearls")
	
	load_leave_event(event_display, player, text)

#10
func take_cursed_artifact(event_display, player, is_halberd):
	var text : String
	if is_halberd:
		player.add_artifact("cursed_halberd")
		text = current_event.leave_text_1
	else:
		player.add_artifact("cursed_shield")
		text = current_event.leave_text_2
	
	load_leave_event(event_display, player, text)

#11
func take_trash(event_display, player, amount):
	var text : String
	var artifacts : Array
	match amount:
		1:
			text = current_event.leave_text_1
			artifacts = ArtifactDB.get_artifacts("common")
		4:
			text = current_event.leave_text_2
			artifacts = ArtifactDB.get_artifacts("uncommon")
		8:
			text = current_event.leave_text_3
			artifacts = ArtifactDB.get_artifacts("rare")
	
	for i in amount:
		player.add_reagent("trash_plus", false)
	
	reward_random_artifact(player, artifacts)
	
	load_leave_event(event_display, player, text)

#12/13
func coins_for_blood(event_display, player, times):
	events_by_id[13].options[0]["args"][0] += 1
	
	if player.hp <= 4:
		player.set_hp(1)
		player.add_artifact("bloodcursed_grimoire")
		load_leave_event(event_display, player, events_by_id[12].leave_text_1)
		return
	
	player.set_hp(player.hp - 4)
	
	if times >= 10:
		reward_random_artifact(player, ArtifactDB.get_artifacts("uncommon"))
		load_leave_event(event_display, player, current_event.leave_text_2)
		return
	
	var text : String
	var gold = 3 + randi() % 5 if randf() > .1 else 10
	
	if times <= 1:
		player.add_gold(gold)
		text = tr(events_by_id[13].text)
		text = text.replace("<amount>", str(gold))
	else:
		player.add_gold(gold)
		text = tr(current_event.leave_text_1)
		text = text.replace("<amount>", str(gold))
	
	load_new_event(event_display, player, 13, text)

#14/15
func life_trade(event_display, player, option_id, life_amount):
	if player.hp <= life_amount:
		AudioManager.play_sfx("error")
		return
	
	player.set_hp(player.hp - life_amount)
	var text : String
	
	match option_id:
		0:
			player.add_gold(15)
			text = events_by_id[14].leave_text_1
		1:
			player.add_pearls(1)
			text = events_by_id[14].leave_text_2
		2:
			reward_random_artifact(player, ArtifactDB.get_artifacts("common"))
			text = events_by_id[14].leave_text_3
	
	for option in events_by_id[15].options:
		if option_id == option["args"][0]:
			events_by_id[15].options.erase(option)
			break
	
	load_new_event(event_display, player, 15, text)

#16
func blood_pact(event_display, player):
	player.set_hp(int(ceil(player.hp * 1.0 / 3.0)))
	player.add_artifact("gold_ankh")
	
	load_leave_event(event_display, player, current_event.leave_text_1)

#17
func resting_place(event_display, player, chose_artifact: bool):
	var text : String
	if chose_artifact:
		player.add_artifact("cursed_scholar_mask")
		text = current_event.leave_text_2
	else:
		text = current_event.leave_text_1
	
	load_rest_event(event_display, player, text)

#18/19
func push_luck(event_display, player, times: int):
	events_by_id[19].options[0]["args"][0] += 1
	
	if randf() < .25 * (times + 1):
		var encounter = EncounterManager.get_random_elite_encounter()
		load_battle_event(event_display, player, events_by_id[19].leave_text_3,
				encounter)
		return
	
	var reward = randf()
	var text : String
	
	if reward < .3:
		text = events_by_id[18].leave_text_1
	elif reward < .6:
		text = events_by_id[18].leave_text_2
		player.add_gold(30)
	elif reward < .9:
		text = events_by_id[18].leave_text_3
		reward_random_artifact(player, ArtifactDB.get_artifacts("common"))
	elif reward < .99:
		text = events_by_id[19].leave_text_1
		reward_random_artifact(player, ArtifactDB.get_artifacts("uncommon"))
	else:
		text = events_by_id[19].leave_text_2
		reward_random_artifact(player, ArtifactDB.get_artifacts("rare"))
	
	text = tr(text)
	if times + 1 >= 3:
		text += tr("EVENT_18_MUST_LEAVE")
		load_leave_event(event_display, player, text)
	else:
		text += tr("EVENT_18_SHOULD_LEAVE")
		load_new_event(event_display, player, 19, text)

#20
func helpful_homunculus(event_display, player, increase_max_hp):
	if increase_max_hp:
		player.increase_max_hp(10)
		load_leave_event(event_display, player, current_event.leave_text_2)
	else:
		player.set_hp(player.hp + 40)
		load_leave_event(event_display, player, current_event.leave_text_1)

#21
func veknor_castle(event_display, player):
	load_leave_event(event_display, player, current_event.leave_text_1)
