extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Freezer.tscn"
var image = "res://assets/images/enemies/freezer/idle.png"
var name = "EN_FREEZER"
var sfx = "freezer"
var use_idle_sfx = false
var hp = 80
var battle_init = true
var size = "medium"
var change_phase = null
var unique_bgm = null

var states = ["init", "attack", "attack2", "freeze", "spawn", "buff"]
var connections = [   
					  ["init", "attack", 1],
					  ["attack", "spawn", 5],
					  ["attack", "attack2", 3],
					  ["attack", "freeze", 3],
					  ["attack2", "spawn", 4],
					  ["attack2", "freeze", 3],
					  ["spawn", "attack", 3],
					  ["spawn", "attack2", 2],
					  ["freeze", "attack", 3],
					  ["freeze", "attack2", 2],
					  ["freeze", "spawn", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "shield", "value": 150, "animation": ""},
		{"name": "status", "status_name": "tough", "value": 1, "target": "self", "positive": true, "animation": ""},
		{"name": "status", "status_name": "freeze", "value": 2, "target": "player", "positive": false, "animation": ""},
	],
	"attack": [
		{"name": "damage", "value": [15, 25], "type": "regular", "animation": "02_atk"}
	],
	"attack2": [
		{"name": "damage", "value": 5, "amount": 3, "type": "regular", "animation": "02_atk"},
		{"name": "status", "status_name": "freeze", "value": 4, "target": "player", "positive": false, "animation": ""},
	],
	"freeze": [
		{"name": "status", "status_name": "freeze", "value": 4, "target": "player", "positive": false, "animation": ""},
		{"name": "shield", "value": [5,10], "animation": "03_dmg"},
		{"name": "status", "status_name": "perm_strength", "value": 2, "target": "self", "positive": true, "animation": ""},
	],
	"spawn": [
		{"name": "status", "status_name": "freeze", "value": 3, "target": "player", "positive": false, "animation": ""},
		{"name": "spawn", "enemy": "self_destructor", "animation": "03_dmg"},
		{"name": "status", "status_name": "perm_strength", "value": 6, "target": "self", "positive": true, "animation": ""},
	],
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
