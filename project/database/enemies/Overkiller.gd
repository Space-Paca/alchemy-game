extends Reference

var image = "res://assets/images/enemies/self destructor/idle.png"
var name = "Overkiller"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 28
var battle_init = true
var size = "small"

var states = ["init", "attack1", "defend", "attack2", "buff"]
var connections = [
					  ["init", "attack1", 1],
					  ["init", "attack2", 1],
					  ["init", "defend", 1],
					  ["attack1", "defend", 4],
					  ["attack1", "attack1", 6],
					  ["attack1", "attack2", 4],
					  ["attack1", "buff", 2],
					  ["attack2", "defend", 4],
					  ["attack2", "attack1", 6],
					  ["attack2", "attack2", 4],
					  ["attack2", "buff", 2],
					  ["defend", "attack1", 4],
					  ["defend", "attack2", 4],
					  ["defend", "attack2", 2],
					  ["defend", "buff", 1],
					  ["buff", "buff", 1],
					  ["buff", "attack1", 4],
					  ["buff", "attack2", 4],
					  ["buff", "defend", 2],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "overkill", "value": 1, "target": "self", "positive": true}
	],
	"attack1": [
		{"name": "damage", "value": [4, 5], "type": "regular"}
	],
	"attack2": [
		{"name": "damage", "value": [2, 8], "type": "regular"}
	],
	"defend": [
		{"name": "shield", "value": [2, 10]},
	],
	"buff": [
		{"name": "status", "status_name": "temp_strength", "value": 5, "target": "self", "positive": true}
	],
}
