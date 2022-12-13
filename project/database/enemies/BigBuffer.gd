extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/BigBuffer.tscn"
var image = "res://assets/images/enemies/buffing big enemy/idle.png"
var name = "EN_BIG_BUFFER"
var sfx = "morhk"
var use_idle_sfx = false
var hp = {
	"easy": 70,
	"normal": 80,
	"hard": 85,
}
var battle_init = false
var size = "medium"
var change_phase = null
var unique_bgm = null

var states = {
	"easy": ["temp_buff", "perm_buff", "attack"],
	"normal": ["temp_buff", "perm_buff", "attack"],
	"hard": ["temp_buff", "perm_buff", "attack"],
}

var connections = {
	"easy": [
		["temp_buff", "attack", 3],
		["temp_buff", "temp_buff", 1],
		["attack", "perm_buff", 1],
		["perm_buff", "temp_buff", 1],
		["perm_buff", "attack", 3],
		["perm_buff", "temp_buff", 1],
	],
	"normal": [
		["temp_buff", "attack", 3],
		["temp_buff", "temp_buff", 1],
		["attack", "perm_buff", 1],
		["perm_buff", "temp_buff", 1],
		["perm_buff", "attack", 3],
		["perm_buff", "temp_buff", 1],
	],
	"hard": [
		["temp_buff", "attack", 3],
		["temp_buff", "temp_buff", 1],
		["attack", "perm_buff", 1],
		["perm_buff", "temp_buff", 1],
		["perm_buff", "attack", 3],
		["perm_buff", "temp_buff", 1],
	],
}

var first_state = {
	"easy": ["temp_buff"],
	"normal": ["temp_buff"],
	"hard": ["temp_buff"],
}

var actions = {
	"easy": {
		"temp_buff": [
			{"name": "status", "status_name": "temp_strength", "value": 8, "target": "self", "positive": true, "animation": "idle"}
		],
		"perm_buff": [
			{"name": "status", "status_name": "perm_strength", "value": 4, "target": "self", "positive": true, "animation": "idle"}
		],
		"attack": [
			{"name": "damage", "value": [4,6], "type": "regular", "animation": "atk"},
		]
	},
	"normal": {
		"temp_buff": [
			{"name": "status", "status_name": "temp_strength", "value": 11, "target": "self", "positive": true, "animation": "idle"}
		],
		"perm_buff": [
			{"name": "status", "status_name": "perm_strength", "value": 6, "target": "self", "positive": true, "animation": "idle"}
		],
		"attack": [
			{"name": "damage", "value": [4,6], "type": "regular", "animation": "atk"},
		]
	},
	"hard": {
		"temp_buff": [
			{"name": "status", "status_name": "temp_strength", "value": 15, "target": "self", "positive": true, "animation": "idle"}
		],
		"perm_buff": [
			{"name": "status", "status_name": "perm_strength", "value": 8, "target": "self", "positive": true, "animation": "idle"}
		],
		"attack": [
			{"name": "damage", "value": [4,6], "type": "regular", "animation": "atk"},
		]
	},
}


func _init():
	idle_anim_name = "stand"
	death_anim_name = "death"
	dmg_anim_name = "dmg"
#	variant_idles = [""]
