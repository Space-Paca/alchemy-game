extends Reference

signal acted

var enemy_ref #Reference to enemy node
var player_ref #Reference to player node

var intents = {"attack": preload("res://assets/images/enemies/intents/attack_normal.png"),
			   "crushing": preload("res://assets/images/enemies/intents/attack_normal.png"),
			   "buff": preload("res://assets/images/enemies/intents/buffing.png"),
			   "debuff": preload("res://assets/images/enemies/intents/debuffing.png"),
			   "dodge": preload("res://assets/images/enemies/intents/buffing.png"),
			   "spawn": preload("res://assets/images/enemies/intents/summoning.png"),
			   "special": preload("res://assets/images/enemies/intents/random.png"),
			  }
var image = "res://assets/images/enemies/Big Poison Elite/idle.png"
var name = "Boss1"
var sfx = "boss_1"
var use_idle_sfx = false
var hp = 100
var battle_init = true
var size = "big"
var damage = 1
var buff = 2

var states = ["init", "start", "attack1", "attack2", "buff_reagent"]
var connections = [
					  ["init", "start", 1],
					  ["start", "attack1", 1],
					  ["attack1", "attack2", 1],
					  ["attack2", "buff_reagent", 1],
					  ["buff_reagent", "attack1", 1],
	
				  ]
var first_state = ["init"]

var next_attack_value

func set_node_references(e_ref, p_ref):
	enemy_ref = e_ref
	player_ref = p_ref

func act(state):
	if state == "init":
		emit_signal("acted", enemy_ref, [["status", {"status": "guard_up", "amount": 5, "target": enemy_ref, "positive": true}]])
	elif state == "start":
		emit_signal("acted", enemy_ref, [["add_reagent", {"type": "trash", "amount": 5}]])
	elif state == "attack1":
		emit_signal("acted", enemy_ref, [["damage", {"value": damage, "type": "regular", "amount": 2}]])
	elif state == "attack2":
		emit_signal("acted", enemy_ref, [["damage", {"value": damage, "type": "regular", "amount": 3}]])
	elif state == "buff_reagent":
		emit_signal("acted", enemy_ref, [["status", {"status": "perm_strength", "amount": buff, "target": enemy_ref, "positive": true}],
										 ["add_reagent", {"type": "trash", "amount": 5}]])

func get_intent_data(state):
	var data = []

	if state == "attack1":
		var intent = {}
		intent.image = intents.attack
		intent.value = damage + enemy_ref.get_damage_modifiers(false)
		intent.multiplier = 2
		data.append(intent)
	elif state == "attack2":
		var intent = {}
		intent.image = intents.attack
		intent.value = damage + enemy_ref.get_damage_modifiers(false)
		intent.multiplier = 3
		data.append(intent)
	elif state == "init":
		var intent = {}
		intent.image = intents.buff
		data.append(intent)
	elif state == "start":
		var intent = {}
		intent.image = intents.debuff
		intent.value = 5
		data.append(intent)
	elif state == "buff_reagent":
		var intent1 = {}
		intent1.image = intents.buff
		data.append(intent1)
		var intent2 = {}
		intent2.image = intents.debuff
		intent2.value = 5
		data.append(intent2)


	return data

func get_intent_tooltips(state):
	var tooltips = []
	
	if state == "attack1" or state == "attack2":
		var tooltip = {}
		tooltip.title = "Attacking"
		tooltip.text = "This enemy is attacking next turn"
		tooltip.title_image = intents.attack.get_path()
		tooltips.append(tooltip)
	elif state == "init":
		var tooltip = {}
		tooltip.title = "Buffing"
		tooltip.text = "This enemy is buffing"
		tooltip.title_image = intents.buff.get_path()
		tooltips.append(tooltip)
	elif state == "start":
		var tooltip = {}
		tooltip.title = "Contaminating"
		tooltip.text = "This enemy is making a special attack"
		tooltip.title_image = intents.debuff.get_path()
		tooltips.append(tooltip)
	elif state == "buff_reagent":
		var tooltip1 = {}
		tooltip1.title = "Buffing"
		tooltip1.text = "This enemy is getting stronger"
		tooltip1.title_image = intents.buff.get_path()
		tooltips.append(tooltip1)
		var tooltip2 = {}
		tooltip2.title = "Contaminating"
		tooltip2.text = "This enemy is making a special attack"
		tooltip2.title_image = intents.debuff.get_path()
		tooltips.append(tooltip2)
	
	
	return tooltips

