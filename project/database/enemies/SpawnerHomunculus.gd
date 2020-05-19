extends Reference

signal acted

var enemy_ref #Reference to enemy node
var player_ref #Reference to player node

var intents = {"attack": preload("res://assets/images/enemies/intents/attack_normal.png"),
			   "defend": preload("res://assets/images/enemies/intents/blocking.png"),
			   "spawn": preload("res://assets/images/enemies/intents/summoning.png"),
			  }
var image = "res://assets/images/enemies/homunculus/idle.png"
var name = "Tanky"
var sfx = "enemy_slime"
var hp = 25
var battle_init = false
var size = "medium"
var damage = [5, 6]
var small_defense = [4, 5]
var defense = [8, 10]

var states = ["attack", "defend", "spawn"]
var connections = [
					  ["attack", "defend", 5],
					  ["attack", "spawn", 5],
					  ["defend", "attack", 5],
					  ["defend", "spawn", 5],
					  ["spawn", "attack", 1],
					  ["spawn", "defend", 1],
				  ]
var first_state = ["attack", "defend"]

var next_attack_value
var next_defend_value

func set_node_references(e_ref, p_ref):
	enemy_ref = e_ref
	player_ref = p_ref

func get_damage():
	randomize()
	return randi()%(damage[1]-damage[0]+1)+damage[0]

func get_small_defense():
	randomize()
	return randi()%(small_defense[1]-small_defense[0]+1)+small_defense[0]

func get_defense():
	randomize()
	return randi()%(defense[1]-defense[0]+1)+defense[0]

func act(state):
	if state == "attack":
		emit_signal("acted", enemy_ref, [["shield", {"value": next_defend_value}], \
							 			 ["damage", {"value": next_attack_value, "type": "regular"}]])
	elif state == "defend":
		emit_signal("acted", enemy_ref, [["shield", {"value": next_defend_value}]])
	elif state == "spawn":
		emit_signal("acted", enemy_ref, [["spawn", {"enemy": "baby_poison"}]])

func get_intent_data(state):
	var data = []

	if state == "attack":
		var intent1 = {}
		next_defend_value = get_small_defense()
		intent1.image = intents.defend
		intent1.value = next_defend_value
		data.append(intent1)
		next_attack_value = get_damage()
		var intent = {}
		intent.image = intents.attack
		intent.value = next_attack_value
		data.append(intent)
	elif state == "defend":
		var intent = {}
		next_defend_value = get_defense()
		intent.image = intents.defend
		intent.value = next_defend_value
		data.append(intent)
	elif state == "spawn":
		var intent = {}
		intent.image = intents.spawn
		data.append(intent)

	return data

func get_intent_tooltips(state):
	var tooltips = []
	
	if state == "defend":
		var tooltip = {}
		tooltip.title = "Defending"
		tooltip.text = "This enemy is going to defend next turn"
		tooltip.title_image = intents.defend.get_path()
		tooltips.append(tooltip)
	elif state == "attack":
		var tooltip1 = {}
		tooltip1.title = "Defending"
		tooltip1.text = "This enemy is going to defend next turn"
		tooltip1.title_image = intents.defend.get_path()
		tooltips.append(tooltip1)
		var tooltip2 = {}
		tooltip2.title = "Attacking"
		tooltip2.text = "This enemy is attacking next turn"
		tooltip2.title_image = intents.attack.get_path()
		tooltips.append(tooltip2)
	if state == "spawn":
		var tooltip = {}
		tooltip.title = "Spawning"
		tooltip.text = "This enemy is going to spawn an enemy next turn"
		tooltip.title_image = intents.spawn.get_path()
		tooltips.append(tooltip)
	
	return tooltips

