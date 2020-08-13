extends Reference

var image = "res://assets/images/enemies/revenger/idle.png"
var name = "Martyr"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 35
var battle_init = true
var size = "small"

var states = ["init", "attack1", "defend", "attack2"]
var connections = [
					  ["init", "attack1", 1],
					  ["init", "attack2", 1],
					  ["init", "defend", 1],
					  ["attack1", "defend", 2],
					  ["attack1", "attack1", 3],
					  ["attack1", "attack2", 1],
					  ["attack2", "defend", 2],
					  ["attack2", "attack1", 3],
					  ["attack2", "attack2", 1],
					  ["defend", "attack1", 2],
					  ["defend", "attack2", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "martyr", "value": 5, "target": "self", "positive": true}
	],
	"attack1": [
		{"name": "damage", "value": [8, 15], "type": "regular"}
	],
	"attack2": [
		{"name": "damage", "value": [5, 8], "amount": 2, "type": "regular"}
	],
	"defend": [
		{"name": "shield", "value": [8, 14]},
	],
}
