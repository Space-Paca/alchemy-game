extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Overkiller.tscn"
var image = "res://assets/images/enemies/overkiller/idle.png"
var name = "EN_OVERKILLER"
var sfx = "overkiller"
var use_idle_sfx = false
var hp = {
	"easy": 80,
	"normal": 90,
	"hard": 99,
}
var battle_init = true
var size = "small"
var change_phase = null
var unique_bgm = null

var states = {
	"easy": ["init", "attack1", "defend", "attack2", "buff"],
	"normal": ["init", "attack1", "defend", "attack2", "buff"],
	"hard": ["init", "attack1", "defend", "attack2", "buff"],
}

var connections = {
	"easy": [
		["init", "attack1", 1],
		["init", "attack2", 1],
		["init", "defend", 1],
		["attack1", "defend", 4],
		["attack1", "attack1", 6],
		["attack1", "attack2", 4],
		["attack1", "buff", 2],
		["attack2", "defend", 4],
		["attack2", "attack1", 6],
		["attack2", "attack2", 4],
		["attack2", "buff", 2],
		["defend", "attack1", 4],
		["defend", "attack2", 4],
		["defend", "attack2", 2],
		["defend", "buff", 1],
		["buff", "buff", 1],
		["buff", "attack1", 4],
		["buff", "attack2", 4],
		["buff", "defend", 2],
	],
	"normal": [
		["init", "attack1", 1],
		["init", "attack2", 1],
		["init", "defend", 1],
		["attack1", "defend", 4],
		["attack1", "attack1", 6],
		["attack1", "attack2", 4],
		["attack1", "buff", 2],
		["attack2", "defend", 4],
		["attack2", "attack1", 6],
		["attack2", "attack2", 4],
		["attack2", "buff", 2],
		["defend", "attack1", 4],
		["defend", "attack2", 4],
		["defend", "attack2", 2],
		["defend", "buff", 1],
		["buff", "buff", 1],
		["buff", "attack1", 4],
		["buff", "attack2", 4],
		["buff", "defend", 2],
	],
	"hard": [
		["init", "attack1", 1],
		["init", "attack2", 1],
		["init", "defend", 1],
		["attack1", "defend", 4],
		["attack1", "attack1", 6],
		["attack1", "attack2", 4],
		["attack1", "buff", 2],
		["attack2", "defend", 4],
		["attack2", "attack1", 6],
		["attack2", "attack2", 4],
		["attack2", "buff", 2],
		["defend", "attack1", 4],
		["defend", "attack2", 4],
		["defend", "attack2", 2],
		["defend", "buff", 1],
		["buff", "buff", 1],
		["buff", "attack1", 4],
		["buff", "attack2", 4],
		["buff", "defend", 2],
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
			{"name": "status", "status_name": "soulbind", "value": 1, "target": "self", "positive": true, "animation": ""},
			{"name": "shield", "value": [15, 30], "animation": ""},
		],
		"attack1": [
			{"name": "damage", "value": [25, 30], "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [10, 20], "animation": ""},
		],
		"attack2": [
			{"name": "damage", "value": [10, 45], "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [10, 20], "animation": ""},
		],
		"defend": [
			{"name": "shield", "value": [25, 40], "animation": ""},
		],
		"buff": [
			{"name": "status", "status_name": "perm_strength", "value": 12, "target": "self", "positive": true, "animation": ""}
		],
	},
	"normal": {
		"init": [
			{"name": "status", "status_name": "soulbind", "value": 1, "target": "self", "positive": true, "animation": ""},
			{"name": "shield", "value": [15, 40], "animation": ""},
		],
		"attack1": [
			{"name": "damage", "value": [25, 30], "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [10, 30], "animation": ""},
		],
		"attack2": [
			{"name": "damage", "value": [10, 50], "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [10, 30], "animation": ""},
		],
		"defend": [
			{"name": "shield", "value": [25, 50], "animation": ""},
		],
		"buff": [
			{"name": "status", "status_name": "perm_strength", "value": 15, "target": "self", "positive": true, "animation": ""}
		],
	},
	"hard": {
		"init": [
			{"name": "status", "status_name": "soulbind", "value": 1, "target": "self", "positive": true, "animation": ""},
			{"name": "shield", "value": [25, 50], "animation": ""},
		],
		"attack1": [
			{"name": "damage", "value": [25, 40], "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [10, 40], "animation": ""},
		],
		"attack2": [
			{"name": "damage", "value": [10, 60], "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [10, 40], "animation": ""},
		],
		"defend": [
			{"name": "shield", "value": [25, 60], "animation": ""},
		],
		"buff": [
			{"name": "status", "status_name": "perm_strength", "value": 20, "target": "self", "positive": true, "animation": ""}
		],
	},
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
