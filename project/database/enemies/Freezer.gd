extends Reference

var image = "res://assets/images/enemies/freezer/idle.png"
var name = "Giant Everfrozen Craggium"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 50
var battle_init = true
var size = "medium"
var change_phase = null

var states = ["init", "attack", "attack2", "freeze", "spawn", "buff"]
var connections = [   
					  ["init", "attack", 1],
					  ["attack", "spawn", 5],
					  ["attack", "attack2", 3],
					  ["attack", "freeze", 3],
					  ["attack2", "spawn", 4],
					  ["attack2", "freeze", 3],
					  ["spawn", "attack", 3],
					  ["spawn", "attack2", 2],
					  ["freeze", "attack", 3],
					  ["freeze", "attack2", 2],
					  ["freeze", "spawn", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "shield", "value": 150},
		{"name": "status", "status_name": "tough", "value": 0, "target": "self", "positive": true},
		{"name": "status", "status_name": "freeze", "value": 2, "target": "player", "positive": false},
	],
	"attack": [
		{"name": "damage", "value": [15, 25], "type": "regular"}
	],
	"attack2": [
		{"name": "damage", "value": 5, "amount": 3, "type": "regular"},
		{"name": "status", "status_name": "freeze", "value": 4, "target": "player", "positive": false},
	],
	"freeze": [
		{"name": "status", "status_name": "freeze", "value": 4, "target": "player", "positive": false},
		{"name": "shield", "value": [5,10]},
		{"name": "status", "status_name": "perm_strength", "value": 2, "target": "self", "positive": true},
	],
	"spawn": [
		{"name": "status", "status_name": "freeze", "value": 3, "target": "player", "positive": false},
		{"name": "spawn", "enemy": "self_destructor"},
		{"name": "status", "status_name": "perm_strength", "value": 6, "target": "self", "positive": true},
	],
}
