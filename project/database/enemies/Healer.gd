extends Reference

var image = "res://assets/images/enemies/small divider/idle.png"
var name = "Healer"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 35
var battle_init = true
var size = "small"

var states = ["attack", "defend", "heal"]
var connections = [
					  ["heal", "attack", 1],
					  ["heal", "defend", 1],
					  ["attack", "attack", 1],
					  ["attack", "defend", 1],
					  ["attack", "heal", 2],
					  ["defend", "attack", 1],
					  ["defend", "defend", 1],
					  ["defend", "heal", 2],
					  
				  ]
var first_state = ["attack", "defend"]

var actions = {
	"attack": [
		{"name": "damage", "value": [3,5], "type": "regular"}
	],
	"defend": [
		{"name": "defend", "value": [5, 6]}
	],
	"heal": [
		{"name": "heal", "value": [5,12], "target": "all_enemies"}
	],
}
