extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Boss1.tscn"
var image = "res://assets/images/enemies/boss1/idle.png"
var name = "EN_BOSS_1"
var sfx = "boss-1"
var use_idle_sfx = false
var hp = {
	"easy": 150,
	"normal": 170,
	"hard": 230,
}
var battle_init = true
var size = "big"
var change_phase = null
var unique_bgm = null

var states = {
	"normal": ["init", "start", "attack1", "attack2", "buff-reagent"],
	"hard": ["init", "start", "attack1", "attack2", "buff-reagent"],
}

var connections = {
	"normal": [
		["init", "start", 1],
		["start", "attack1", 1],
		["attack1", "attack2", 1],
		["attack2", "buff-reagent", 1],
		["buff-reagent", "attack1", 1],
	],
	"hard": [
		["init", "start", 1],
		["start", "attack1", 1],
		["attack1", "attack2", 1],
		["attack2", "buff-reagent", 1],
		["buff-reagent", "attack1", 1],
	],
}

var first_state = {
	"normal": ["init"],
	"hard": ["init"],
}

var actions = {
	"normal": {
		"init": [
			{"name": "status", "status_name": "arcane_aegis", "value": 6, "target": "self", "positive": true, "animation": ""}
		],
		"start": [
			{"name": "add_reagent", "type": "trash", "value": 6, "animation": "atk 2"}
		],
		"attack1": [
			{"name": "damage", "value": 2, "type": "regular", "amount": 2, "animation": "atk 1"},
		],
		"attack2": [
			{"name": "damage", "value": 2, "type": "regular", "amount": 3, "animation": "atk 1"},
		],
		"buff-reagent": [
			{"name": "status", "status_name": "perm_strength", "value": 3, "target": "self", "positive": true, "animation": ""},
			{"name": "add_reagent", "type": "trash", "value": 6, "animation": "atk 2"}
		]
	},
	"hard": {
		"init": [
			{"name": "status", "status_name": "arcane_aegis", "value": 20, "target": "self", "positive": true, "animation": ""}
		],
		"start": [
			{"name": "add_reagent", "type": "trash", "value": 8, "animation": "atk 2"}
		],
		"attack1": [
			{"name": "damage", "value": 2, "type": "regular", "amount": 2, "animation": "atk 1"},
		],
		"attack2": [
			{"name": "damage", "value": 2, "type": "regular", "amount": 3, "animation": "atk 1"},
		],
		"buff-reagent": [
			{"name": "status", "status_name": "perm_strength", "value": 5, "target": "self", "positive": true, "animation": ""},
			{"name": "add_reagent", "type": "trash", "value": 8, "animation": "atk 2"}
		]
	},
}


func _init():
	idle_anim_name = "01_stand"
	death_anim_name = "death"
	dmg_anim_name = "dmg"

