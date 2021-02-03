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
		{"name": "damage", "value": [7, 9], "type": "regular"}
	],
	"defend": [
		{"name": "shield", "value": [4, 5]},
		{"name": "damage", "value": [4, 5], "type": "regular"}
	],
	"poison": [
		{"name": "damage", "value": [4, 6], "type": "venom"},
	],
	"first": [
		{"name": "damage", "value": 1, "type": "venom"},
	],
}
