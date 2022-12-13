extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Healer.tscn"
var image = "res://assets/images/enemies/healer/idle.png"
var name = "EN_HEALER"
var sfx = "healer"
var use_idle_sfx = false
var hp = {
	"easy": 165,
	"normal": 170,
	"hard": 175,
}
var battle_init = true
var size = "small"
var change_phase = null
var unique_bgm = null

var states = {
	"easy": ["attack", "defend", "heal", "init"],
	"normal": ["attack", "defend", "heal", "init"],
	"hard": ["attack", "defend", "heal", "init"],
}

var connections = {
	"easy": [
		["init", "attack", 1],
		["init", "defend", 1],  
		["heal", "attack", 1],
		["heal", "defend", 1],
		["attack", "attack", 1],
		["attack", "defend", 1],
		["attack", "heal", 2],
		["defend", "attack", 1],
		["defend", "defend", 1],
		["defend", "heal", 2],
	],
	"normal": [
		["init", "attack", 1],
		["init", "defend", 1],  
		["heal", "attack", 1],
		["heal", "defend", 1],
		["attack", "attack", 1],
		["attack", "defend", 1],
		["attack", "heal", 2],
		["defend", "attack", 1],
		["defend", "defend", 1],
		["defend", "heal", 2],
	],
	"hard": [
		["init", "attack", 1],
		["init", "defend", 1],  
		["heal", "attack", 1],
		["heal", "defend", 1],
		["attack", "attack", 1],
		["attack", "defend", 1],
		["attack", "heal", 2],
		["defend", "attack", 1],
		["defend", "defend", 1],
		["defend", "heal", 2],
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
			{"name": "shield", "value": 40, "animation": ""},
		],
		"attack": [
			{"name": "damage", "value": 20, "type": "regular", "animation": "02_atk"},
			{"name": "heal", "value": [10,15], "target": "all_enemies", "animation": "02_atk"},
		],
		"defend": [
			{"name": "shield", "value": [10, 50], "animation": "02_atk"},
			{"name": "heal", "value": [10,15], "target": "all_enemies", "animation": "02_atk"},
		],
		"heal": [
			{"name": "heal", "value": [18,25], "target": "all_enemies", "animation": "02_atk"},
			{"name": "status", "status_name": "perm_strength", "value": 6, "target": "self", "positive": true, "animation": ""},
		],
	},
	"normal": {
		"init": [
			{"name": "shield", "value": 50, "animation": ""},
		],
		"attack": [
			{"name": "damage", "value": 20, "type": "regular", "animation": "02_atk"},
			{"name": "heal", "value": [10,20], "target": "all_enemies", "animation": "02_atk"},
		],
		"defend": [
			{"name": "shield", "value": [10, 50], "animation": "02_atk"},
			{"name": "heal", "value": [10,20], "target": "all_enemies", "animation": "02_atk"},
		],
		"heal": [
			{"name": "heal", "value": [20,30], "target": "all_enemies", "animation": "02_atk"},
			{"name": "status", "status_name": "perm_strength", "value": 8, "target": "self", "positive": true, "animation": ""},
		],
	},
	"hard": {
		"init": [
			{"name": "shield", "value": 60, "animation": ""},
		],
		"attack": [
			{"name": "damage", "value": 20, "type": "regular", "animation": "02_atk"},
			{"name": "heal", "value": [20,30], "target": "all_enemies", "animation": "02_atk"},
		],
		"defend": [
			{"name": "shield", "value": [10, 50], "animation": "02_atk"},
			{"name": "heal", "value": [20,30], "target": "all_enemies", "animation": "02_atk"},
		],
		"heal": [
			{"name": "heal", "value": [30,40], "target": "all_enemies", "animation": "02_atk"},
			{"name": "status", "status_name": "perm_strength", "value": 10, "target": "self", "positive": true, "animation": ""},
		],
	},
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
