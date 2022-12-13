extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/BabySlasher.tscn"
var image = "res://assets/images/enemies/small piercing/idle.png"
var name = "EN_BABY_SLASHER"
var sfx = "needler-spawn"
var use_idle_sfx = false
var hp = {
	"easy": 4,
	"normal": 5,
	"hard": 8,
}
var battle_init = false
var size = "small"
var change_phase = null
var unique_bgm = null

var states = {
	"easy": ["attack"],
	"normal": ["attack"],
	"hard": ["attack"],
}

var connections = {
	"easy": [
		["attack", "attack", 1],
	],
	"normal": [
		["attack", "attack", 1],
	],
	"hard": [
		["attack", "attack", 1],
	],
}

var first_state = {
	"easy": ["attack"],
	"normal": ["attack"],
	"hard": ["attack"],
}

var actions = {
	"easy": {
		"attack": [
			{"name": "damage", "value": 2, "type": "piercing", "animation": "atk"}
		]
	},
	"normal": {
		"attack": [
			{"name": "damage", "value": [2,3], "type": "piercing", "animation": "atk"}
		]
	},
	"hard": {
		"attack": [
			{"name": "shield", "value": [2,5], "animation": ""},
			{"name": "damage", "value": [3,5], "type": "piercing", "animation": "atk"}
		]
	},
}


func _init():
	idle_anim_name = "stand"
	death_anim_name = "death"
	dmg_anim_name = "dmg"
