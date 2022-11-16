extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Confuser.tscn"
var image = "res://assets/images/enemies/confuser/idle.png"
var name = "EN_CONFUSER"
var sfx = "confuser"
var use_idle_sfx = false
var hp = {
	"normal": 315,
	"hard": 315,
}
var battle_init = true
var size = "medium"
var change_phase = null
var unique_bgm = null

var states = {
	"normal": ["init", "attack1", "attack2", "defend1", "defend2"],
	"hard": ["init", "attack1", "attack2", "defend1", "defend2"],
}

var connections = {
	"normal": [
		["init", "attack1", 1],
		["init", "attack2", 1],
		["attack1", "attack2", 1],
		["attack1", "defend2", 1],
		["defend1", "attack2", 1],
		["defend1", "defend2", 1],
		["attack2", "attack1", 1],
		["attack2", "defend1", 1],
		["defend2", "attack1", 1],
		["defend2", "defend1", 1],
	],
	"hard": [
		["init", "attack1", 1],
		["init", "attack2", 1],
		["attack1", "attack2", 1],
		["attack1", "defend2", 1],
		["defend1", "attack2", 1],
		["defend1", "defend2", 1],
		["attack2", "attack1", 1],
		["attack2", "defend1", 1],
		["defend2", "attack1", 1],
		["defend2", "defend1", 1],
	],
}

var first_state = {
	"normal": ["init"],
	"hard": ["init"],
}

var actions = {
	"normal": {
		"init": [
			{"name": "status", "status_name": "confusion", "value": 1, "target": "player", "positive": false, "animation": ""}
		],
		"attack1": [
			{"name": "damage", "value": [2, 4], "amount": 3, "type": "venom", "animation": "02_atk"}
		],
		"attack2": [
			{"name": "damage", "value": [5, 7], "amount": 2, "type": "venom", "animation": "02_atk"}
		],
		"defend1": [
			{"name": "shield", "value": [12, 30], "animation": ""},
			{"name": "status", "status_name": "perm_strength", "value": 5, "target": "self", "positive": true, "animation": ""},
		],
		"defend2": [
			{"name": "shield", "value": [15, 25], "animation": ""},
			{"name": "status", "status_name": "poison", "value": [3, 6], "target": "player", "positive": false, "animation": "02_atk"}
		],
	},
	"hard": {
		"init": [
			{"name": "status", "status_name": "confusion", "value": 1, "target": "player", "positive": false, "animation": ""}
		],
		"attack1": [
			{"name": "damage", "value": [2, 4], "amount": 3, "type": "venom", "animation": "02_atk"}
		],
		"attack2": [
			{"name": "damage", "value": [5, 7], "amount": 2, "type": "venom", "animation": "02_atk"}
		],
		"defend1": [
			{"name": "shield", "value": [12, 30], "animation": ""},
			{"name": "status", "status_name": "perm_strength", "value": 5, "target": "self", "positive": true, "animation": ""},
		],
		"defend2": [
			{"name": "shield", "value": [15, 25], "animation": ""},
			{"name": "status", "status_name": "poison", "value": [3, 6], "target": "player", "positive": false, "animation": "02_atk"}
		],
	},
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
