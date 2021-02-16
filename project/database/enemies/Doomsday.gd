extends Reference

var image = "res://assets/images/enemies/doomsayer/idle.png"
var name = "Doomsayer"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 460
var battle_init = true
var size = "big"
var change_phase = null

var states = ["init", "attack1", "attack2", "doom", "dodge"]
var connections = [
					  ["init", "attack1", 1],
					  ["init", "attack2", 1],
					  ["attack1", "attack2", 3],
					  ["attack1", "doom", 2],
					  ["attack1", "dodge", 2],
					  ["attack2", "attack1", 3],
					  ["attack2", "doom", 2],
					  ["attack2", "dodge", 2],
					  ["doom", "attack1", 2],
					  ["doom", "attack2", 2],
					  ["doom", "dodge", 1],
					  ["dodge", "attack1", 2],
					  ["dodge", "attack2", 2],
					  ["dodge", "doom", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "impending_doom", "value": 99, "target": "self", "positive": true}
	],
	"attack1": [
		{"name": "damage", "value": [30, 50], "type": "regular"},
		{"name": "status", "status_name": "impending_doom", "value": [4,5], "target": "self", "positive": true, "reduce": true}
	],
	"attack2": [
		{"name": "damage", "value": [4, 7], "amount": 7, "type": "regular"},
		{"name": "status", "status_name": "impending_doom", "value": [4,5], "target": "self", "positive": true, "reduce": true}
	],
	"doom": [
		{"name": "status", "status_name": "impending_doom", "value": [15,20], "target": "self", "positive": true, "reduce": true}
	],
	"dodge": [
		{"name": "status", "status_name": "impending_doom", "value": [8,12], "target": "self", "positive": true, "reduce": true},
		{"name": "status", "status_name": "dodge", "value": 4, "target": "self", "positive": true}
	],
}
