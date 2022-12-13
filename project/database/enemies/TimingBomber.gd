extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/TimingBomber.tscn"
var image = "res://assets/images/enemies/timing bomber/idle.png"
var name = "EN_TIMING_BOMBER"
var sfx = "bomber"
var use_idle_sfx = false
var hp = {
	"easy": 187,
	"normal": 202,
	"hard": 242,
}
var battle_init = true
var size = "medium"
var change_phase = null
var unique_bgm = null

var states = {
	"easy": ["init", "bomb-time", "attack", "defend", "big-attack"],
	"normal": ["init", "bomb-time", "attack", "defend", "big-attack"],
	"hard": ["init", "bomb-time", "attack", "defend", "big-attack"],
}

var connections = {
	"easy": [
		["init", "attack", 1],
		["init", "defend", 1],
		["attack", "bomb-time", 1],
		["attack", "defend", 1],
		["big-attack", "bomb-time", 1],
		["big-attack", "defend", 1],
		["defend", "attack", 4],
		["defend", "big-attack", 3],
		["defend", "bomb-time", 4],
		["bomb-time", "attack", 4],
		["bomb-time", "big-attack", 3],
		["bomb-time", "defend", 4]  
	],
	"normal": [
		["init", "attack", 1],
		["init", "defend", 1],
		["attack", "bomb-time", 1],
		["attack", "defend", 1],
		["big-attack", "bomb-time", 1],
		["big-attack", "defend", 1],
		["defend", "attack", 4],
		["defend", "big-attack", 3],
		["defend", "bomb-time", 4],
		["bomb-time", "attack", 4],
		["bomb-time", "big-attack", 3],
		["bomb-time", "defend", 4]  
	],
	"hard": [
		["init", "attack", 1],
		["init", "defend", 1],
		["attack", "bomb-time", 1],
		["attack", "defend", 1],
		["big-attack", "bomb-time", 1],
		["big-attack", "defend", 1],
		["defend", "attack", 4],
		["defend", "big-attack", 3],
		["defend", "bomb-time", 4],
		["bomb-time", "attack", 4],
		["bomb-time", "big-attack", 3],
		["bomb-time", "defend", 4]  
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
			{"name": "status", "status_name": "time_bomb", "value": 4, "target": "player", "positive": false, "animation": "taunt2"}
		],
		"bomb-time": [
			{"name": "status", "status_name": "time_bomb", "value": 6, "target": "player", "positive": false, "animation": "taunt2"}
		],
		"attack": [
			{"name": "status", "status_name": "time_bomb", "value": 3, "target": "player", "positive": false, "animation": "taunt2"},
			{"name": "damage", "value": [12,13], "type": "regular", "animation": "atk"},
		],
		"big-attack": [
			{"name": "status", "status_name": "time_bomb", "value": 2, "target": "player", "positive": false, "animation": "taunt2"},
			{"name": "damage", "value": [15,20], "type": "regular", "animation": "atk"},
		],
		"defend": [
			{"name": "status", "status_name": "time_bomb", "value": 3, "target": "player", "positive": false, "animation": "taunt2"},
			{"name": "shield", "value": [12,13], "animation": "atk"}
		],
	},
	"normal": {
		"init": [
			{"name": "status", "status_name": "time_bomb", "value": 4, "target": "player", "positive": false, "animation": "taunt2"}
		],
		"bomb-time": [
			{"name": "status", "status_name": "time_bomb", "value": 8, "target": "player", "positive": false, "animation": "taunt2"}
		],
		"attack": [
			{"name": "status", "status_name": "time_bomb", "value": 3, "target": "player", "positive": false, "animation": "taunt2"},
			{"name": "damage", "value": [15,17], "type": "regular", "animation": "atk"},
		],
		"big-attack": [
			{"name": "status", "status_name": "time_bomb", "value": 2, "target": "player", "positive": false, "animation": "taunt2"},
			{"name": "damage", "value": [19,25], "type": "regular", "animation": "atk"},
		],
		"defend": [
			{"name": "status", "status_name": "time_bomb", "value": 4, "target": "player", "positive": false, "animation": "taunt2"},
			{"name": "shield", "value": [14,15], "animation": "atk"}
		],
	},
	"hard": {
		"init": [
			{"name": "status", "status_name": "time_bomb", "value": 6, "target": "player", "positive": false, "animation": "taunt2"}
		],
		"bomb-time": [
			{"name": "status", "status_name": "time_bomb", "value": 10, "target": "player", "positive": false, "animation": "taunt2"}
		],
		"attack": [
			{"name": "status", "status_name": "time_bomb", "value": 5, "target": "player", "positive": false, "animation": "taunt2"},
			{"name": "damage", "value": [15,17], "type": "regular", "animation": "atk"},
		],
		"big-attack": [
			{"name": "status", "status_name": "time_bomb", "value": 3, "target": "player", "positive": false, "animation": "taunt2"},
			{"name": "damage", "value": [19,35], "type": "regular", "animation": "atk"},
		],
		"defend": [
			{"name": "status", "status_name": "time_bomb", "value": 6, "target": "player", "positive": false, "animation": "taunt2"},
			{"name": "shield", "value": [14,25], "animation": "atk"}
		],
	},
}


func _init():
	idle_anim_name = "stand"
	death_anim_name = "death2"
	dmg_anim_name = "dmg2"
	entry_anim_name = "enter"
	variant_idles = ["idle", "idle2"]
