extends Reference

signal acted

var enemy_ref #Reference to enemy node
var player_ref #Reference to player node

var intents = {"attack": preload("res://assets/images/enemies/intents/attack_normal.png"),
			   "buff": preload("res://assets/images/enemies/intents/buffing.png"),
			   "dodge": preload("res://assets/images/enemies/intents/buffing.png"),
			   "spawn": preload("res://assets/images/enemies/intents/summoning.png"),
			  }
var image = "res://assets/images/enemies/spawner poison enemy/idle.png"
var name = "Elite Dodger"
var sfx = "slime"
var use_idle_sfx = true
var hp = 40
var battle_init = true
var size = "medium"
var damage = [2, 4]
var dodge = 2
var buff = 3

var states = ["attack1", "buff1", "attack2", "buff2", "spawn"]
var connections = [
					  ["attack1", "attack2", 1],
					  ["attack1", "buff2", 2],
					  ["buff1", "attack2", 2],
					  ["buff1", "buff2", 1],
					  ["attack2", "spawn", 1],
					  ["buff2", "spawn", 1],
					  ["spawn", "attack1", 1],
					  ["spawn", "buff1", 1],
				  ]
var first_state = ["spawn"]

var next_attack_value
var next_defend_value

func set_node_references(e_ref, p_ref):
	enemy_ref = e_ref
	player_ref = p_ref

func get_damage():
	randomize()
	return randi()%(damage[1]-damage[0]+1)+damage[0]

func act(state):
	if state == "attack1" or state == "attack2":
		emit_signal("acted", enemy_ref, [["status", {"status": "dodge", "amount": dodge, "target": enemy_ref, "positive": true}], \
							 			 ["damage", {"value": next_attack_value, "type": "regular"}]])
	elif state == "buff1" or state == "buff2":
		emit_signal("acted", enemy_ref, [["status", {"status": "dodge", "amount": dodge, "target": enemy_ref, "positive": true}], \
							 			 ["status", {"status": "perm_strength", "amount": buff, "target": enemy_ref, "positive": true}]])
	elif state == "spawn":
		emit_signal("acted", enemy_ref, [["status", {"status": "dodge", "amount": dodge, "target": enemy_ref, "positive": true}],
										 ["spawn", {"enemy": "baby_slasher"}],
										 ["spawn", {"enemy": "baby_slasher"}]])

func get_intent_data(state):
	var data = []

	if state == "attack1" or state == "attack2":
		var intent1 = {}
		intent1.image = intents.dodge
		intent1.value = dodge
		data.append(intent1)
		next_attack_value = get_damage()
		var intent2 = {}
		intent2.image = intents.attack
		intent2.value = next_attack_value + enemy_ref.get_damage_modifiers(false)
		data.append(intent2)
	elif state == "buff1" or state == "buff2":
		var intent1 = {}
		intent1.image = intents.dodge
		intent1.value = dodge
		data.append(intent1)
		var intent2 = {}
		intent2.image = intents.buff
		intent2.value = buff
		data.append(intent2)
	elif state == "spawn":
		var intent1 = {}
		intent1.image = intents.dodge
		intent1.value = dodge
		data.append(intent1)
		var intent2 = {}
		intent2.image = intents.spawn
		data.append(intent2)
		var intent3 = {}
		intent3.image = intents.spawn
		data.append(intent3)


	return data

func get_intent_tooltips(state):
	var tooltips = []
	
	if state == "buff1" or state == "buff2":
		var tooltip1 = {}
		tooltip1.title = "Dodging"
		tooltip1.text = "This enemy is going to dodge next turn"
		tooltip1.title_image = intents.dodge.get_path()
		tooltips.append(tooltip1)
		var tooltip2 = {}
		tooltip2.title = "Getting Strong"
		tooltip2.text = "This enemy is getting a permanent attack buff"
		tooltip2.title_image = intents.buff.get_path()
		tooltips.append(tooltip2)
	elif state == "attack1" or state == "attack2":
		var tooltip1 = {}
		tooltip1.title = "Dodging"
		tooltip1.text = "This enemy is going to dodge next turn"
		tooltip1.title_image = intents.dodge.get_path()
		tooltips.append(tooltip1)
		var tooltip2 = {}
		tooltip2.title = "Attacking"
		tooltip2.text = "This enemy is attacking next turn"
		tooltip2.title_image = intents.attack.get_path()
		tooltips.append(tooltip2)
	if state == "spawn":
		var tooltip1 = {}
		tooltip1.title = "Dodging"
		tooltip1.text = "This enemy is going to dodge next turn"
		tooltip1.title_image = intents.dodge.get_path()
		tooltips.append(tooltip1)
		var tooltip2 = {}
		tooltip2.title = "Spawning"
		tooltip2.text = "This enemy is going to spawn an enemy next turn"
		tooltip2.title_image = intents.spawn.get_path()
		tooltips.append(tooltip2)
	
	return tooltips

