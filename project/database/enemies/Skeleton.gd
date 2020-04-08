extends Reference

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
