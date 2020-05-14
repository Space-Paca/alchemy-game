extends Reference

signal acted

var enemy_ref #Reference to enemy node
var player_ref #Reference to player node

var intents = {"poison": preload("res://assets/images/enemies/intents/random.png"),
			   "defend": preload("res://assets/images/enemies/intents/defense.png"),
			  }
var image = "res://assets/images/enemies/homunculus/idle.png"
var name = "Venenin"
var sfx = "enemy_1"
var hp = 6
var battle_init = true
var size = "small"
var poison = [1, 2]
var medium_poison = [2, 3]
var big_poison = [3, 4]
var defense = [7, 9]
var start_shield = 6

var states = ["init", "poison", "defend-poison", "medium-poison"]
var connections = [
					  ["init", "poison", 1],
					  ["poison", "defend-poison", 5],
					  ["poison", "medium-poison", 3],
					  ["defend-poison", "medium-poison", 1],
					  ["medium-poison", "defend-poison", 1],
				  ]
var first_state = ["init"]

var next_defend_value
var next_poison_value

func set_node_references(e_ref, p_ref):
	enemy_ref = e_ref
	player_ref = p_ref

func get_defense():
	randomize()
	return randi()%(defense[1]-defense[0]+1)+defense[0]

func get_poison():
	randomize()
	return randi()%(poison[1]-poison[0]+1)+poison[0]

func get_medium_poison():
	randomize()
	return randi()%(medium_poison[1]-medium_poison[0]+1)+medium_poison[0]

func get_big_poison():
	randomize()
	return randi()%(big_poison[1]-big_poison[0]+1)+big_poison[0]

func act(state):
	if state == "init":
		emit_signal("acted", enemy_ref, [["shield", {"value": start_shield}]])
	elif state == "poison":
		emit_signal("acted", enemy_ref, [["status", {"status": "poison", "amount": next_poison_value, "target": player_ref, "positive": false}]])
	elif state == "medium-poison":
		emit_signal("acted", enemy_ref, [["status", {"status": "poison", "amount": next_poison_value, "target": player_ref, "positive": false}]])
	elif state == "defend-poison":
		emit_signal("acted", enemy_ref, [["shield", {"value": next_defend_value}],
										 ["status", {"status": "poison", "amount": next_poison_value, "target": player_ref, "positive": false}]])

func get_intent_data(state):
	var data = []
	
	if state == "init":
		var intent = {}
		intent.image = intents.defend
		intent.value = start_shield
		data.append(intent)
	elif state == "poison":
		next_poison_value = get_big_poison()
		var intent = {}
		intent.image = intents.poison
		intent.value = next_poison_value
		data.append(intent)
	elif state == "defend-poison":
		var intent1 = {}
		next_defend_value = get_defense()
		intent1.image = intents.defend
		intent1.value = next_defend_value
		data.append(intent1)
		var intent2 = {}
		next_poison_value = get_poison()
		intent2.image = intents.poison
		intent2.value = next_poison_value
		data.append(intent2)
	elif state == "medium-poison":
		next_poison_value = get_medium_poison()
		var intent = {}
		intent.image = intents.poison
		intent.value = next_poison_value
		data.append(intent)
	
	return data

func get_intent_tooltips(state):
	var tooltips = []
	
	if state == "init":
		var tooltip = {}
		tooltip.title = "Defending"
		tooltip.text = "This enemy is going to defend next turn"
		tooltip.title_image = intents.defend.get_path()
		tooltips.append(tooltip)
	elif state == "poison" or state == "medium-poison":
		var tooltip = {}
		tooltip.title = "Poisoning"
		tooltip.text = "This enemy is spitting poison next turn"
		tooltip.title_image = intents.poison.get_path()
		tooltips.append(tooltip)
	elif state == "defend-poison":
		var tooltip1 = {}
		tooltip1.title = "Defending"
		tooltip1.text = "This enemy is going to defend next turn"
		tooltip1.title_image = intents.defend.get_path()
		tooltips.append(tooltip1)
		var tooltip2 = {}
		tooltip2.title = "Poisoning"
		tooltip2.text = "This enemy is spitting poison next turn"
		tooltip2.title_image = intents.poison.get_path()
		tooltips.append(tooltip2)
	
	return tooltips
