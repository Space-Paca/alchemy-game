extends Reference

var image = "res://assets/images/enemies/boss2/idle.png"
var name = "Boss3 Phase2"
var sfx = "boss_1"
var use_idle_sfx = false
var hp = 300
var battle_init = true
var size = "big"
var change_phase = null

var states = ["init", "start", "attack1", "attack2", "attack3", "attack4", \
			  "debuff1", "debuff2", "debuff3", "debuff3", "debuff4", "debuff5"]
var connections = [
					  ["init", "start", 1],  
					  ["start", "attack1", 1],
					  ["start", "attack2", 1],
					  ["start", "attack3", 1],
					
					  ["attack1", "buff1", 1],
					  ["attack1", "buff2", 1],
					  ["attack1", "buff3", 1],
					  ["attack1", "buff4", 1],
					  ["attack1", "buff5", 1],
					
					  ["attack2", "buff1", 1],
					  ["attack2", "buff2", 1],
					  ["attack2", "buff3", 1],
					  ["attack2", "buff4", 1],
					  ["attack2", "buff5", 1],
					
					  ["attack3", "buff1", 1],
					  ["attack3", "buff2", 1],
					  ["attack3", "buff3", 1],
					  ["attack3", "buff4", 1],
					  ["attack3", "buff5", 1],
					
					  ["attack4", "buff1", 1],
					  ["attack4", "buff2", 1],
					  ["attack4", "buff3", 1],
					  ["attack4", "buff4", 1],
					  ["attack4", "buff5", 1],
					
					  ["buff1", "attack1", 1],
					  ["buff1", "attack2", 1],
					  ["buff1", "attack3", 1],
					  ["buff1", "attack4", 1],
					  
					  ["buff2", "attack1", 1],
					  ["buff2", "attack2", 1],
					  ["buff2", "attack3", 1],
					  ["buff2", "attack4", 1],
					
					  ["buff3", "attack1", 1],
					  ["buff3", "attack2", 1],
					  ["buff3", "attack3", 1],
					  ["buff3", "attack4", 1],
					
					  ["buff4", "attack1", 1],
					  ["buff4", "attack2", 1],
					  ["buff4", "attack3", 1],
					  ["buff4", "attack4", 1],
					
					  ["buff5", "attack1", 1],
					  ["buff5", "attack2", 1],
					  ["buff5", "attack3", 1],
					  ["buff5", "attack4", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "shield", "value": 100, "type": "regular"},
	],
	"start": [
		{"name": "status", "status_name": "deviation", "value": 1, "target": "player", "positive": false},
		{"name": "status", "status_name": "divine_protection", "value": 60, "target": "self", "positive": true},
	],
	"attack1": [
		{"name": "damage", "value": 20, "amount":2, "type": "regular"},
		{"name": "shield", "value": [15,25], "type": "regular"},
	],
	"attack2": [
		{"name": "damage", "value": [12,13], "amount":3, "type": "regular"},
		{"name": "shield", "value": [15,25], "type": "regular"},
	],
	"attack3": [
		{"name": "damage", "value": 45, "type": "regular"},
		{"name": "shield", "value": [15,25], "type": "regular"},
	],
	"attack4": [
		{"name": "drain", "value": 30},
		{"name": "shield", "value": [15,25], "type": "regular"},
	],
	"debuff1": [
		{"name": "status", "status_name": "burning", "value": 12, "target": "player", "positive": false},
		{"name": "status", "status_name": "perm_strength", "value": 1, "target": "self", "positive": true}
	],
	"debuff2": [
		{"name": "status", "status_name": "freeze", "value": 5, "target": "player", "positive": false},
		{"name": "status", "status_name": "perm_strength", "value": 1, "target": "self", "positive": true}
	],
	"debuff3": [
		{"name": "status", "status_name": "time_bomb", "value": 12, "target": "player", "positive": false},
		{"name": "status", "status_name": "perm_strength", "value": 1, "target": "self", "positive": true}
	],
	"debuff4": [
		{"name": "status", "status_name": "weakness", "value": 2, "target": "player", "positive": false},
		{"name": "status", "status_name": "perm_strength", "value": 1, "target": "self", "positive": true}
	],
	"debuff5": [
		{"name": "status", "status_name": "perm_strength", "value": 4, "target": "self", "positive": true}
	],
	
}
