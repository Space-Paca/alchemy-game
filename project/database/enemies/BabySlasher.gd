extends Reference

var image = "res://assets/images/enemies/small piercing/idle.png"
var name = "Needler Spawn"
var sfx = "eye_crab_minion"
var use_idle_sfx = false
var hp = 5
var battle_init = false
var size = "small"
var change_phase = null

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
