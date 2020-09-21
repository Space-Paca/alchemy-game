extends Reference

var image = "res://assets/images/enemies/medium divider/idle.png"
var name = "Medium Divider"
var sfx = "toxic_slime"
var use_idle_sfx = true
var hp = 20
var battle_init = true
var size = "medium"

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
}
