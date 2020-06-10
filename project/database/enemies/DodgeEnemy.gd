extends Reference

var image = "res://assets/images/enemies/homunculus/idle.png"
var name = "Dodge Enemy"
var sfx = "enemy_2"
var use_idle_sfx = false
var hp = 28
var battle_init = true
var size = "small"

var states = ["init", "dodge", "attack", "big_attack"]
var connections = [	      ["init", "big_attack", 1],
						  ["big_attack", "dodge", 1],
						  ["big_attack", "attack", 1],
						  ["dodge", "attack", 6],
						  ["dodge", "dodge", 4],
						  ["dodge", "big_attack", 1],
						  ["attack", "dodge", 5],
						  ["attack", "attack", 5],
						  ["attack", "big_attack", 1],
				 ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "dodge", "value": 1, "target": "self", "positive": true}
	],
	"dodge": [
		{"name": "status", "status_name": "dodge", "value": 2, "target": "self", "positive": true}
	],
	"attack": [
		{"name": "status", "status_name": "dodge", "value": 1, "target": "self", "positive": true},
		{"name": "damage", "value": [5, 7], "type": "regular"},
	],
	"big_attack": [
		{"name": "damage", "value": [7, 9], "type": "regular"},
	],
}
