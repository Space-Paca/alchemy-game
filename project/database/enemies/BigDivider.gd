extends Reference

var image = "res://assets/images/enemies/homunculus/idle.png"
var name = "Big Divider"
var sfx = "slime"
var use_idle_sfx = true
var hp = 40
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
		{"name": "status", "status_name": "divider", "value": 0, "target": "self", "positive": true, "extra_args": {"enemy": "medium_divider"}}
	],
	"attack": [
		{"name": "damage", "value": [18, 20], "type": "regular"}
	],
	"defend": [
		{"name": "shield", "value": [10, 12]},
		{"name": "damage", "value": [10, 12], "type": "regular"}
	],
	"poison": [
		{"name": "status", "status_name": "poison", "value": [6,8], "target": "player", "positive": false}
	],
}
