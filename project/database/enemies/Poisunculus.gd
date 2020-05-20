extends Reference

signal acted

var enemy_ref #Reference to enemy node
var player_ref #Reference to player node

var intents = {"poison": preload("res://assets/images/enemies/intents/debuffing.png"),
			   "attack": preload("res://assets/images/enemies/intents/attack_normal.png"),
			   "defend": preload("res://assets/images/enemies/intents/blocking.png"),
			  }
var image = "res://assets/images/enemies/homunculus/idle.png"
var name = "Venenin"
var sfx = "slime"
var use_idle_sfx = true
var hp = 60
var battle_init = false
var size = "big"
var damage = [4, 6]
var poison = [1, 2]
var big_poison = [5, 7]
var defense = [13, 15]

var states = ["poison", "defend-poison", "attack-poison"]
var connections = [
					  ["poison", "defend-poison", 5],
					  ["poison", "attack-poison", 3],
					  ["defend-poison", "poison", 1],
					  ["attack-poison", "poison", 1],
				  ]
var first_state = ["poison"]

var next_attack_value
var next_defend_value
var next_poison_value

func set_node_references(e_ref, p_ref):
	enemy_ref = e_ref
	player_ref = p_ref

func get_damage():
	randomize()
	return randi()%(damage[1]-damage[0]+1)+damage[0]

func get_defense():
	randomize()
	return randi()%(defense[1]-defense[0]+1)+defense[0]

func get_poison():
	randomize()
	return randi()%(poison[1]-poison[0]+1)+poison[0]

func get_big_poison():
	randomize()
	return randi()%(big_poison[1]-big_poison[0]+1)+big_poison[0]

func act(state):
	if state == "poison":
		emit_signal("acted", enemy_ref, [["status", {"status": "poison", "amount": next_poison_value, "target": player_ref, "positive": false}]])
	elif state == "attack-poison":
		emit_signal("acted", enemy_ref, [["damage", {"value": next_attack_value, "type": "crushing"}],
										 ["status", {"status": "poison", "amount": next_poison_value, "target": player_ref, "positive": false}]])
	elif state == "defend-poison":
		emit_signal("acted", enemy_ref, [["shield", {"value": next_defend_value}],
										 ["status", {"status": "poison", "amount": next_poison_value, "target": player_ref, "positive": false}]])

func get_intent_data(state):
	var data = []

	if state == "poison":
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
	elif state == "attack-poison":
		var intent1 = {}
		next_attack_value = get_damage()
		intent1.image = intents.attack
		intent1.value = next_attack_value
		data.append(intent1)
		var intent2 = {}
		next_poison_value = get_poison()
		intent2.image = intents.poison
		intent2.value = next_poison_value
		data.append(intent2)

	
	return data

func get_intent_tooltips(state):
	var tooltips = []
	
	if state == "poison":
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
	elif state == "attack-poison":
		var tooltip1 = {}
		tooltip1.title = "Attacking"
		tooltip1.text = "This enemy is attacking next turn"
		tooltip1.title_image = intents.attack.get_path()
		tooltips.append(tooltip1)
		var tooltip2 = {}
		tooltip2.title = "Poisoning"
		tooltip2.text = "This enemy is spitting poison next turn"
		tooltip2.title_image = intents.poison.get_path()
		tooltips.append(tooltip2)
	
	return tooltips
