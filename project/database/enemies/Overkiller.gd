extends Reference

var image = "res://assets/images/enemies/overkiller/idle.png"
var name = "Soulbound Doll"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 90
var battle_init = true
var size = "small"
var change_phase = null

var states = ["init", "attack1", "defend", "attack2", "buff"]
var connections = [
					  ["init", "attack1", 1],
					  ["init", "attack2", 1],
					  ["init", "defend", 1],
					  ["attack1", "defend", 4],
					  ["attack1", "attack1", 6],
					  ["attack1", "attack2", 4],
					  ["attack1", "buff", 2],
					  ["attack2", "defend", 4],
					  ["attack2", "attack1", 6],
					  ["attack2", "attack2", 4],
					  ["attack2", "buff", 2],
					  ["defend", "attack1", 4],
					  ["defend", "attack2", 4],
					  ["defend", "attack2", 2],
					  ["defend", "buff", 1],
					  ["buff", "buff", 1],
					  ["buff", "attack1", 4],
					  ["buff", "attack2", 4],
					  ["buff", "defend", 2],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "soulbind", "value": 1, "target": "self", "positive": true},
		{"name": "shield", "value": [15, 40]},
	],
	"attack1": [
		{"name": "damage", "value": [25, 30], "type": "regular"},
		{"name": "shield", "value": [10, 30]},
	],
	"attack2": [
		{"name": "damage", "value": [10, 50], "type": "regular"},
		{"name": "shield", "value": [10, 30]},
	],
	"defend": [
		{"name": "shield", "value": [25, 50]},
	],
	"buff": [
		{"name": "status", "status_name": "perm_strength", "value": 15, "target": "self", "positive": true}
	],
}
