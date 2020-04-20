extends Reference

signal acted

var enemy_ref #Reference to enemy node
var player_ref #Reference to player node

var intents = {"attack": preload("res://assets/images/enemies/intents/attack.png"),
				"dodge": preload("res://assets/images/enemies/intents/dodge.png"),
			   }
var image = "res://assets/images/enemies/wolf/wolfIDLE.png"
var name = "Good Boy"
var hp = 50
var size = "medium"
var damage = [4, 5]

var states = ["dodge", "attack"]
var connections = [	      ["dodge", "attack", 1],
						  ["dodge", "attack", 2],
						  ["attack", "dodge", 1],
				 ]
var first_state = ["dodge"]

var next_value

func set_node_references(e_ref, p_ref):
	enemy_ref = e_ref
	player_ref = p_ref

func get_damage():
	randomize()
	return randi()%(damage[1]-damage[0]+1)+damage[0]


func act(state):
	if state == "attack":
		emit_signal("acted", "damage", {"value": next_value, "type": "phantom"})
	elif state == "dodge":
		emit_signal("acted", "status", {"status": "dodge", "amount": 1, "target": enemy_ref, "positive": false})

func get_intent_data(state):
	var data = {}

	data.image = intents[state]
	
	next_value = null
	if state == "attack":
		next_value = get_damage()
		data.value = next_value
	elif state == "dodge":
		data.value = 1
	
	return data
