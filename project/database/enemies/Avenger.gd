extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Avenger.tscn"
var image = "res://assets/images/enemies/avenger/idle.png"
var name = "EN_AVENGER"
var sfx = "carapa"
var use_idle_sfx = false
var hp = {
	"easy": 100,
	"normal": 125,
	"hard": 150,
}
var battle_init = true
var size = "small"
var change_phase = null
var unique_bgm = null

var states = {
	"normal": ["init", "attack1", "defend", "attack2"],
	"hard": ["init", "attack1", "defend", "attack2"],
}

var connections = {
	"normal": [
		  ["init", "attack1", 1],
		  ["init", "attack2", 1],
		  ["init", "defend", 1],
		  ["attack1", "defend", 2],
		  ["attack1", "attack1", 3],
		  ["attack1", "attack2", 1],
		  ["attack2", "defend", 2],
		  ["attack2", "attack1", 3],
		  ["attack2", "attack2", 1],
		  ["defend", "attack1", 2],
		  ["defend", "attack2", 1],
	],
	"hard": [
		  ["init", "attack1", 1],
		  ["init", "attack2", 1],
		  ["init", "defend", 1],
		  ["attack1", "defend", 2],
		  ["attack1", "attack1", 3],
		  ["attack1", "attack2", 1],
		  ["attack2", "defend", 2],
		  ["attack2", "attack1", 3],
		  ["attack2", "attack2", 1],
		  ["defend", "attack1", 2],
		  ["defend", "attack2", 1],
	],
}

var first_state = {
	"normal": ["init"],
	"hard": ["init"],
}

var actions = {
	"normal": {
		"init": [
			{"name": "status", "status_name": "avenge", "value": 20, "target": "self", "positive": true, "animation": "taunt"}
		],
		"attack1": [
			{"name": "damage", "value": [30, 35], "type": "regular", "animation": "atk3_arc"}
		],
		"attack2": [
			{"name": "damage", "value": [14, 20], "amount": 2, "type": "regular", "animation": "atk2"}
		],
		"defend": [
			{"name": "shield", "value": [10, 25], "animation": "defense"},
		],
	},
	"hard": {
		"init": [
			{"name": "status", "status_name": "avenge", "value": 40, "target": "self", "positive": true, "animation": "taunt"}
		],
		"attack1": [
			{"name": "damage", "value": [30, 35], "type": "regular", "animation": "atk3_arc"}
		],
		"attack2": [
			{"name": "damage", "value": [14, 20], "amount": 2, "type": "regular", "animation": "atk2"}
		],
		"defend": [
			{"name": "shield", "value": [10, 25], "animation": "defense"},
		],
	},
}


func _init():
	idle_anim_name = "stand"
	death_anim_name = "death"
	dmg_anim_name = "dmg"
	entry_anim_name = "enter"
	variant_idles = ["idle", "idle2"]
