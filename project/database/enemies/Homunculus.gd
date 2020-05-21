extends Reference

signal acted

var enemy_ref #Reference to enemy node
var player_ref #Reference to player node

var intents = {"attack": preload("res://assets/images/enemies/intents/attack_normal.png"),
			   "defend": preload("res://assets/images/enemies/intents/blocking.png"),
			  }
var image = "res://assets/images/enemies/homunculus/idle.png"
var name = "Humunculus"
var sfx = "slime"
var use_idle_sfx = true
var hp = 50
var battle_init = false
var size = "medium"
var damage = [10, 15]
var small_damage = [5, 7]
var defense = [4, 6]

var states = ["attack", "defend"]
var connections = [
					  ["attack", "defend", 5],
					  ["attack", "attack", 5],
					  ["defend", "attack", 1],
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

func get_small_damage():
	randomize()
	return randi()%(small_damage[1]-small_damage[0]+1)+small_damage[0]

func get_defense():
	randomize()
	return randi()%(defense[1]-defense[0]+1)+defense[0]

func act(state):
	if state == "attack":
		emit_signal("acted", enemy_ref, [["damage", {"value": next_attack_value, "type": "regular"}]])
	elif state == "defend":
		emit_signal("acted", enemy_ref, [["shield", {"value": next_defend_value}], \
										 ["damage", {"value": next_attack_value, "type": "regular"}]])

func get_intent_data(state):
	var data = []

	if state == "attack":
		next_attack_value = get_damage()/2
		var intent = {}
		intent.image = intents.attack
		intent.value = next_attack_value
		data.append(intent)
	elif state == "defend":
		var intent1 = {}
		next_defend_value = get_defense()
		intent1.image = intents.defend
		intent1.value = next_defend_value
		data.append(intent1)
		var intent2 = {}
		next_attack_value = get_small_damage()
		intent2.image = intents.attack
		intent2.value = next_attack_value
		data.append(intent2)

	
	return data

func get_intent_tooltips(state):
	var tooltips = []
	
	if state == "attack":
		var tooltip = {}
		tooltip.title = "Attacking"
		tooltip.text = "This enemy is attacking next turn"
		tooltip.title_image = intents.attack.get_path()
		tooltips.append(tooltip)
	elif state == "defend":
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
	
	return tooltips

