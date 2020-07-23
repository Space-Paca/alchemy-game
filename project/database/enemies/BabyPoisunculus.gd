extends Reference

var image = "res://assets/images/enemies/small poison enemy/idle.png"
var name = "Venenin"
var sfx = "toxic_slime_minion"
var use_idle_sfx = false
var hp = 6
var battle_init = true
var size = "small"

var states = ["init", "poison", "defend-poison", "medium-poison"]
var connections = [
					  ["init", "poison", 1],
					  ["poison", "defend-poison", 5],
					  ["poison", "medium-poison", 3],
					  ["defend-poison", "medium-poison", 1],
					  ["medium-poison", "defend-poison", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "shield", "value": 6}
	],
	"poison": [
		{"name": "status", "status_name": "poison", "value": [3,4], "target": "player", "positive": false}
	],
	"medium-poison": [
		{"name": "status", "status_name": "poison", "value": [2,3], "target": "player", "positive": false}
	],
	"defend-poison": [
		{"name": "shield", "value": [7,9]},
		{"name": "status", "status_name": "poison", "value": [1,2], "target": "player", "positive": false}
	]
}
