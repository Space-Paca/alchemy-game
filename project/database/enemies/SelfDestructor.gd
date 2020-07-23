extends Reference

var image = "res://assets/images/enemies/small piercing/idle.png"
var name = "Self Destructor"
var sfx = "toxic_slime_minion"
var use_idle_sfx = false
var hp = 2
var battle_init = true
var size = "small"

var states = ["init","attack", "self_destruct"]
var connections = [
					  ["init", "attack", 1],
					  ["attack", "self_destruct", 1],
					  ["self_destruct", "self_destruct", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "shield", "value": 12},
		{"name": "status", "status_name": "tough", "value": 0, "target": "self", "positive": true}
	],
	"attack": [
		{"name": "damage", "value": [2,3], "type": "regular"}
	],
	"self_destruct": [
		{"name": "self_destruct", "value": 15}
	]
}
