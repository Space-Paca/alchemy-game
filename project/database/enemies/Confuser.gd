extends Reference

var image = "res://assets/images/enemies/curser/idle.png"
var name = "Confuser"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 105
var battle_init = true
var size = "medium"

var states = ["init", "attack1", "attack2", "defend1", "defend2"]
var connections = [
					  ["init", "attack1", 1],
					  ["init", "attack2", 1],
					  ["attack1", "attack2", 1],
					  ["attack1", "defend2", 1],
					  ["defend1", "attack2", 1],
					  ["defend1", "defend2", 1],
					  ["attack2", "attack1", 1],
					  ["attack2", "defend1", 1],
					  ["defend2", "attack1", 1],
					  ["defend2", "defend1", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "confusion", "value": 1, "target": "player", "positive": false}
	],
	"attack1": [
		{"name": "damage", "value": [3, 5], "amount": 3, "type": "venom"}
	],
	"attack2": [
		{"name": "damage", "value": [5, 8], "amount": 2, "type": "venom"}
	],
	"defend1": [
		{"name": "shield", "value": [8, 20]},
	],
	"defend2": [
		{"name": "shield", "value": [4, 7]},
		{"name": "status", "status_name": "poison", "value": [2, 4], "target": "player", "positive": false}
	],
}
