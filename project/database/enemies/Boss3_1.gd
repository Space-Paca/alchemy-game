extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Boss3-1.tscn"
var image = "res://assets/images/enemies/boss3-1/idle.png"
var name = "EN_BOSS_3_1"
var sfx = "boss-3-1"
var use_idle_sfx = false
var hp = {
	"easy": 550,
	"normal": 600,
	"hard": 700,
}
var battle_init = false
var size = "big"
var change_phase = "boss_3_2"
var unique_bgm = null

var states = {
	"easy": ["start", "attack1", "attack2", "attack3", "attack4", "attack5-1", \
			  "attack5-2", "buff1", "buff2", "buff3", "buff3", "buff4", "buff5"],
	"normal": ["start", "attack1", "attack2", "attack3", "attack4", "attack5-1", \
			  "attack5-2", "buff1", "buff2", "buff3", "buff3", "buff4", "buff5"],
	"hard": ["start", "attack1", "attack2", "attack3", "attack4", "attack5-1", \
			  "attack5-2", "buff1", "buff2", "buff3", "buff3", "buff4", "buff5"],
}

var connections = {
	"easy": [
		["start", "buff1", 1],
		["buff1", "attack1", 1],
		["attack1", "buff2", 1],
		["buff2", "attack2", 1],
		["attack2", "buff3", 1],
		["buff3", "attack3", 1],
		["attack3", "buff4", 1],
		["buff4", "attack5-1", 1],
		["attack5-1", "buff5", 1],
		["attack5-2", "buff5", 1],
		["buff5", "attack5-1", 1],
		["buff5", "attack5-2", 1],
	],
	"normal": [
		["start", "buff1", 1],
		["buff1", "attack1", 1],
		["attack1", "buff2", 1],
		["buff2", "attack2", 1],
		["attack2", "buff3", 1],
		["buff3", "attack3", 1],
		["attack3", "buff4", 1],
		["buff4", "attack5-1", 1],
		["attack5-1", "buff5", 1],
		["attack5-2", "buff5", 1],
		["buff5", "attack5-1", 1],
		["buff5", "attack5-2", 1],
	],
	"hard": [
		["start", "buff1", 1],
		["buff1", "attack1", 1],
		["attack1", "buff2", 1],
		["buff2", "attack2", 1],
		["attack2", "buff3", 1],
		["buff3", "attack3", 1],
		["attack3", "buff4", 1],
		["buff4", "attack5-1", 1],
		["attack5-1", "buff5", 1],
		["attack5-2", "buff5", 1],
		["buff5", "attack5-1", 1],
		["buff5", "attack5-2", 1],
	],
}

var first_state = {
	"easy": ["start"],
	"normal": ["start"],
	"hard": ["start"],
}

var actions = {
	"easy": {
		"start": [
			{"name": "damage", "value": 70, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [40,60], "type": "regular", "animation": ""},
		],
		"buff1": [
			{"name": "damage", "value": 30, "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "concentration", "value": 40, "target": "self", "positive": false, "animation": ""},
		],
		"attack1": [
			{"name": "damage", "value": [22,25], "amount":2, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [40,60], "type": "regular", "animation": ""},
		],
		"buff2": [
			{"name": "damage", "value": 30, "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "concentration", "value": 60, "target": "self", "positive": false, "animation": ""},
		],
		"attack2": [
			{"name": "damage", "value": [22,25], "amount":2, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [40,60], "type": "regular", "animation": ""},
		],
		"buff3": [
			{"name": "damage", "value": 30, "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "concentration", "value": 70, "target": "self", "positive": false, "animation": ""},
		],
		"attack3": [
			{"name": "damage", "value": [32,35], "amount":3, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [40,60], "type": "regular", "animation": ""},
		],
		"buff4": [
			{"name": "damage", "value": 30, "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "concentration", "value": 80, "target": "self", "positive": false, "animation": ""},
		],
		"attack4": [
			{"name": "damage", "value": [32,35], "amount":3, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [40,60], "type": "regular", "animation": ""},
		],
		"buff5": [
			{"name": "status", "status_name": "concentration", "value": 90, "target": "self", "positive": false, "animation": "02_atk"},
			{"name": "status", "status_name": "perm_strength", "value": 16, "target": "self", "positive": true, "animation": ""},
		],
		"attack5-1": [
			{"name": "damage", "value": 90, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": 70, "type": "regular", "animation": ""},
		],
		"attack5-2": [
			{"name": "damage", "value": [8,10], "amount":3, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": 70, "type": "regular", "animation": ""},
		],
		
	},
	"normal": {
		"start": [
			{"name": "damage", "value": 80, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [50,70], "type": "regular", "animation": ""},
		],
		"buff1": [
			{"name": "damage", "value": 30, "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "concentration", "value": 50, "target": "self", "positive": false, "animation": ""},
		],
		"attack1": [
			{"name": "damage", "value": [28,30], "amount":2, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [50,70], "type": "regular", "animation": ""},
		],
		"buff2": [
			{"name": "damage", "value": 30, "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "concentration", "value": 70, "target": "self", "positive": false, "animation": ""},
		],
		"attack2": [
			{"name": "damage", "value": [28,30], "amount":2, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [50,70], "type": "regular", "animation": ""},
		],
		"buff3": [
			{"name": "damage", "value": 30, "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "concentration", "value": 80, "target": "self", "positive": false, "animation": ""},
		],
		"attack3": [
			{"name": "damage", "value": [38,40], "amount":3, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [50,70], "type": "regular", "animation": ""},
		],
		"buff4": [
			{"name": "damage", "value": 30, "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "concentration", "value": 90, "target": "self", "positive": false, "animation": ""},
		],
		"attack4": [
			{"name": "damage", "value": [38,40], "amount":3, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [50,70], "type": "regular", "animation": ""},
		],
		"buff5": [
			{"name": "status", "status_name": "concentration", "value": 100, "target": "self", "positive": false, "animation": "02_atk"},
			{"name": "status", "status_name": "perm_strength", "value": 20, "target": "self", "positive": true, "animation": ""},
		],
		"attack5-1": [
			{"name": "damage", "value": 100, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": 70, "type": "regular", "animation": ""},
		],
		"attack5-2": [
			{"name": "damage", "value": [8,12], "amount":3, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": 70, "type": "regular", "animation": ""},
		],
		
	},
	"hard": {
		"start": [
			{"name": "damage", "value": 100, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [60,70], "type": "regular", "animation": ""},
		],
		"buff1": [
			{"name": "damage", "value": 30, "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "concentration", "value": 50, "target": "self", "positive": false, "animation": ""},
		],
		"attack1": [
			{"name": "damage", "value": [28,30], "amount":2, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [60,70], "type": "regular", "animation": ""},
		],
		"buff2": [
			{"name": "damage", "value": 30, "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "concentration", "value": 70, "target": "self", "positive": false, "animation": ""},
		],
		"attack2": [
			{"name": "damage", "value": [28,30], "amount":2, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [60,70], "type": "regular", "animation": ""},
		],
		"buff3": [
			{"name": "damage", "value": 30, "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "concentration", "value": 100, "target": "self", "positive": false, "animation": ""},
		],
		"attack3": [
			{"name": "damage", "value": [38,40], "amount":3, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [60,70], "type": "regular", "animation": ""},
		],
		"buff4": [
			{"name": "damage", "value": 30, "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "concentration", "value": 110, "target": "self", "positive": false, "animation": ""},
		],
		"attack4": [
			{"name": "damage", "value": [38,40], "amount":3, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [60,70], "type": "regular", "animation": ""},
		],
		"buff5": [
			{"name": "status", "status_name": "concentration", "value": 120, "target": "self", "positive": false, "animation": "02_atk"},
			{"name": "status", "status_name": "perm_strength", "value": 25, "target": "self", "positive": true, "animation": ""},
		],
		"attack5-1": [
			{"name": "damage", "value": 100, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": 100, "type": "regular", "animation": ""},
		],
		"attack5-2": [
			{"name": "damage", "value": [8,12], "amount":3, "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": 100, "type": "regular", "animation": ""},
		],
		
	},
}

func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
