extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/EliteDodger.tscn"
var image = "res://assets/images/enemies/elite dodger/idle.png"
var name = "EN_ELITE_DODGER"
var sfx = "needler-queen"
var use_idle_sfx = false
var hp = {
	"easy": 38,
	"normal": 45,
	"hard": 65,
}
var battle_init = true
var size = "medium"
var change_phase = null
var unique_bgm = null

var states = {
	"normal": ["attack1", "buff1", "attack2", "buff2", "spawn"],
	"hard": ["attack1", "buff1", "attack2", "buff2", "spawn"],
}

var connections = {
	"normal": [
		["attack1", "attack2", 1],
		["attack1", "buff2", 2],
		["buff1", "attack2", 2],
		["buff1", "buff2", 1],
		["attack2", "spawn", 1],
		["buff2", "spawn", 1],
		["spawn", "attack1", 1],
		["spawn", "buff1", 1],
	],
	"hard": [
		["attack1", "attack2", 1],
		["attack1", "buff2", 2],
		["buff1", "attack2", 2],
		["buff1", "buff2", 1],
		["attack2", "spawn", 1],
		["buff2", "spawn", 1],
		["spawn", "attack1", 1],
		["spawn", "buff1", 1],
	],
}

var first_state = {
	"normal": ["spawn"],
	"hard": ["spawn"],
}

var actions = {
	"normal": {
		"attack1": [
			{"name": "status", "status_name": "dodge", "value": 2, "target": "self", "positive": true, "animation": "divider"},
			{"name": "damage", "value": [2, 4], "type": "regular", "animation": "atk"},
		],
		"attack2": [
			{"name": "status", "status_name": "dodge", "value": 1, "target": "self", "positive": true, "animation": "divider"},
			{"name": "damage", "value": [2, 4], "type": "regular", "animation": "atk"},
		],
		"buff1": [
			{"name": "status", "status_name": "dodge", "value": 2, "target": "self", "positive": true, "animation": "divider"},
			{"name": "status", "status_name": "perm_strength", "value": 3, "target": "self", "positive": true, "animation": ""}
		],
		"buff2": [
			{"name": "status", "status_name": "dodge", "value": 1, "target": "self", "positive": true, "animation": "divider"},
			{"name": "status", "status_name": "perm_strength", "value": 3, "target": "self", "positive": true, "animation": ""}
		],
		"spawn": [
			{"name": "status", "status_name": "dodge", "value": 2, "target": "self", "positive": true, "animation": "divider"},
			{"name": "spawn", "enemy": "baby_slasher", "animation": "divider"},
			{"name": "spawn", "enemy": "baby_slasher", "animation": "divider"},
		],
	},
	"hard": {
		"attack1": [
			{"name": "status", "status_name": "dodge", "value": 2, "target": "self", "positive": true, "animation": "divider"},
			{"name": "damage", "value": [2, 4], "type": "regular", "animation": "atk"},
		],
		"attack2": [
			{"name": "status", "status_name": "dodge", "value": 1, "target": "self", "positive": true, "animation": "divider"},
			{"name": "damage", "value": [2, 4], "type": "regular", "animation": "atk"},
		],
		"buff1": [
			{"name": "status", "status_name": "dodge", "value": 2, "target": "self", "positive": true, "animation": "divider"},
			{"name": "status", "status_name": "perm_strength", "value": 3, "target": "self", "positive": true, "animation": ""}
		],
		"buff2": [
			{"name": "status", "status_name": "dodge", "value": 1, "target": "self", "positive": true, "animation": "divider"},
			{"name": "status", "status_name": "perm_strength", "value": 8, "target": "self", "positive": true, "animation": ""}
		],
		"spawn": [
			{"name": "status", "status_name": "dodge", "value": 3, "target": "self", "positive": true, "animation": "divider"},
			{"name": "spawn", "enemy": "baby_slasher", "animation": "divider"},
			{"name": "spawn", "enemy": "baby_slasher", "animation": "divider"},
		],
	},
}


func _init():
	idle_anim_name = "stand"
	death_anim_name = "death"
	dmg_anim_name = "dmg"
