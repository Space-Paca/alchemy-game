extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/SpawnerOoze.tscn"
var image = "res://assets/images/enemies/spawner poison enemy/idle.png"
var name = "EN_SPAWNER_OOZE"
var sfx = "ooze"
var use_idle_sfx = false
var hp = {
	"normal": 25,
	"hard": 25,
}
var battle_init = true
var size = "small"
var change_phase = null
var unique_bgm = null

var states = {
	"normal": ["init", "attack", "defend", "spawn", "poison"],
	"hard": ["init", "attack", "defend", "spawn", "poison"],
}

var connections = {
	"normal": [
		["init", "attack", 1],
		["init", "defend", 1],
		["attack", "defend", 5],
		["attack", "spawn", 5],
		["attack", "poison", 2],
		["defend", "attack", 5],
		["defend", "spawn", 5],
		["defend", "poison", 2],
		["spawn", "attack", 4],
		["spawn", "defend", 4],
		["spawn", "poison", 2],
		["poison", "attack", 1],
		["poison", "defend", 1],
		["poison", "spawn", 1],
	],
	"hard": [
		["init", "attack", 1],
		["init", "defend", 1],
		["attack", "defend", 5],
		["attack", "spawn", 5],
		["attack", "poison", 2],
		["defend", "attack", 5],
		["defend", "spawn", 5],
		["defend", "poison", 2],
		["spawn", "attack", 4],
		["spawn", "defend", 4],
		["spawn", "poison", 2],
		["poison", "attack", 1],
		["poison", "defend", 1],
		["poison", "spawn", 1],
	],
}

var first_state = {
	"normal": ["init"],
	"hard": ["init"],
}

var actions = {
	"normal": {
		"init": [
			{"name": "spawn", "enemy": "baby_poison", "animation": "divider"},
			{"name": "spawn", "enemy": "baby_poison", "animation": "divider"},
		],
		"attack": [
			{"name": "shield", "value": [4,5], "animation": ""},
			{"name": "damage", "value": [5,6], "type": "regular", "animation": "atk"},
		],
		"defend": [
			{"name": "shield", "value": [8,10], "animation": ""},
		],
		"poison": [
			{"name": "damage", "value": [5,6], "type": "venom", "animation": "atk"},
		],
		"spawn": [
			{"name": "spawn", "enemy": "baby_poison", "animation": "divider"},
		],
	},
	"hard": {
		"init": [
			{"name": "spawn", "enemy": "baby_poison", "animation": "divider"},
			{"name": "spawn", "enemy": "baby_poison", "animation": "divider"},
		],
		"attack": [
			{"name": "shield", "value": [4,5], "animation": ""},
			{"name": "damage", "value": [5,6], "type": "regular", "animation": "atk"},
		],
		"defend": [
			{"name": "shield", "value": [8,10], "animation": ""},
		],
		"poison": [
			{"name": "damage", "value": [5,6], "type": "venom", "animation": "atk"},
		],
		"spawn": [
			{"name": "spawn", "enemy": "baby_poison", "animation": "divider"},
		],
	},
}


func _init():
	idle_anim_name = "stand"
	death_anim_name = "death"
	dmg_anim_name = "dmg"
