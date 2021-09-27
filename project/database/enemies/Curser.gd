extends Reference

var image = "res://assets/images/enemies/curser/idle.png"
var name = "EN_CURSER"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 100
var battle_init = true
var size = "medium"
var change_phase = null

var states = ["init", "attack", "debuff"]
var connections = [
					  ["init", "attack", 1],
					  ["init", "debuff", 1],
					  ["attack", "attack", 2],
					  ["attack", "debuff", 1],
					  ["debuff", "attack", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "curse", "value": 2, "target": "player", "positive": false}
	],
	"attack": [
		{"name": "damage", "value": [10, 20], "type": "regular"}
	],
	"debuff": [
		{"name": "shield", "value": [5, 18]},
		{"name": "status", "status_name": "weakness", "value": 1, "target": "player", "positive": false}
	],
}
