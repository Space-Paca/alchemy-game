extends Reference

var image = "res://assets/images/enemies/delayed hitter plus/idle.png"
var name = "Delayed hitter"
var sfx = "stone_golem"
var use_idle_sfx = false
var hp = 65
var battle_init = false
var size = "small"
var change_phase = null

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
		{"name": "idle", "sfx": "charge"}
	],
	"preparing2": [
		{"name": "idle", "sfx": "charge"}
	],
	"preparing3": [
		{"name": "idle", "sfx": "charge"}
	],
	"preparing4": [
		{"name": "idle", "sfx": "charge"}
	],
	"attack": [
		{"name": "damage", "value": [25, 29], "type": "regular"},
	],
}
