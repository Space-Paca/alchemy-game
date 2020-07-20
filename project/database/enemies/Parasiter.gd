extends Reference

var image = "res://assets/images/enemies/dodge enemy/idle.png"
var name = "Parasiter"
var sfx = "toxic_slime"
var use_idle_sfx = false
var hp = 65
var battle_init = true
var size = "medium"

var states = ["init", "drain", "attack"]
var connections = [
					  ["init", "attack", 1],
					  ["init", "drain", 1],
					  ["attack", "attack", 1],
					  ["attack", "drain", 2],
					  ["drain", "attack", 3],
					  ["drain", "drain", 1],
					  
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "status", "status_name": "parasite", "value": 2, "target": "self", "positive": true}
	],
	"drain": [
		{"name": "drain", "value": [8, 10]}
	],
	"attack": [
		{"name": "damage", "value": 5, "amount": 2, "type": "regular"}
	],
}
