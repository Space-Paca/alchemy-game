extends Reference

signal acted

var enemy_ref #Reference to enemy node
var player_ref #Reference to player node

var intents = {"attack": preload("res://assets/images/enemies/intents/attack_normal.png"),
			   "preparing": preload("res://assets/images/enemies/intents/random.png")}

var image = "res://assets/images/enemies/homunculus/idle.png"
var name = "Delayed hitter"
var sfx = "slime"
var use_idle_sfx = true
var hp = 22
var battle_init = false
var size = "small"
var damage = [16, 18]

var states = ["attack", "preparing1", "preparing2", "preparing3"]
var connections = [
					  ["preparing1", "preparing2", 1],
					  ["preparing2", "preparing3", 1],
					  ["preparing3", "attack", 1],
					  ["attack", "attack", 1],
				  ]
var first_state = ["preparing1"]

var next_attack_value

func set_node_references(e_ref, p_ref):
	enemy_ref = e_ref
	player_ref = p_ref

func get_damage():
	randomize()
	return randi()%(damage[1]-damage[0]+1)+damage[0]

func act(state):
	if state == "attack":
		emit_signal("acted", enemy_ref, [["damage", {"value": next_attack_value, "type": "regular"}]])
	elif state == "preparing1" or state == "preparing2" or state == "preparing3":
		emit_signal("acted", enemy_ref, [["idle", {}]])
	
func get_intent_data(state):
	var data = []

	if state == "attack":
		next_attack_value = get_damage()
		var intent = {}
		intent.image = intents.attack
		intent.value = next_attack_value
		data.append(intent)
	elif state == "preparing1" or state == "preparing2" or state == "preparing3":
		var intent = {}
		intent.image = intents.preparing
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
	elif state == "preparing1" or state == "preparing2" or state == "preparing3":
		var tooltip = {}
		tooltip.title = "Preparing"
		tooltip.text = "This enemy is preparing something"
		tooltip.title_image = intents.attack.get_path()
		tooltips.append(tooltip)
	
	return tooltips
	
