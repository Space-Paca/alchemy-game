extends Reference

var image = "res://assets/images/enemies/small regular enemy/idle.png"
var name = "Baby Slasher"
var sfx = "slime"
var use_idle_sfx = false
var hp = 5
var battle_init = false
var size = "small"

var states = ["attack"]
var connections = [
					  ["attack", "attack", 1],
				  ]
var first_state = ["attack"]

var actions = {
	"attack": [
		{"name": "damage", "value": [2,3], "type": "piercing"}
	]
}
