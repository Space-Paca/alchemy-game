extends Reference

var image = "res://assets/images/enemies/small regular enemy plus/idle.png"
var name = "EN_BABY_CARAPA_PLUS"
var sfx = "wolftopus"
var use_idle_sfx = false
var hp = 45
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
		{"name": "damage", "value": [8,25], "type": "regular"}
	]
}
