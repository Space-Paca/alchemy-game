extends Reference

var image = "res://assets/images/enemies/spawner poison enemy/idle.png"
var name = "Spawner"
var sfx = "slime"
var use_idle_sfx = true
var hp = 25
var battle_init = false
var size = "small"

var states = ["attack", "defend", "spawn"]
var connections = [
					  ["attack", "defend", 5],
					  ["attack", "spawn", 5],
					  ["defend", "attack", 5],
					  ["defend", "spawn", 5],
					  ["spawn", "attack", 1],
					  ["spawn", "defend", 1],
				  ]
var first_state = ["attack", "defend"]

var actions = {
	"attack": [
		{"name": "shield", "value": [4,5]},
		{"name": "damage", "value": [5,6], "type": "regular"},
	],
	"defend": [
		{"name": "shield", "value": [8,10]},
	],
	"spawn": [
		{"name": "spawn", "enemy": "baby_poison"},
	],
}
