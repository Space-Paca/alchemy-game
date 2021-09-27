extends Reference

var image = "res://assets/images/enemies/small poison enemy plus/idle.png"
var name = "EN_BABY_POISUN_PLUS"
var sfx = "toxic_slime_minion"
var use_idle_sfx = false
var hp = 90
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
		{"name": "shield", "value": 30}
	],
	"poison": [
		{"name": "damage", "value": [12,20], "type": "venom"}
	],
	"medium-poison": [
		{"name": "status", "status_name": "poison", "value": [2, 4], "target": "player", "positive": false},
		{"name": "status", "status_name": "perm_strength", "value": 5, "target": "self", "positive": true},
		
	],
	"defend-poison": [
		{"name": "shield", "value": [20,25]},
		{"name": "damage", "value": [5,6], "amount": 2, "type": "venom"}
	]
}
