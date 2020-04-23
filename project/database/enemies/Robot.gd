extends Reference

signal acted

const TEMP_BUFF = 10
const PERM_BUFF = 5

var enemy_ref #Reference to enemy node
var player_ref #Reference to player node

var intents = {"attack": preload("res://assets/images/enemies/intents/attack.png"),
			   "temp_buff": preload("res://assets/images/enemies/intents/temp_strength.png"),
			   "perm_buff": preload("res://assets/images/enemies/intents/perm_strength.png"),
			   }
var image = "res://assets/images/enemies/robot/robotIDLE.png"
var name = "BeepBoop"
var hp = 50
var size = "big"
var damage = [3, 5]
var temp_buff = 0
var perm_buff = 0

var states = ["temp_buff", "perm_buff", "attack"]
var connections = [["temp_buff", "attack", 1],
				   ["attack", "perm_buff", 1],
				   ["perm_buff", "temp_buff", 1],
				   ["perm_buff", "attack", 2],
						 ]
var first_state = ["temp_buff"]

var next_value

func set_node_references(e_ref, p_ref):
	enemy_ref = e_ref
	player_ref = p_ref

func get_damage():
	randomize()
	return randi()%(damage[1]-damage[0]+1)+damage[0]

func act(state):
	if state == "attack":
		emit_signal("acted", enemy_ref, "damage", {"value": next_value, "type": "regular"})
	elif state == "temp_buff":
		emit_signal("acted", enemy_ref, "status", {"status": "temp_strength", "amount": TEMP_BUFF, "target": enemy_ref, "positive": true})
	elif state == "perm_buff":
		emit_signal("acted", enemy_ref, "status", {"status": "perm_strength", "amount": PERM_BUFF, "target": enemy_ref, "positive": true})

func get_intent_data(state):
	var data = {}

	data.image = intents[state]
	
	next_value = null
	if state == "attack":
		next_value = get_damage()
		data.value = next_value + temp_buff + perm_buff
		temp_buff = 0
	elif state == "temp_buff":
		data.value = TEMP_BUFF
		temp_buff = TEMP_BUFF
	elif state == "perm_buff":
		data.value = PERM_BUFF
		perm_buff += PERM_BUFF
	
	return data

func get_intent_tooltip(state):
	var tooltip = {}
	
	if state == "attack":
		tooltip.title = "Attacking"
		tooltip.text = "This enemy is attacking next turn"
	elif state == "temp_buff":
		tooltip.title = "Temporary Buff"
		tooltip.text = "This enemy is buffing his next attack"
	elif state == "perm_buff":
		tooltip.title = "Getting Strong"
		tooltip.text = "This enemy is getting a permanent attack buff"
	
	return tooltip
