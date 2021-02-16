extends Reference

var image = "res://assets/images/enemies/big divider/idle.png"
var name = "Plantora"
var sfx = "toxic_slime"
var use_idle_sfx = true
var hp = 80
var battle_init = true
var size = "medium"
var change_phase = null

var states = ["init", "attack", "defend", "poison"]
var connections = [
					  ["init", "poison", 1],
					  ["attack", "poison", 1],
					  ["defend", "poison", 1],
					  ["poison", "attack", 1],
					  ["poison", "defend", 1],
					
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "splitting", "value": 0, "target": "self", "positive": true, "extra_args": {"enemy": "medium_divider"}}
	],
	"attack": [
		{"name": "damage", "value": [20, 30], "type": "regular"}
	],
	"defend": [
		{"name": "shield", "value": [15, 20]},
		{"name": "damage", "value": [10, 20], "type": "regular"}
	],
	"poison": [
		{"name": "damage", "value": [15, 25], "type": "venom"},
	],
}
