extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Necromancer.tscn"
var image = "res://assets/images/enemies/necromancer/idle.png"
var name = "EN_NECROMANCER"
var sfx = "necromancer"
var use_idle_sfx = false
var hp = {
	"easy": 180,
	"normal": 180,
	"hard": 220,
}
var battle_init = true
var size = "medium"
var change_phase = null
var unique_bgm = null

var states = {
	"normal": ["init", "spawn", "attack1", "attack2", "defense", "debuff"],
	"hard": ["init", "spawn", "attack1", "attack2", "defense", "debuff"],
}

var connections = {
	"normal": [
		["init", "spawn", 1],
		["spawn", "attack1", 1],
		["spawn", "defense", 1],
		["attack1", "debuff", 2],
		["attack1", "attack2", 2],
		["defense", "debuff", 1],
		["defense", "attack2", 1],
		["attack2", "spawn", 1],
		["debuff", "spawn", 1],
	],
	"hard": [
		["init", "spawn", 1],
		["spawn", "attack1", 1],
		["spawn", "defense", 1],
		["attack1", "debuff", 2],
		["attack1", "attack2", 2],
		["defense", "debuff", 1],
		["defense", "attack2", 1],
		["attack2", "spawn", 1],
		["debuff", "spawn", 1],
	],
}

var first_state = {
	"normal": ["init"],
	"hard": ["init"],
}

var actions = {
	"normal": {
		"init": [
			{"name": "status", "status_name": "deep_wound", "value": 1, "target": "player", "positive": false, "animation": ""}
		],
		"attack1": [
			{"name": "damage", "value": [30, 35], "type": "regular", "animation": "02_atk"}
		],
		"attack2": [
			{"name": "damage", "value": [30, 35], "type": "regular", "animation": "02_atk"}
		],
		"defense": [
			{"name": "damage", "value": [20, 22], "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [30, 45], "animation": ""}
		],
		"debuff": [
			{"name": "damage", "value": [20, 22], "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "weakness", "value": 2, "target": "player", "positive": false, "animation": ""}
		],
		"spawn": [
			{"name": "shield", "value": [25, 35], "animation": ""},
			{"name": "spawn", "enemy": "zombie", "minion": true, "animation": ""},
		],
	},
	"hard": {
		"init": [
			{"name": "status", "status_name": "deep_wound", "value": 1, "target": "player", "positive": false, "animation": ""}
		],
		"attack1": [
			{"name": "damage", "value": [35, 40], "type": "regular", "animation": "02_atk"}
		],
		"attack2": [
			{"name": "damage", "value": [35, 40], "type": "regular", "animation": "02_atk"}
		],
		"defense": [
			{"name": "damage", "value": [25, 30], "type": "regular", "animation": "02_atk"},
			{"name": "shield", "value": [40, 45], "animation": ""}
		],
		"debuff": [
			{"name": "damage", "value": [25, 30], "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "weakness", "value": 2, "target": "player", "positive": false, "animation": ""}
		],
		"spawn": [
			{"name": "shield", "value": [30, 40], "animation": ""},
			{"name": "spawn", "enemy": "zombie", "minion": true, "animation": ""},
		],
	},
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
