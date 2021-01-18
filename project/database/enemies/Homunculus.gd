extends Reference

var image = "res://assets/images/enemies/regular enemy/idle.png"
var name = "Carapa Brave"
var sfx = "turtle_spider"
var use_idle_sfx = false
var hp = 45
var battle_init = false
var size = "medium"
var change_phase = null

var states = ["attack", "defend"]
var connections = [
					  ["attack", "defend", 5],
					  ["attack", "attack", 5],
					  ["defend", "attack", 1],
				  ]
var first_state = ["attack", "defend"]

var actions = {
	"attack": [
		{"name": "damage", "value": [10, 15], "type": "regular"}
	],
	"defend": [
		{"name": "shield", "value": [4, 6]},
		{"name": "damage", "value": [5, 7], "type": "regular"}
	],
}
