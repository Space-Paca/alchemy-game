extends Reference

var image = "res://assets/images/enemies/small poison enemy/idle.png"
var name = "Venenin Plus"
var sfx = "toxic_slime_minion"
var use_idle_sfx = false
var hp = 30
var battle_init = true
var size = "small"
var change_phase = null

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
		{"name": "shield", "value": 20}
	],
	"poison": [
		{"name": "damage", "value": [10,15], "type": "venom"}
	],
	"medium-poison": [
		{"name": "damage", "value": [7,9], "type": "venom"}
		
	],
	"defend-poison": [
		{"name": "shield", "value": [10,15]},
		{"name": "damage", "value": [5,6], "type": "venom"}
	]
}
