extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Parasiter.tscn"
var image = "res://assets/images/enemies/parasiter/idle.png"
var name = "EN_PARASITER"
var sfx = "parasiter"
var use_idle_sfx = false
var hp = {
	"easy": 125,
	"normal": 125,
	"hard": 125,
}
var battle_init = true
var size = "medium"
var change_phase = null
var unique_bgm = null

var states = {
	"normal": ["init", "drain", "attack"],
	"hard": ["init", "drain", "attack"],
}

var connections = {
	"normal": [
		["init", "attack", 1],
		["init", "drain", 1],
		["attack", "attack", 1],
		["attack", "drain", 2],
		["drain", "attack", 3],
		["drain", "drain", 1],
	],
	"hard": [
		["init", "attack", 1],
		["init", "drain", 1],
		["attack", "attack", 1],
		["attack", "drain", 2],
		["drain", "attack", 3],
		["drain", "drain", 1],
	],
}

var first_state = {
	"normal": ["init"],
	"hard": ["init"],
}

var actions = {
	"normal": {
		"init": [
			{"name": "status", "status_name": "hex", "value": 2, "target": "self", "positive": true, "animation": "02_atk"}
		],
		"drain": [
			{"name": "drain", "value": [15, 22], "animation": "02_atk"}
		],
		"attack": [
			{"name": "damage", "value": [5,8], "amount": [2,4], "type": "regular", "animation": "02_atk"}
		],
	},
	"hard": {
		"init": [
			{"name": "status", "status_name": "hex", "value": 2, "target": "self", "positive": true, "animation": "02_atk"}
		],
		"drain": [
			{"name": "drain", "value": [15, 22], "animation": "02_atk"}
		],
		"attack": [
			{"name": "damage", "value": [5,8], "amount": [2,4], "type": "regular", "animation": "02_atk"}
		],
	},
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
