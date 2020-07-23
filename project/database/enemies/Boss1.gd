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
var name = "Boss1"
var sfx = "boss_1"
var use_idle_sfx = false
var hp = 100
var battle_init = true
var size = "big"

var states = ["init", "start", "attack1", "attack2", "buff-reagent"]
var connections = [
					  ["init", "start", 1],
					  ["start", "attack1", 1],
					  ["attack1", "attack2", 1],
					  ["attack2", "buff-reagent", 1],
					  ["buff-reagent", "attack1", 1],
	
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "guard_up", "value": 5, "target": "self", "positive": true}
	],
	"start": [
		{"name": "add_reagent", "type": "trash", "value": 5}
	],
	"attack1": [
		{"name": "damage", "value": 1, "type": "regular", "amount": 2},
	],
	"attack2": [
		{"name": "damage", "value": 1, "type": "regular", "amount": 3},
	],
	"buff-reagent": [
		{"name": "status", "status_name": "perm_strength", "value": 2, "target": "self", "positive": true},
		{"name": "add_reagent", "type": "trash", "value": 5}
	]
}

