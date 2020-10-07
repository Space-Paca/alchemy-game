extends Reference

var image = "res://assets/images/enemies/boss2/idle.png"
var name = "Boss3 Phase1"
var sfx = "boss_1"
var use_idle_sfx = false
var hp = 200
var battle_init = false
var size = "big"

var states = ["start", "attack1", "attack2", "attack3", "attack4", "attack5-1", \
			  "attack5-2", "buff1", "buff2", "buff3", "buff3", "buff4", "buff5"]
var connections = [
					  ["start", "buff1", 1],
					  ["buff1", "attack1", 1],
					  ["attack1", "buff2", 1],
					  ["buff2", "attack2", 1],
					  ["attack2", "buff3", 1],
					  ["buff3", "attack3", 1],
					  ["attack3", "buff4", 1],
					  ["buff4", "attack5-1", 1],
					  ["attack5-1", "buff5", 1],
					  ["attack5-2", "buff5", 1],
					  ["buff5", "attack5-1", 1],
					  ["buff5", "attack5-2", 1],



				  ]
var first_state = ["start"]

var actions = {
	"start": [
		{"name": "damage", "value": [20,21], "type": "regular"},
		{"name": "shield", "value": [25,40], "type": "regular"},
	],
	"buff1": [
		{"name": "status", "status_name": "stagger", "value": 10, "target": "self", "positive": false},
	],
	"attack1": [
		{"name": "damage", "value": [6,10], "amount":2, "type": "regular"},
		{"name": "shield", "value": [25,40], "type": "regular"},
	],
	"buff2": [
		{"name": "status", "status_name": "stagger", "value": 20, "target": "self", "positive": false},
	],
	"attack2": [
		{"name": "damage", "value": [8,12], "amount":2, "type": "regular"},
		{"name": "shield", "value": [25,40], "type": "regular"},
	],
	"buff3": [
		{"name": "status", "status_name": "stagger", "value": 25, "target": "self", "positive": false},
	],
	"attack3": [
		{"name": "damage", "value": [10,15], "amount":3, "type": "regular"},
		{"name": "shield", "value": [25,40], "type": "regular"},
	],
	"buff4": [
		{"name": "status", "status_name": "stagger", "value": 30, "target": "self", "positive": false},
	],
	"attack4": [
		{"name": "damage", "value": [16,20], "amount":3, "type": "regular"},
		{"name": "shield", "value": [25,40], "type": "regular"},
	],
	"buff5": [
		{"name": "status", "status_name": "stagger", "value": 35, "target": "self", "positive": false},
	],
	"attack5-1": [
		{"name": "damage", "value": 55, "type": "regular"},
		{"name": "shield", "value": [25,40], "type": "regular"},
	],
	"attack5-2": [
		{"name": "damage", "value": [19,20], "amount":3, "type": "regular"},
		{"name": "shield", "value": [25,40], "type": "regular"},
	],
	
}
