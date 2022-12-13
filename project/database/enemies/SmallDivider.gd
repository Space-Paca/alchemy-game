extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/SmallDivider.tscn"
var image = "res://assets/images/enemies/small divider/idle.png"
var name = "EN_SMALL_DIVIDER"
var sfx = "divider"
var use_idle_sfx = false
var hp = {
	"easy": 20,
	"normal": 25,
	"hard": 30,
}
var battle_init = true
var size = "small"
var change_phase = null
var unique_bgm = null

var states = {
	"easy": ["init", "first", "attack", "defend", "poison", "second"],
	"normal": ["init", "first", "attack", "defend", "poison", "second"],
	"hard": ["init", "first", "attack", "defend", "poison", "second"],
}
var connections = {
	"easy": [
		["init", "first", 1],
		["first", "second", 1],
		["second", "poison", 1],
		["attack", "poison", 1],
		["defend", "poison", 1],
		["poison", "attack", 1],
		["poison", "defend", 1],
	],
	"normal": [
		["init", "first", 1],
		["first", "second", 1],
		["second", "poison", 1],
		["attack", "poison", 1],
		["defend", "poison", 1],
		["poison", "attack", 1],
		["poison", "defend", 1],
	],
	"hard": [
		["init", "first", 1],
		["first", "second", 1],
		["second", "poison", 1],
		["attack", "poison", 1],
		["defend", "poison", 1],
		["poison", "attack", 1],
		["poison", "defend", 1],
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
			{"name": "shield", "value": 6, "animation": "02_atk"},
		],
		"attack": [
			{"name": "status", "status_name": "poison", "value": 2, "target": "player", "positive": false, "animation": "02_atk"}
		],
		"defend": [
			{"name": "shield", "value": [10, 12], "animation": "02_atk"},
			{"name": "status", "status_name": "poison", "value": 1, "target": "player", "positive": false, "animation": "02_atk"}
		],
		"poison": [
			{"name": "damage", "value": [6, 8], "type": "venom", "animation": "02_atk"},
		],
		"first": [
			{"name": "shield", "value": 6, "animation": "02_atk"},
		],
		"second": [
			{"name": "status", "status_name": "poison", "value": 2, "target": "player", "positive": false, "animation": "02_atk"}
		],
	},
	"normal": {
		"init": [
			{"name": "shield", "value": [6, 8], "animation": "02_atk"},
		],
		"attack": [
			{"name": "status", "status_name": "poison", "value": [2,3], "target": "player", "positive": false, "animation": "02_atk"}
		],
		"defend": [
			{"name": "shield", "value": [10, 15], "animation": "02_atk"},
			{"name": "status", "status_name": "poison", "value": [1,2], "target": "player", "positive": false, "animation": "02_atk"}
		],
		"poison": [
			{"name": "damage", "value": [6, 8], "type": "venom", "animation": "02_atk"},
		],
		"first": [
			{"name": "shield", "value": [6, 8], "animation": "02_atk"},
		],
		"second": [
			{"name": "status", "status_name": "poison", "value": 2, "target": "player", "positive": false, "animation": "02_atk"}
		],
	},
	"hard": {
		"init": [
			{"name": "shield", "value": [8, 10], "animation": "02_atk"},
		],
		"attack": [
			{"name": "status", "status_name": "poison", "value": [2,5], "target": "player", "positive": false, "animation": "02_atk"}
		],
		"defend": [
			{"name": "shield", "value": [10, 15], "animation": "02_atk"},
			{"name": "status", "status_name": "poison", "value": [1,4], "target": "player", "positive": false, "animation": "02_atk"}
		],
		"poison": [
			{"name": "damage", "value": [8, 10], "type": "venom", "animation": "02_atk"},
		],
		"first": [
			{"name": "shield", "value": [6, 8], "animation": "02_atk"},
		],
		"second": [
			{"name": "status", "status_name": "poison", "value": 3, "target": "player", "positive": false, "animation": "02_atk"}
		],
	},
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
