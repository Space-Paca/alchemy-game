extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Burner.tscn"
var image = "res://assets/images/enemies/burner/idle.png"
var name = "EN_BURNER"
var sfx = "burner"
var use_idle_sfx = false
var hp = {
	"normal": 200,
	"hard": 250,
}
var battle_init = false
var size = "medium"
var change_phase = null
var unique_bgm = null

var states = {
	"normal": ["attack1", "attack2", "defend", "burn"],
	"hard": ["attack1", "attack2", "defend", "burn"],
}

var connections = {
	"normal": [
		["attack1", "attack1", 2],
		["attack1", "attack2", 2],
		["attack1", "defend", 2],
		["attack1", "burn", 2],
		["defend", "attack1", 5],
		["defend", "attack2", 5],
		["defend", "defend", 3],
		["defend", "burn", 2],
		["burn", "attack1", 2],
		["burn", "attack2", 2],
		["burn", "defend", 1],
		["attack2", "attack2", 2],
		["attack2", "attack1", 2],
		["attack2", "defend", 2],
		["attack2", "burn", 2],
	],
	"hard": [
		["attack1", "attack1", 2],
		["attack1", "attack2", 2],
		["attack1", "defend", 2],
		["attack1", "burn", 2],
		["defend", "attack1", 5],
		["defend", "attack2", 5],
		["defend", "defend", 3],
		["defend", "burn", 2],
		["burn", "attack1", 2],
		["burn", "attack2", 2],
		["burn", "defend", 1],
		["attack2", "attack2", 2],
		["attack2", "attack1", 2],
		["attack2", "defend", 2],
		["attack2", "burn", 2],
	],
}

var first_state = {
	"normal": ["attack1", "defend", "burn"],
	"hard": ["attack1", "defend", "burn"],
}

var actions = {
	"normal": {
		"burn": [
			{"name": "status", "status_name": "burning", "value": 10, "target": "player", "positive": false, "animation": "02_atk"}
		],
		"attack1": [
			{"name": "damage", "value": [10, 50], "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "burning", "value": 4, "target": "player", "positive": false, "animation": ""}
		],
		"attack2": [
			{"name": "damage", "value": [25, 40], "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "burning", "value": 5, "target": "player", "positive": false, "animation": ""}
		],
		"defend": [
			{"name": "shield", "value": [5, 18], "animation": ""},
			{"name": "status", "status_name": "burning", "value": 6, "target": "player", "positive": false, "animation": "02_atk"}
		],
	},
	"hard": {
		"burn": [
			{"name": "status", "status_name": "burning", "value": 11, "target": "player", "positive": false, "animation": "02_atk"}
		],
		"attack1": [
			{"name": "damage", "value": [20, 51], "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "burning", "value": 5, "target": "player", "positive": false, "animation": ""}
		],
		"attack2": [
			{"name": "damage", "value": [30, 41], "type": "regular", "animation": "02_atk"},
			{"name": "status", "status_name": "burning", "value": 6, "target": "player", "positive": false, "animation": ""}
		],
		"defend": [
			{"name": "shield", "value": [10, 21], "animation": ""},
			{"name": "status", "status_name": "burning", "value": 7, "target": "player", "positive": false, "animation": "02_atk"}
		],
	},
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
