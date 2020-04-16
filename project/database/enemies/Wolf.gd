extends SampleEnemyData

signal acted

export var intents = {"attack": preload("res://assets/images/enemies/intents/attack.png"),
					  "defend": preload("res://assets/images/enemies/intents/defense.png"),
					  "random": preload("res://assets/images/enemies/intents/random.png"),
					 }
export var image = "res://assets/images/enemies/wolf/wolfIDLE.png"
export var name = "Good Boy"
export var hp = 50
export var damage = [10, 12]
export var defense = [4, 6]

export var states = ["attack", "defend", "random"]
export var connections = [["random", "attack", 1],
						  ["random", "defend", 2],
						  ["attack", "defend", 5],
						  ["attack", "attack", 5],
						  ["defend", "attack", 1]
						 ]
export var first_state = ["random", "random", "attack"]

var next_value

func get_damage():
	randomize()
	return randi()%(damage[1]-damage[0]+1)+damage[0]

func get_defense():
	randomize()
	return randi()%(defense[1]-defense[0]+1)+defense[0]

func act(state):
	if state == "attack":
		emit_signal("acted", "damage", {"value": next_value})
	elif state == "defend":
		emit_signal("acted", "shield", {"value": next_value, "target": enemy_ref})
	elif state == "random":
		randomize()
		if randf() > .5:
			emit_signal("acted", "damage", {"value": get_damage() + 2})
		else:
			emit_signal("acted", "shield", {"value": get_defense() + 2, "target": enemy_ref})

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
