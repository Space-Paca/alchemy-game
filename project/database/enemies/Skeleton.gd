extends Reference

signal acted

var enemy_ref #Reference to enemy node
var player_ref #Reference to player node

var intents = {"attack": preload("res://assets/images/enemies/intents/attack.png"),
			   "defend": preload("res://assets/images/enemies/intents/defense.png"),
			  }
var image = "res://assets/images/enemies/skeleton/skeletonIDLE.png"
var name = "Skelly"
var hp = 30
var size = "small"
var damage = [10, 12]
var defense = [4, 6]

var states = ["attack", "defend"]
var connections = [
					  ["attack", "defend", 5],
					  ["attack", "attack", 5],
					  ["defend", "attack", 1],
				  ]
var first_state = ["attack", "defend"]

var next_value

func set_node_references(e_ref, p_ref):
	enemy_ref = e_ref
	player_ref = p_ref

func get_damage():
	randomize()
	return randi()%(damage[1]-damage[0]+1)+damage[0]

func get_defense():
	randomize()
	return randi()%(defense[1]-defense[0]+1)+defense[0]

func act(state):
	if state == "attack":
		emit_signal("acted", enemy_ref, "damage", {"value": next_value, "type": "pierce"})
	elif state == "defend":
		emit_signal("acted", enemy_ref, "shield", {"value": next_value, "target": enemy_ref})

func get_intent_data(state):
	var data = {}

	data.image = intents[state]
	
	next_value = null
	if state == "attack":
		next_value = get_damage()
	elif state == "defend":
		next_value = get_defense()
	data.value = next_value
	
	return data

func get_intent_tooltip(state):
	var tooltip = {}
	
	if state == "attack":
		tooltip.title = "Attacking"
		tooltip.text = "This enemy is attacking next turn"
	elif state == "defend":
		tooltip.title = "Defending"
		tooltip.text = "This enemy is going to defend next turn"
	
	return tooltip
