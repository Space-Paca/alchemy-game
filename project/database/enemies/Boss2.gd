extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Boss2.tscn"
var image = "res://assets/images/enemies/boss2/idle.png"
var name = "EN_BOSS_2"
var sfx = "boss-2"
var use_idle_sfx = false
var hp = {
	"normal": 380,
	"hard": 430,
}
var battle_init = true
var size = "medium"
var change_phase = null
var unique_bgm = null

var states = {
	"normal": ["start", "attack1", "attack2", "attack3", "attack4", "attack5", \
			  "restrict_buff", "spawn1", "spawn2", "spawn3"],
	"hard": ["start", "attack1", "attack2", "attack3", "attack4", "attack5", \
			  "restrict_buff", "spawn1", "spawn2", "spawn3"],
}

var connections = {
	"normal": [
		["start", "attack1", 1],
		["attack1", "attack2", 1],
		["attack2", "attack3", 1],
		["attack3", "attack4", 1],
		["attack4", "attack5", 1],
		["attack5", "restrict_buff", 1],
		["restrict_buff", "spawn1", 1],
		["restrict_buff", "spawn2", 1],
		["restrict_buff", "spawn3", 1],
		["spawn1", "attack1", 1],
		["spawn2", "attack1", 1],
		["spawn3", "attack1", 1],
	],
	"hard": [
		["start", "attack1", 1],
		["attack1", "attack2", 1],
		["attack2", "attack3", 1],
		["attack3", "attack4", 1],
		["attack4", "attack5", 1],
		["attack5", "restrict_buff", 1],
		["restrict_buff", "spawn1", 1],
		["restrict_buff", "spawn2", 1],
		["restrict_buff", "spawn3", 1],
		["spawn1", "attack1", 1],
		["spawn2", "attack1", 1],
		["spawn3", "attack1", 1],
	],
}

var first_state = {
	"normal": ["start"],
	"hard": ["start"],
}

var actions = {
	"normal": {
		"start": [
			{"name": "status", "status_name": "restrict_minor", "value": 4, "target": "player", "positive": false, "animation": "atk2"}
		],
		"attack1": [
			{"name": "status", "status_name": "restrict_minor", "value": 4, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "damage", "value": [22,30], "type": "regular", "animation": "atk"},
		],
		"attack2": [
			{"name": "status", "status_name": "restrict_minor", "value": 4, "target": "player", "positive": false, "animation": ""},
			{"name": "damage", "value": [4,5], "type": "regular", "amount": 2, "animation": "atk"},
		],
		"attack3": [
			{"name": "status", "status_name": "restrict_minor", "value": 4, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "damage", "value": [4,5], "type": "regular", "amount": 3, "animation": "atk"},
		],
		"attack4": [
			{"name": "status", "status_name": "restrict_minor", "value": 3, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "damage", "value": [4,5], "type": "regular", "amount": 4, "animation": "atk"},
		],
		"attack5": [
			{"name": "status", "status_name": "restrict_minor", "value": 2, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "damage", "value": [4,5], "type": "regular", "amount": 5, "animation": "atk"},
		],
		"restrict_buff": [
			{"name": "status", "status_name": "restrict_major", "value": 1, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "status", "status_name": "restrict_minor", "value": 2, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "status", "status_name": "perm_strength", "value": 5, "target": "self", "positive": true, "animation": ""},
		],
		"spawn1": [
			{"name": "status", "status_name": "restrict_major", "value": 1, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "status", "status_name": "restrict_minor", "value": 3, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "spawn", "enemy": "baby_poison", "minion": true, "animation": ""},
		],
		"spawn2": [
			{"name": "status", "status_name": "restrict_major", "value": 1, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "status", "status_name": "restrict_minor", "value": 3, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "spawn", "enemy": "baby_carapa", "minion": true, "animation": ""},
		],
		"spawn3": [
			{"name": "status", "status_name": "restrict_major", "value": 1, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "status", "status_name": "restrict_minor", "value": 3, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "spawn", "enemy": "baby_slasher", "minion": true, "animation": ""},
			{"name": "spawn", "enemy": "baby_slasher", "minion": true, "animation": ""},
		],
	},
	"hard": {
		"start": [
			{"name": "status", "status_name": "restrict_minor", "value": 5, "target": "player", "positive": false, "animation": "atk2"}
		],
		"attack1": [
			{"name": "status", "status_name": "restrict_minor", "value": 5, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "damage", "value": [22,30], "type": "regular", "animation": "atk"},
		],
		"attack2": [
			{"name": "status", "status_name": "restrict_minor", "value": 5, "target": "player", "positive": false, "animation": ""},
			{"name": "damage", "value": [4,5], "type": "regular", "amount": 2, "animation": "atk"},
		],
		"attack3": [
			{"name": "status", "status_name": "restrict_minor", "value": 5, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "damage", "value": [4,5], "type": "regular", "amount": 3, "animation": "atk"},
		],
		"attack4": [
			{"name": "status", "status_name": "restrict_minor", "value": 4, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "damage", "value": [4,5], "type": "regular", "amount": 4, "animation": "atk"},
		],
		"attack5": [
			{"name": "status", "status_name": "restrict_minor", "value": 3, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "damage", "value": [4,5], "type": "regular", "amount": 5, "animation": "atk"},
		],
		"restrict_buff": [
			{"name": "status", "status_name": "restrict_major", "value": 1, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "status", "status_name": "restrict_minor", "value": 3, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "status", "status_name": "perm_strength", "value": 7, "target": "self", "positive": true, "animation": ""},
		],
		"spawn1": [
			{"name": "status", "status_name": "restrict_major", "value": 1, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "status", "status_name": "restrict_minor", "value": 4, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "spawn", "enemy": "baby_poison", "minion": true, "animation": ""},
		],
		"spawn2": [
			{"name": "status", "status_name": "restrict_major", "value": 1, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "status", "status_name": "restrict_minor", "value": 4, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "spawn", "enemy": "baby_carapa", "minion": true, "animation": ""},
		],
		"spawn3": [
			{"name": "status", "status_name": "restrict_major", "value": 1, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "status", "status_name": "restrict_minor", "value": 4, "target": "player", "positive": false, "animation": "atk2"},
			{"name": "spawn", "enemy": "baby_slasher", "minion": true, "animation": ""},
			{"name": "spawn", "enemy": "baby_slasher", "minion": true, "animation": ""},
		],
	},
}

func _init():
	idle_anim_name = "stand"
	death_anim_name = "death"
	dmg_anim_name = "dmg"
	variant_idles = ["idle"]
