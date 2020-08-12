extends Reference

var image = "res://assets/images/enemies/freezer/idle.png"
var name = "Freezer"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 30
var battle_init = true
var size = "medium"

var states = ["init", "attack", "attack2", "freeze", "spawn", "buff"]
var connections = [   
					  ["init", "attack", 1],
					  ["attack", "spawn", 4],
					  ["attack", "attack2", 2],
					  ["attack", "freeze", 3],
					  ["attack2", "spawn", 4],
					  ["attack2", "freeze", 3],
					  ["spawn", "attack", 3],
					  ["spawn", "buff", 1],
					  ["freeze", "attack", 3],
					  ["freeze", "buff", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "shield", "value": 80},
		{"name": "status", "status_name": "tough", "value": 0, "target": "self", "positive": true},
		{"name": "status", "status_name": "freeze", "value": 2, "target": "player", "positive": false},
	],
	"attack": [
		{"name": "damage", "value": [10, 12], "type": "regular"}
	],
	"attack2": [
		{"name": "damage", "value": 4, "amount": 3, "type": "regular"}
	],
	"freeze": [
		{"name": "status", "status_name": "freeze", "value": 4, "target": "player", "positive": false},
	],
	"spawn": [
		{"name": "status", "status_name": "freeze", "value": 3, "target": "player", "positive": false},
		{"name": "spawn", "enemy": "self_destructor"},
	],
	"buff": [
		{"name": "status", "status_name": "freeze", "value": 2, "target": "player", "positive": false},
		{"name": "status", "status_name": "perm_strength", "value": 2, "target": "self", "positive": true},
	],
}
