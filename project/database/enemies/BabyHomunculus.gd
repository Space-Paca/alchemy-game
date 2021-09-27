extends Reference

var image = "res://assets/images/enemies/small regular enemy/idle.png"
var name = "EN_BABY_HOMUN"
var sfx = "wolftopus"
var use_idle_sfx = false
var hp = 15
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
		{"name": "damage", "value": [5,7], "type": "regular"}
	]
}
