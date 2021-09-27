extends Reference

var image = "res://assets/images/enemies/self destructor/idle.png"
var name = "EN_SELF_DESTRUCTOR"
var sfx = "toxic_slime_minion"
var use_idle_sfx = false
var hp = 5
var battle_init = true
var size = "small"
var change_phase = null

var states = ["init","attack", "self_destruct"]
var connections = [
					  ["init", "attack", 1],
					  ["attack", "self_destruct", 1],
					  ["self_destruct", "self_destruct", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "shield", "value": 30},
		{"name": "status", "status_name": "tough", "value": 1, "target": "self", "positive": true}
	],
	"attack": [
		{"name": "damage", "value": [4,5], "amount": 2, "type": "regular"}
	],
	"self_destruct": [
		{"name": "self_destruct", "value": 30}
	]
}
