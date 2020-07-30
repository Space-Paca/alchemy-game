extends Reference

var intents = {"attack": preload("res://assets/images/enemies/intents/attack_normal.png"),
			   "crushing": preload("res://assets/images/enemies/intents/attack_normal.png"),
			   "buff": preload("res://assets/images/enemies/intents/buffing.png"),
			   "debuff": preload("res://assets/images/enemies/intents/debuffing.png"),
			   "dodge": preload("res://assets/images/enemies/intents/buffing.png"),
			   "spawn": preload("res://assets/images/enemies/intents/summoning.png"),
			   "special": preload("res://assets/images/enemies/intents/random.png"),
			  }
var image = "res://assets/images/enemies/boss1/idle.png"
var name = "Boss2"
var sfx = "boss_1"
var use_idle_sfx = false
var hp = 120
var battle_init = true
var size = "big"

var states = ["start", "attack1", "attack2", "attack3", "attack4", "attack5", \
			  "restrict_buff", "spawn1", "spawn2", "spawn3"]
var connections = [
					  ["start", "attack1", 1],
					  ["attack1", "attack2", 1],
					  ["attack2", "attack3", 1],
					  ["attack3", "attack4", 1],
					  ["attack4", "attack5", 1],
					  ["attack5", "restrict_buff", 1],
					  ["restrict_buff", "spawn1", 1],
					  ["restrict_buff", "spawn2", 1],
					  ["restrict_buff", "spawn3", 1],
					  ["spawn1", "attack1", 1],
					  ["spawn2", "attack1", 1],
					  ["spawn3", "attack1", 1],
	
				  ]
var first_state = ["start"]

var actions = {
	"start": [
		{"name": "status", "status_name": "restrict_minor", "value": 1, "target": "player", "positive": false}
	],
	"attack1": [
		{"name": "damage", "value": [12,15], "type": "regular"},
	],
	"attack2": [
		{"name": "status", "status_name": "restrict_minor", "value": 1, "target": "player", "positive": false},
		{"name": "damage", "value": [3,4], "type": "regular", "amount": 2},
	],
	"attack3": [
		{"name": "status", "status_name": "restrict_minor", "value": 1, "target": "player", "positive": false},
		{"name": "damage", "value": [3,4], "type": "regular", "amount": 3},
	],
	"attack4": [
		{"name": "damage", "value": [3,4], "type": "regular", "amount": 4},
	],
	"attack5": [
		{"name": "damage", "value": [3,4], "type": "regular", "amount": 5},
	],
	"restrict_buff": [
		{"name": "status", "status_name": "restrict_major", "value": 1, "target": "player", "positive": false},
		{"name": "status", "status_name": "perm_strength", "value": 1, "target": "self", "positive": true},
	],
	"spawn1": [
		{"name": "status", "status_name": "restrict_minor", "value": 2, "target": "player", "positive": false},
		{"name": "spawn", "enemy": "baby_poison", "minion": true},
	],
	"spawn2": [
		{"name": "status", "status_name": "restrict_minor", "value": 2, "target": "player", "positive": false},
		{"name": "spawn", "enemy": "baby_humunculus", "minion": true},
	],
	"spawn3": [
		{"name": "status", "status_name": "restrict_minor", "value": 2, "target": "player", "positive": false},
		{"name": "spawn", "enemy": "baby_slasher", "minion": true},
		{"name": "spawn", "enemy": "baby_slasher", "minion": true},
	],
}
