extends Reference

var image = "res://assets/images/enemies/small regular enemy/idle.png"
var name = "Retaliate"
var sfx = "slime"
var use_idle_sfx = false
var hp = 20
var battle_init = true
var size = "small"

var states = ["init", "attack"]
var connections = [
					  ["init", "attack", 1],
					  ["attack", "attack", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "retaliate", "value": 3, "target": "self", "positive": true},
	],
	"attack": [
		{"name": "status", "status_name": "retaliate", "value": 3, "target": "self", "positive": true},
		{"name": "damage", "value": [5,8], "type": "regular"}
	]
}
