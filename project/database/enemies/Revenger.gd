extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Revenger.tscn"
var image = "res://assets/images/enemies/revenger/idle.png"
var name = "EN_REVENGER"
var sfx = "revenger"
var use_idle_sfx = false
var hp = {
	"easy": 30,
	"normal": 35,
	"hard": 40,
}
var battle_init = true
var size = "small"
var change_phase = null
var unique_bgm = null

var states = {
	"easy": ["init", "attack", "defend"],
	"normal": ["init", "attack", "defend"],
	"hard": ["init", "attack", "defend"],
}

var connections = {
	"easy": [
		["init", "attack", 1],
		["init", "defend", 1],
		["attack", "defend", 1],
		["attack", "attack", 2],
		["defend", "attack", 1],
	],
	"normal": [
		["init", "attack", 1],
		["init", "defend", 1],
		["attack", "defend", 1],
		["attack", "attack", 2],
		["defend", "attack", 1],
	],
	"hard": [
		["init", "attack", 1],
		["init", "defend", 1],
		["attack", "defend", 1],
		["attack", "attack", 2],
		["defend", "attack", 1],
	],
}

var first_state = {
	"easy": ["init"],
	"normal": ["init"],
	"hard": ["init"],
}

var actions = {
	"easy": {
		"init": [
			{"name": "status", "status_name": "revenge", "value": 10, "target": "self", "positive": true, "animation": ""}
		],
		"attack": [
			{"name": "damage", "value": [10, 16], "type": "regular", "animation": "02_atk"}
		],
		"defend": [
			{"name": "shield", "value": [10, 13], "animation": "03_dmg"},
		],
	},
	"normal": {
		"init": [
			{"name": "status", "status_name": "revenge", "value": 15, "target": "self", "positive": true, "animation": ""}
		],
		"attack": [
			{"name": "damage", "value": [12, 16], "type": "regular", "animation": "02_atk"}
		],
		"defend": [
			{"name": "shield", "value": [10, 15], "animation": "03_dmg"},
		],
	},
	"hard": {
		"init": [
			{"name": "status", "status_name": "revenge", "value": 25, "target": "self", "positive": true, "animation": ""}
		],
		"attack": [
			{"name": "damage", "value": [14, 16], "type": "regular", "animation": "02_atk"}
		],
		"defend": [
			{"name": "shield", "value": [10, 18], "animation": "03_dmg"},
		],
	},
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
