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
var hp = 80
var battle_init = true
var size = "big"
var damage = [2, 4]
var dodge = 2
var buff = 3

var states = ["init", "start", "attack"]
var connections = [
					  ["init", "start", 1],
					  ["start", "attack", 1],
	
				  ]
var first_state = ["init"]

var next_attack_value

func set_node_references(e_ref, p_ref):
	enemy_ref = e_ref
	player_ref = p_ref

func get_damage():
	randomize()
	return randi()%(damage[1]-damage[0]+1)+damage[0]

func act(state):
	if state == "init":
		emit_signal("acted", enemy_ref, [["status", {"status": "guard_up", "amount": 2, "target": enemy_ref, "positive": true}]])
	elif state == "start":
		emit_signal("acted", enemy_ref, [["add_reagent", {"type": "trash", "amount": 5}]])
	elif state == "attack":
		emit_signal("acted", enemy_ref, [["damage", {"value": next_attack_value, "type": "regular"}]])

func get_intent_data(state):
	var data = []

	if state == "attack":
		next_attack_value = get_damage()
		var intent = {}
		intent.image = intents.attack
		intent.value = next_attack_value + enemy_ref.get_damage_modifiers(false)
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


	return data

func get_intent_tooltips(state):
	var tooltips = []
	
	if state == "attack":
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
	
	return tooltips

