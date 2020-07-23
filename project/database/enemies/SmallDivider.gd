extends Reference

var image = "res://assets/images/enemies/homunculus/idle.png"
var name = "Small Divider"
var sfx = "toxic_slime"
var use_idle_sfx = true
var hp = 10
var battle_init = false
var size = "small"

var states = ["attack", "defend", "poison"]
var connections = [
					  ["attack", "poison", 1],
					  ["defend", "poison", 1],
					  ["poison", "attack", 1],
					  ["poison", "defend", 1],
					
				  ]
var first_state = ["poison"]

var actions = {
	"attack": [
		{"name": "damage", "value": [7, 9], "type": "regular"}
	],
	"defend": [
		{"name": "shield", "value": [4, 5]},
		{"name": "damage", "value": [4, 5], "type": "regular"}
	],
	"poison": [
		{"name": "status", "status_name": "poison", "value": [2,3], "target": "player", "positive": false}
	],
}
