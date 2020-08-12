extends Reference

var image = "res://assets/images/enemies/small regular enemy plus/idle.png"
var name = "Wolftopus+"
var sfx = "wolftopus"
var use_idle_sfx = false
var hp = 20
var battle_init = false
var size = "small"

var states = ["attack"]
var connections = [
					  ["attack", "attack", 1],
				  ]
var first_state = ["attack"]

var actions = {
	"attack": [
		{"name": "damage", "value": [9,10], "type": "regular"}
	]
}
