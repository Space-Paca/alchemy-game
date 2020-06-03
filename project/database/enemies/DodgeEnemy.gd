extends Reference

signal acted

var enemy_ref #Reference to enemy node
var player_ref #Reference to player node

var intents = {"attack": preload("res://assets/images/enemies/intents/attack_normal.png"),
				"dodge": preload("res://assets/images/enemies/intents/buffing.png"),
			   }
var image = "res://assets/images/enemies/homunculus/idle.png"
var name = "Dodge Enemy"
var sfx = "enemy_2"
var use_idle_sfx = false
var hp = 28
var battle_init = true
var size = "small"
var damage = [5, 7]
var big_damage = [7,9]

var states = ["init", "dodge", "attack", "big_attack"]
var connections = [	      ["init", "big_attack", 1],
						  ["big_attack", "dodge", 1],
						  ["big_attack", "attack", 1],
						  ["dodge", "attack", 6],
						  ["dodge", "dodge", 4],
						  ["dodge", "big_attack", 1],
						  ["attack", "dodge", 5],
						  ["attack", "attack", 5],
						  ["attack", "big_attack", 1],
				 ]
var first_state = ["init"]

var next_value

func set_node_references(e_ref, p_ref):
	enemy_ref = e_ref
	player_ref = p_ref

func get_rand(value_range):
	randomize()
	return randi()%(value_range[1]-value_range[0]+1)+value_range[0]


func act(state):
	if state == "init":
		emit_signal("acted", enemy_ref, [["status", {"status": "dodge", "amount": 1, "target": enemy_ref, "positive": true}]])
	elif state == "big_attack":
		emit_signal("acted", enemy_ref, [["damage", {"value": next_value, "type": "regular"}]])
	elif state == "attack":
		emit_signal("acted", enemy_ref, [["status", {"status": "dodge", "amount": 1, "target": enemy_ref, "positive": true}],
										 ["damage", {"value": next_value, "type": "regular"}]])
	elif state == "dodge":
		emit_signal("acted", enemy_ref, [["status", {"status": "dodge", "amount": 2, "target": enemy_ref, "positive": true}]])

func get_intent_data(state):
	var data = []
	
	if state == "init":
		var intent = {}
		intent.image = intents["dodge"]
		data.append(intent)
	elif state == "big_attack":
		var intent = {}
		intent.image = intents["attack"]
		next_value = get_rand(big_damage)
		intent.value = next_value
		data.append(intent)
	elif state == "attack":
		var intent1 = {}
		intent1.image = intents["attack"]
		next_value = get_rand(big_damage)
		intent1.value = next_value
		data.append(intent1)
		var intent2 = {}
		intent2.image = intents["dodge"]
		intent2.value = 1
		data.append(intent2)
	elif state == "dodge":
		var intent = {}
		intent.image = intents["dodge"]
		intent.value = 2
		data.append(intent)

	return data

func get_intent_tooltips(state):
	var tooltips = []
	
	if state == "init":
		var tooltip = {}
		tooltip.title = "Dodging"
		tooltip.text = "This enemy is going to dodge next turn"
		tooltip.title_image = intents.dodge.get_path()
		tooltips.append(tooltip)
	elif state == "big_attack":
		var tooltip = {}
		tooltip.title = "Attacking"
		tooltip.text = "This enemy is attacking next turn"
		tooltip.title_image = intents.attack.get_path()
		tooltips.append(tooltip)
	elif state == "attack":
		var tooltip1 = {}
		tooltip1.title = "Attacking"
		tooltip1.text = "This enemy is attacking next turn"
		tooltip1.title_image = intents.attack.get_path()
		tooltips.append(tooltip1)
		var tooltip2 = {}
		tooltip2.title = "Dodging"
		tooltip2.text = "This enemy is going to dodge next turn"
		tooltip2.title_image = intents.dodge.get_path()
		tooltips.append(tooltip2)
	elif state == "dodge":
		var tooltip = {}
		tooltip.title = "Dodging"
		tooltip.text = "This enemy is going to dodge next turn"
		tooltip.title_image = intents.dodge.get_path()
		tooltips.append(tooltip)
	
	return tooltips
