extends Reference

signal acted

export var image = "res://assets/images/enemies/skeleton/skeletonIDLE.png"
export var name = "Skelly"
export var hp = 10
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

func get_damage():
	randomize()
	return randi()%(damage[1]-damage[0]+1)+damage[0]

func get_defense():
	randomize()
	return randi()%(defense[1]-defense[0]+1)+defense[0]

func act(state):
	print(state)
	if state == "attack":
		emit_signal("acted", "damage", {"value": get_damage()})
	elif state == "defend":
		emit_signal("acted", "shield", {"value":get_defense()})
	elif state == "random":
		emit_signal("acted", "damage", {"value":get_damage() + 2})


