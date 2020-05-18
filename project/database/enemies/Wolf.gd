extends Reference

signal acted

var enemy_ref #Reference to enemy node
var player_ref #Reference to player node

var intents = {"attack": preload("res://assets/images/enemies/intents/attack_normal.png"),
				"dodge": preload("res://assets/images/enemies/intents/buffing.png"),
			   }
var image = "res://assets/images/enemies/wolf/wolfIDLE.png"
var name = "Good Boy"
var sfx = "enemy_2"
var hp = 50
var battle_init = false
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
		emit_signal("acted", enemy_ref, [["damage", {"value": next_value, "type": "pierce"}]])
	elif state == "dodge":
		emit_signal("acted", enemy_ref, [["status", {"status": "dodge", "amount": 1, "target": enemy_ref, "positive": true}]])

func get_intent_data(state):
	var data = []
	var intent = {}
	
	intent.image = intents[state]
	
	if state == "attack":
		next_value = get_damage()
		intent.value = next_value
	elif state == "dodge":
		intent.value = 1
	data.append(intent)
	
	return data

func get_intent_tooltips(state):
	var tooltips = []
	var tooltip = {}
	
	if state == "attack":
		tooltip.title = "Attacking"
		tooltip.text = "This enemy is attacking next turn"
		tooltip.title_image = intents.attack.get_path()
	elif state == "dodge":
		tooltip.title = "Dodging"
		tooltip.text = "This enemy is getting dodge next turn"
		tooltip.title_image = intents.dodge.get_path()
	tooltips.append(tooltip)
	
	return tooltips
