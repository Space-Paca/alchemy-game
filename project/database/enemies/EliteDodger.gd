extends Reference

var image = "res://assets/images/enemies/elite dodger/idle.png"
var name = "EN_ELITE_DODGER"
var sfx = "eye_crab"
var use_idle_sfx = true
var hp = 45
var battle_init = true
var size = "medium"
var change_phase = null

var states = ["attack1", "buff1", "attack2", "buff2", "spawn"]
var connections = [
					  ["attack1", "attack2", 1],
					  ["attack1", "buff2", 2],
					  ["buff1", "attack2", 2],
					  ["buff1", "buff2", 1],
					  ["attack2", "spawn", 1],
					  ["buff2", "spawn", 1],
					  ["spawn", "attack1", 1],
					  ["spawn", "buff1", 1],
				  ]
var first_state = ["spawn"]

var actions = {
	"attack1": [
		{"name": "status", "status_name": "dodge", "value": 2, "target": "self", "positive": true},
		{"name": "damage", "value": [2, 4], "type": "regular"},
	],
	"attack2": [
		{"name": "status", "status_name": "dodge", "value": 1, "target": "self", "positive": true},
		{"name": "damage", "value": [2, 4], "type": "regular"},
	],
	"buff1": [
		{"name": "status", "status_name": "dodge", "value": 2, "target": "self", "positive": true},
		{"name": "status", "status_name": "perm_strength", "value": 3, "target": "self", "positive": true}
	],
	"buff2": [
		{"name": "status", "status_name": "dodge", "value": 1, "target": "self", "positive": true},
		{"name": "status", "status_name": "perm_strength", "value": 3, "target": "self", "positive": true}
	],
	"spawn": [
		{"name": "status", "status_name": "dodge", "value": 2, "target": "self", "positive": true},
		{"name": "spawn", "enemy": "baby_slasher"},
		{"name": "spawn", "enemy": "baby_slasher"},
	],
}
