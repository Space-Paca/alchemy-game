extends Reference

var image = "res://assets/images/enemies/poison elite/idle.png"
var name = "Monstrão"
var sfx = "fat_monster"
var use_idle_sfx = true
var hp = 60
var battle_init = false
var size = "big"

var states = ["poison", "defend-poison", "attack-poison"]
var connections = [
					  ["poison", "defend-poison", 5],
					  ["poison", "attack-poison", 3],
					  ["poison", "poison-attack", 3],
					  ["defend-poison", "poison", 1],
					  ["attack-poison", "poison", 1],
					  ["poison-attack", "poison", 1],
				  ]
var first_state = ["poison"]

var actions = {
	"poison": [
		{"name": "damage", "value": [8, 15], "type": "venom"},
	],
	"attack-poison": [
		{"name": "damage", "value": [3,8], "type": "regular"},
		{"name": "damage", "value": [5,6], "type": "venom"},
	],
	"poison-attack": [
		{"name": "damage", "value": [5,6], "type": "venom"},
		{"name": "damage", "value": [10,12], "type": "regular"},
	],
	"defend-poison": [
		{"name": "shield", "value": [13,15]},
		{"name": "damage", "value": [5, 10], "type": "venom"},
	]
}
