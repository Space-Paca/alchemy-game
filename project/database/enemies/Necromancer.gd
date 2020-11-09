extends Reference

var image = "res://assets/images/enemies/curser/idle.png"
var name = "Necromancer"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 80
var battle_init = true
var size = "medium"
var change_phase = null

var states = ["init", "spawn", "attack1", "attack2", "defense", "debuff"]
var connections = [
					  ["init", "spawn", 1],
					  ["spawn", "attack1", 1],
					  ["spawn", "defense", 1],
					  ["attack1", "debuff", 2],
					  ["attack1", "attack2", 2],
					  ["defense", "debuff", 1],
					  ["defense", "attack2", 1],
					  ["attack2", "spawn", 1],
					  ["debuff", "spawn", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "deep_wound", "value": 1, "target": "player", "positive": false}
	],
	"attack1": [
		{"name": "damage", "value": [10, 20], "type": "regular"}
	],
	"attack2": [
		{"name": "damage", "value": [10, 20], "type": "regular"}
	],
	"defense": [
		{"name": "shield", "value": [7, 15]}
	],
	"debuff": [
		{"name": "status", "status_name": "weakness", "value": 2, "target": "player", "positive": false}
	],
	"spawn": [
		{"name": "shield", "value": [9, 10]},
		{"name": "spawn", "enemy": "zombie", "minion": true},
	],
}
