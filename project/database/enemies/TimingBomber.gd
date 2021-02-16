extends Reference

var image = "res://assets/images/enemies/timing bomber/idle.png"
var name = "Dr. Bomberson"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 202
var battle_init = true
var size = "medium"
var change_phase = null

var states = ["init", "bomb-time", "attack", "defend", "big-attack"]
var connections = [
					  ["init", "attack", 1],
					  ["init", "defend", 1],
					  ["attack", "bomb-time", 1],
					  ["attack", "defend", 1],
					  ["big-attack", "bomb-time", 1],
					  ["big-attack", "defend", 1],
					  ["defend", "attack", 4],
					  ["defend", "big-attack", 3],
					  ["defend", "bomb-time", 4],
					  ["bomb-time", "attack", 4],
					  ["bomb-time", "big-attack", 3],
					  ["bomb-time", "defend", 4]
					
					  
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "time_bomb", "value": 4, "target": "player", "positive": false}
	],
	"bomb-time": [
		{"name": "status", "status_name": "time_bomb", "value": 8, "target": "player", "positive": false}
	],
	"attack": [
		{"name": "status", "status_name": "time_bomb", "value": 3, "target": "player", "positive": false},
		{"name": "damage", "value": [15,17], "type": "regular"},
	],
	"big-attack": [
		{"name": "status", "status_name": "time_bomb", "value": 2, "target": "player", "positive": false},
		{"name": "damage", "value": [19,25], "type": "regular"},
	],
	"defend": [
		{"name": "status", "status_name": "time_bomb", "value": 4, "target": "player", "positive": false},
		{"name": "shield", "value": [14,15]}
	],
}
