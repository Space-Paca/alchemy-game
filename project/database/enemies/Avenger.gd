extends Reference

var image = "res://assets/images/enemies/avenger/idle.png"
var name = "EN_AVENGER"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 125
var battle_init = true
var size = "small"
var change_phase = null

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
		{"name": "status", "status_name": "avenge", "value": 20, "target": "self", "positive": true}
	],
	"attack1": [
		{"name": "damage", "value": [30, 35], "type": "regular"}
	],
	"attack2": [
		{"name": "damage", "value": [14, 20], "amount": 2, "type": "regular"}
	],
	"defend": [
		{"name": "shield", "value": [10, 25]},
	],
}
