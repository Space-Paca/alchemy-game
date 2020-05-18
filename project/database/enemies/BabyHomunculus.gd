extends Reference

signal acted

var enemy_ref #Reference to enemy node
var player_ref #Reference to player node

var intents = {"attack": preload("res://assets/images/enemies/intents/attack_normal.png"),
			   "defend": preload("res://assets/images/enemies/intents/blocking.png"),
			  }
var image = "res://assets/images/enemies/homunculus/idle.png"
var name = "Baby Humunculus"
var sfx = "enemy_1"
var hp = 15
var battle_init = false
var size = "small"
var damage = [5, 7]

var states = ["attack"]
var connections = [
					  ["attack", "attack", 1],
				  ]
var first_state = ["attack"]

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
	
func get_intent_data(state):
	var data = []

	if state == "attack":
		next_attack_value = get_damage()
		var intent = {}
		intent.image = intents.attack
		intent.value = next_attack_value
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
	
	return tooltips
	
