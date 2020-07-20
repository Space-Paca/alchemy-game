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
					  ["defend-poison", "poison", 1],
					  ["attack-poison", "poison", 1],
				  ]
var first_state = ["poison"]

var actions = {
	"poison": [
		{"name": "status", "status_name": "poison", "value": [5, 7], "target": "player", "positive": false}
	],
	"attack-poison": [
		{"name": "damage", "value": [4,6], "type": "regular"},
		{"name": "status", "status_name": "poison", "value": [1, 2], "target": "player", "positive": false}
	],
	"defend-poison": [
		{"name": "shield", "value": [13,15]},
		{"name": "status", "status_name": "poison", "value": [1, 2], "target": "player", "positive": false}
	]
}
