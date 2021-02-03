extends Reference

var image = "res://assets/images/enemies/medium divider/idle.png"
var name = "Plantoon"
var sfx = "toxic_slime"
var use_idle_sfx = true
var hp = 30
var battle_init = true
var size = "medium"
var change_phase = null

var states = ["init", "attack", "defend", "poison", "first"]
var connections = [
					  ["init", "first", 1],
					  ["first", "poison", 1],
					  ["attack", "poison", 1],
					  ["defend", "poison", 1],
					  ["poison", "attack", 1],
					  ["poison", "defend", 1],
					
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "splitting", "value": 0, "target": "self", "positive": true, "extra_args": {"enemy": "small_divider"}}
	],
	"attack": [
		{"name": "damage", "value": [10, 15], "type": "regular"}
	],
	"defend": [
		{"name": "shield", "value": [6, 8]},
		{"name": "damage", "value": [6, 8], "type": "regular"}
	],
	"poison": [
		{"name": "damage", "value": [8, 12], "type": "venom"},
	],
	"first": [
		{"name": "damage", "value": [2,3], "type": "venom"},
	],
}
