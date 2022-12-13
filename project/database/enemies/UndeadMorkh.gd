extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/UndeadMorkh.tscn"
var image = "res://assets/images/enemies/undead_morkh/idle.png"
var name = "EN_UNDEAD_MORKH"
var sfx = "morhk"
var use_idle_sfx = false
var hp = {
	"easy": 150,
	"normal": 160,
	"hard": 180,
}
var battle_init = true
var size = "medium"
var change_phase = null
var unique_bgm = null

var states = {
	"easy": ["init","temp_buff", "perm_buff", "attack"],
	"normal": ["init","temp_buff", "perm_buff", "attack"],
	"hard": ["init","temp_buff", "perm_buff", "attack"],
}

var connections = {
	"easy": [
		["init", "temp_buff", 1],
		["temp_buff", "attack", 3],
		["temp_buff", "temp_buff", 1],
		["attack", "perm_buff", 1],
		["perm_buff", "temp_buff", 1],
		["perm_buff", "attack", 3],
		["perm_buff", "temp_buff", 1],
	],
	"normal": [
		["init", "temp_buff", 1],
		["temp_buff", "attack", 3],
		["temp_buff", "temp_buff", 1],
		["attack", "perm_buff", 1],
		["perm_buff", "temp_buff", 1],
		["perm_buff", "attack", 3],
		["perm_buff", "temp_buff", 1],
	],
	"hard": [
		["init", "temp_buff", 1],
		["temp_buff", "attack", 3],
		["temp_buff", "temp_buff", 1],
		["attack", "perm_buff", 1],
		["perm_buff", "temp_buff", 1],
		["perm_buff", "attack", 3],
		["perm_buff", "temp_buff", 1],
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
			{"name": "status", "status_name": "deterioration", "value": 1, "target": "player", "positive": false, "animation": "idle"}
		],
		"temp_buff": [
			{"name": "status", "status_name": "temp_strength", "value": 12, "target": "self", "positive": true, "animation": "idle"}
		],
		"perm_buff": [
			{"name": "status", "status_name": "perm_strength", "value": 6, "target": "self", "positive": true, "animation": "idle"}
		],
		"attack": [
			{"name": "damage", "value": [6,7], "type": "regular", "animation": "atk"},
		]
	},
	"normal": {
		"init": [
			{"name": "status", "status_name": "deterioration", "value": 1, "target": "player", "positive": false, "animation": "idle"}
		],
		"temp_buff": [
			{"name": "status", "status_name": "temp_strength", "value": 15, "target": "self", "positive": true, "animation": "idle"}
		],
		"perm_buff": [
			{"name": "status", "status_name": "perm_strength", "value": 8, "target": "self", "positive": true, "animation": "idle"}
		],
		"attack": [
			{"name": "damage", "value": [6,9], "type": "regular", "animation": "atk"},
		]
	},
	"hard": {
		"init": [
			{"name": "status", "status_name": "deterioration", "value": 1, "target": "player", "positive": false, "animation": "idle"}
		],
		"temp_buff": [
			{"name": "status", "status_name": "temp_strength", "value": 20, "target": "self", "positive": true, "animation": "idle"}
		],
		"perm_buff": [
			{"name": "status", "status_name": "perm_strength", "value": 12, "target": "self", "positive": true, "animation": "idle"}
		],
		"attack": [
			{"name": "damage", "value": [7,10], "type": "regular", "animation": "atk"},
		]
	},
}


func _init():
	idle_anim_name = "stand"
	death_anim_name = "death"
	dmg_anim_name = "dmg"
#	variant_idles = [""]
