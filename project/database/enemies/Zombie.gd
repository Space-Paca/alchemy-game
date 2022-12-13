extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Zombie.tscn"
var image = "res://assets/images/enemies/zombie/idle.png"
var name = "EN_ZOMBIE"
var sfx = "zombie"
var use_idle_sfx = false
var hp = {
	"easy": 50,
	"normal": 60,
	"hard": 70,
}
var battle_init = true
var size = "small"
var change_phase = null
var unique_bgm = null

var states = {
	"easy": ["init", "drain", "attack"],
	"normal": ["init", "drain", "attack"],
	"hard": ["init", "drain", "attack"],
}

var connections = {
	"easy": [
		["init", "attack", 1],
		["init", "drain", 1],
		["attack", "attack", 2],
		["attack", "drain", 1],
		["drain", "attack", 3],
		["drain", "drain", 1],
	],
	"normal": [
		["init", "attack", 1],
		["init", "drain", 1],
		["attack", "attack", 2],
		["attack", "drain", 1],
		["drain", "attack", 3],
		["drain", "drain", 1],
	],
	"hard": [
		["init", "attack", 1],
		["init", "drain", 1],
		["attack", "attack", 2],
		["attack", "drain", 1],
		["drain", "attack", 3],
		["drain", "drain", 1],
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
			{"name": "status", "status_name": "poison_immunity", "value": 1, "target": "self", "positive": true, "animation": ""}
		],
		"drain": [
			{"name": "drain", "value": [12, 17], "animation": "02_Atk"}
		],
		"attack": [
			{"name": "damage", "value": [18,25], "type": "regular", "animation": "02_Atk"}
		],
	},
	"normal": {
		"init": [
			{"name": "status", "status_name": "poison_immunity", "value": 1, "target": "self", "positive": true, "animation": ""}
		],
		"drain": [
			{"name": "drain", "value": [15, 20], "animation": "02_Atk"}
		],
		"attack": [
			{"name": "damage", "value": [20,30], "type": "regular", "animation": "02_Atk"}
		],
	},
	"hard": {
		"init": [
			{"name": "status", "status_name": "poison_immunity", "value": 1, "target": "self", "positive": true, "animation": ""}
		],
		"drain": [
			{"name": "drain", "value": [20, 25], "animation": "02_Atk"}
		],
		"attack": [
			{"name": "damage", "value": [20,40], "type": "regular", "animation": "02_Atk"}
		],
	},
}


func _init():
	idle_anim_name = "01_Idle"
	death_anim_name = "04_Death"
	dmg_anim_name = "03_Dmg"
