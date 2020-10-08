extends Reference

var image = "res://assets/images/enemies/small divider/idle.png"
var name = "Zombie"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 15
var battle_init = true
var size = "small"
var change_phase = null

var states = ["init", "drain", "attack"]
var connections = [
					  ["init", "attack", 1],
					  ["init", "drain", 1],
					  ["attack", "attack", 2],
					  ["attack", "drain", 1],
					  ["drain", "attack", 3],
					  ["drain", "drain", 1],
					  
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "poison_immunity", "value": 1, "target": "self", "positive": true}
	],
	"drain": [
		{"name": "drain", "value": [6, 10]}
	],
	"attack": [
		{"name": "damage", "value": [8,12], "type": "regular"}
	],
}
