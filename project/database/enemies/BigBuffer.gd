extends Reference

var image = "res://assets/images/enemies/buffing big enemy/idle.png"
var name = "EN_BIG_BUFFER"
var sfx = "goblintaur"
var use_idle_sfx = false
var hp = 90
var battle_init = false
var size = "medium"
var change_phase = null

var states = ["temp_buff", "perm_buff", "attack"]
var connections = [["temp_buff", "attack", 3],
				   ["temp_buff", "temp_buff", 1],
				   ["attack", "perm_buff", 1],
				   ["perm_buff", "temp_buff", 1],
				   ["perm_buff", "attack", 3],
				   ["perm_buff", "temp_buff", 1],
						 ]
var first_state = ["temp_buff"]

var actions = {
	"temp_buff": [
		{"name": "status", "status_name": "temp_strength", "value": 10, "target": "self", "positive": true}
	],
	"perm_buff": [
		{"name": "status", "status_name": "perm_strength", "value": 5, "target": "self", "positive": true}
	],
	"attack": [
		{"name": "damage", "value": [3,5], "type": "regular"},
	]
}
