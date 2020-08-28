extends Reference

var image = "res://assets/images/enemies/buffing big enemy/idle.png"
var name = "Restrainer"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 160
var battle_init = false
var size = "big"

var states = ["attack1", "attack2", "attack3", "charging", "big_restrain", "medium_restrain"]
var connections = [   
					 
					  ["attack1", "attack2", 4],
					  ["attack1", "attack3", 4],
					  ["attack1", "medium_restrain", 3],
					  ["attack1", "charging", 2],
					  ["attack2", "attack1", 4],
					  ["attack2", "attack3", 4],
					  ["attack2", "medium_restrain", 3],
					  ["attack2", "charging", 2],
					  ["attack3", "medium_restrain", 3],
					  ["attack3", "charging", 3],
					  ["attack3", "attack1", 2],
					  ["attack3", "attack2", 2],
					  ["charging", "big_restrain", 1],
					  ["big_restrain", "attack1", 4],
					  ["big_restrain", "attack2", 4],
					  ["big_restrain", "attack3", 2],
					  ["medium_restrain", "attack1", 4],
					  ["medium_restrain", "attack2", 4],
					  ["medium_restrain", "attack3", 3],
				  ]
var first_state = ["attack1", "attack2"]

var actions = {
	"attack1": [
		{"name": "status", "status_name": "restrained", "value": 4, "target": "player", "positive": false},
		{"name": "damage", "value": [15, 25], "type": "regular"}
	],
	"attack2": [
		{"name": "status", "status_name": "restrained", "value": 5, "target": "player", "positive": false},
		{"name": "damage", "value": [12, 20], "type": "regular"}
	],
	"attack3": [
		{"name": "damage", "value": [20, 30], "type": "regular"}
	],
	"charging": [
		{"name": "idle", "sfx": "charge"}
	],
	"big_restrain": [
		{"name": "status", "status_name": "restrained", "value": 16, "target": "player", "positive": false},
	],
	"medium_restrain": [
		{"name": "status", "status_name": "restrained", "value": 8, "target": "player", "positive": false},
	],
}
