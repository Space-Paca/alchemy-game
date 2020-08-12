extends Reference

var image = "res://assets/images/enemies/revenger/idle.png"
var name = "Martyr"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 25
var battle_init = true
var size = "small"

var states = ["init", "attack", "defend"]
var connections = [
					  ["init", "attack", 1],
					  ["init", "defend", 1],
					  ["attack", "defend", 1],
					  ["attack", "attack", 2],
					  ["defend", "attack", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "martyr", "value": 5, "target": "self", "positive": true}
	],
	"attack": [
		{"name": "damage", "value": [9, 10], "type": "regular"}
	],
	"defend": [
		{"name": "shield", "value": [6, 8]},
	],
}
