extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Curser.tscn"
var image = "res://assets/images/enemies/curser/idle.png"
var name = "EN_CURSER"
var sfx = "curser"
var use_idle_sfx = false
var hp = {
	"normal": 100,
	"hard": 120,
}
var battle_init = true
var size = "medium"
var change_phase = null
var unique_bgm = null

var states = {
	"normal": ["init", "attack", "debuff"],
	"hard": ["init", "attack", "debuff"],
}

var connections = {
	"normal": [
		["init", "attack", 1],
		["init", "debuff", 1],
		["attack", "attack", 2],
		["attack", "debuff", 1],
		["debuff", "attack", 1],
	],
	"hard": [
		["init", "attack", 1],
		["init", "debuff", 1],
		["attack", "attack", 2],
		["attack", "debuff", 1],
		["debuff", "attack", 1],
	],
}

var first_state = {
	"normal": ["init"],
	"hard": ["init"],
}

var actions = {
	"normal": {
		"init": [
			{"name": "status", "status_name": "curse", "value": 3, "target": "player", "positive": false, "animation": "02_atk"}
		],
		"attack": [
			{"name": "damage", "value": [8, 15], "type": "regular", "animation": "02_atk"}
		],
		"debuff": [
			{"name": "shield", "value": [5, 18], "animation": ""},
			{"name": "status", "status_name": "weakness", "value": 1, "target": "player", "positive": false, "animation": "02_atk"}
		],
	},
	"hard": {
		"init": [
			{"name": "status", "status_name": "curse", "value": 2, "target": "player", "positive": false, "animation": "02_atk"}
		],
		"attack": [
			{"name": "damage", "value": [10, 16], "type": "regular", "animation": "02_atk"}
		],
		"debuff": [
			{"name": "shield", "value": [7, 20], "animation": ""},
			{"name": "status", "status_name": "weakness", "value": 1, "target": "player", "positive": false, "animation": "02_atk"}
		],
	},
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
