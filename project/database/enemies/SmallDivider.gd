extends Reference

var image = "res://assets/images/enemies/small divider/idle.png"
var name = "Plantling"
var sfx = "toxic_slime"
var use_idle_sfx = true
var hp = 20
var battle_init = false
var size = "small"
var change_phase = null

var states = ["first","attack", "defend", "poison"]
var connections = [
					  ["first", "poison", 1],
					  ["attack", "poison", 1],
					  ["defend", "poison", 1],
					  ["poison", "attack", 1],
					  ["poison", "defend", 1],
					
				  ]
var first_state = ["first"]

var actions = {
	"attack": [
		{"name": "status", "status_name": "poison", "value": [2,3], "target": "player", "positive": false}
	],
	"defend": [
		{"name": "shield", "value": [10, 15]},
		{"name": "status", "status_name": "poison", "value": [1,2], "target": "player", "positive": false}
	],
	"poison": [
		{"name": "damage", "value": [10, 12], "type": "venom"},
	],
	"first": [
		{"name": "status", "status_name": "poison", "value": [1,2], "target": "player", "positive": false}
	],
}
