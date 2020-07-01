extends Reference

var image = "res://assets/images/enemies/homunculus/idle.png"
var name = "Delayed hitter"
var sfx = "slime"
var use_idle_sfx = true
var hp = 42
var battle_init = false
var size = "small"

var states = ["attack", "preparing1", "preparing2", "preparing3", "preparing4"]
var connections = [
					  ["preparing1", "preparing2", 1],
					  ["preparing2", "preparing3", 1],
					  ["preparing3", "preparing4", 1],
					  ["preparing4", "attack", 1],
					  ["attack", "attack", 1],
				  ]
var first_state = ["preparing1"]

var actions = {
	"preparing1": [
		{"name": "idle"}
	],
	"preparing2": [
		{"name": "idle"}
	],
	"preparing3": [
		{"name": "idle"}
	],
	"preparing4": [
		{"name": "idle"}
	],
	"attack": [
		{"name": "damage", "value": [25, 29], "type": "regular"},
	],
}
