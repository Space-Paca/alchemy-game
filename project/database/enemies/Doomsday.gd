extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Doomsday.tscn"
var image = "res://assets/images/enemies/doomsayer/idle.png"
var name = "EN_DOOMSDAY"
var sfx = "doomsayer"
var use_idle_sfx = false
var hp = {
	"easy": 480,
	"normal": 560,
	"hard": 600,
}
var battle_init = true
var size = "big"
var change_phase = null
var unique_bgm = null

var states = {
	"normal": ["init", "attack1", "attack2", "doom", "dodge"],
	"hard": ["init", "attack1", "attack2", "doom", "dodge"],
}

var connections = {
	"normal": [
		["init", "attack1", 1],
		["init", "attack2", 1],
		["attack1", "attack2", 3],
		["attack1", "doom", 2],
		["attack1", "dodge", 2],
		["attack2", "attack1", 3],
		["attack2", "doom", 2],
		["attack2", "dodge", 2],
		["doom", "attack1", 2],
		["doom", "attack2", 2],
		["doom", "dodge", 1],
		["dodge", "attack1", 2],
		["dodge", "attack2", 2],
		["dodge", "doom", 1],
	],
	"hard": [
		["init", "attack1", 1],
		["init", "attack2", 1],
		["attack1", "attack2", 3],
		["attack1", "doom", 2],
		["attack1", "dodge", 2],
		["attack2", "attack1", 3],
		["attack2", "doom", 2],
		["attack2", "dodge", 2],
		["doom", "attack1", 2],
		["doom", "attack2", 2],
		["doom", "dodge", 1],
		["dodge", "attack1", 2],
		["dodge", "attack2", 2],
		["dodge", "doom", 1],
	],
}

var first_state = {
	"normal": ["init"],
	"hard": ["init"],
}

var actions = {
	"normal": {
		"init": [
			{"name": "status", "status_name": "impending_doom", "value": 99, "target": "self", "positive": true, "animation": ""}
		],
		"attack1": [
			{"name": "damage", "value": [30, 50], "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "impending_doom", "value": [4,5], "target": "self", "positive": true, "reduce": true, "animation": ""}
		],
		"attack2": [
			{"name": "damage", "value": [4, 7], "amount": 7, "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "impending_doom", "value": [4,5], "target": "self", "positive": true, "reduce": true, "animation": ""}
		],
		"doom": [
			{"name": "status", "status_name": "impending_doom", "value": [15,20], "target": "self", "positive": true, "reduce": true, "animation": ""}
		],
		"dodge": [
			{"name": "status", "status_name": "impending_doom", "value": [8,12], "target": "self", "positive": true, "reduce": true, "animation": ""},
			{"name": "status", "status_name": "dodge", "value": 4, "target": "self", "positive": true, "animation": "03_dmg"}
		],
	},
	"hard": {
		"init": [
			{"name": "status", "status_name": "impending_doom", "value": 69, "target": "self", "positive": true, "animation": ""}
		],
		"attack1": [
			{"name": "damage", "value": [30, 50], "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "impending_doom", "value": [4,5], "target": "self", "positive": true, "reduce": true, "animation": ""}
		],
		"attack2": [
			{"name": "damage", "value": [4, 7], "amount": 7, "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "impending_doom", "value": [4,5], "target": "self", "positive": true, "reduce": true, "animation": ""}
		],
		"doom": [
			{"name": "status", "status_name": "impending_doom", "value": [15,20], "target": "self", "positive": true, "reduce": true, "animation": ""}
		],
		"dodge": [
			{"name": "status", "status_name": "impending_doom", "value": [8,12], "target": "self", "positive": true, "reduce": true, "animation": ""},
			{"name": "status", "status_name": "dodge", "value": 4, "target": "self", "positive": true, "animation": "03_dmg"}
		],
	},
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
