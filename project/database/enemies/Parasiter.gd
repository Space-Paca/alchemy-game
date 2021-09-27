extends Reference

var image = "res://assets/images/enemies/parasiter/idle.png"
var name = "EN_PARASITER"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 125
var battle_init = true
var size = "medium"
var change_phase = null

var states = ["init", "drain", "attack"]
var connections = [
					  ["init", "attack", 1],
					  ["init", "drain", 1],
					  ["attack", "attack", 1],
					  ["attack", "drain", 2],
					  ["drain", "attack", 3],
					  ["drain", "drain", 1],
					  
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "hex", "value": 2, "target": "self", "positive": true}
	],
	"drain": [
		{"name": "drain", "value": [15, 22]}
	],
	"attack": [
		{"name": "damage", "value": [5,8], "amount": [2,4], "type": "regular"}
	],
}
