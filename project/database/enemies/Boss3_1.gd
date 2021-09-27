extends Reference

var image = "res://assets/images/enemies/boss3-1/idle.png"
var name = "EN_BOSS_3_1"
var sfx = "boss_1"
var use_idle_sfx = false
var hp = 600
var battle_init = false
var size = "big"
var change_phase = "boss_3_2"

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
		{"name": "damage", "value": 80, "type": "regular"},
		{"name": "shield", "value": [50,70], "type": "regular"},
	],
	"buff1": [
		{"name": "status", "status_name": "concentration", "value": 30, "target": "self", "positive": false},
	],
	"attack1": [
		{"name": "damage", "value": [28,30], "amount":2, "type": "regular"},
		{"name": "shield", "value": [50,70], "type": "regular"},
	],
	"buff2": [
		{"name": "status", "status_name": "concentration", "value": 40, "target": "self", "positive": false},
	],
	"attack2": [
		{"name": "damage", "value": [28,30], "amount":2, "type": "regular"},
		{"name": "shield", "value": [50,70], "type": "regular"},
	],
	"buff3": [
		{"name": "status", "status_name": "concentration", "value": 50, "target": "self", "positive": false},
	],
	"attack3": [
		{"name": "damage", "value": [38,40], "amount":3, "type": "regular"},
		{"name": "shield", "value": [50,70], "type": "regular"},
	],
	"buff4": [
		{"name": "status", "status_name": "concentration", "value": 60, "target": "self", "positive": false},
	],
	"attack4": [
		{"name": "damage", "value": [38,40], "amount":3, "type": "regular"},
		{"name": "shield", "value": [50,70], "type": "regular"},
	],
	"buff5": [
		{"name": "status", "status_name": "concentration", "value": 70, "target": "self", "positive": false},
		{"name": "status", "status_name": "perm_strength", "value": 10, "target": "self", "positive": true},
	],
	"attack5-1": [
		{"name": "damage", "value": 100, "type": "regular"},
		{"name": "shield", "value": 70, "type": "regular"},
	],
	"attack5-2": [
		{"name": "damage", "value": [28,30], "amount":3, "type": "regular"},
		{"name": "shield", "value": 70, "type": "regular"},
	],
	
}
