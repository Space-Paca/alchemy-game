extends Reference

var image = "res://assets/images/enemies/spawner poison enemy/idle.png"
var name = "Spawner"
var sfx = "toxic_slime"
var use_idle_sfx = true
var hp = 25
var battle_init = false
var size = "small"

var states = ["attack", "defend", "spawn", "poison"]
var connections = [
					  ["attack", "defend", 5],
					  ["attack", "spawn", 5],
					  ["attack", "poison", 2],
					  ["defend", "attack", 5],
					  ["defend", "spawn", 5],
					  ["defend", "poison", 2],
					  ["spawn", "attack", 4],
					  ["spawn", "defend", 4],
					  ["spawn", "poison", 2],
					  ["poison", "attack", 1],
					  ["poison", "defend", 1],
					  ["poison", "spawn", 1],
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
	"poison": [
		{"name": "damage", "value": [5,6], "type": "venom"},
	],
	"spawn": [
		{"name": "spawn", "enemy": "baby_poison"},
	],
}
